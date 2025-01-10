import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;

class AdminCameraScreen extends StatefulWidget {
  @override
  _AdminCameraScreenState createState() => _AdminCameraScreenState();
}

class _AdminCameraScreenState extends State<AdminCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Interpreter _interpreter;

  bool isLoading = true;
  bool isModelLoaded = false;
  List<Map<String, dynamic>> _detections = [];
  static const int inputSize = 300; // Input size for SSD MobileNet
  static const double threshold = 0.5; // Confidence threshold
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('asset/images/ssd_mobilenet.tflite');
      print('Model loaded successfully.');

      // Load labels
      final rawLabels = await DefaultAssetBundle.of(context)
          .loadString('asset/images/ssd_mobilenet.txt');
      _labels = rawLabels.split('\n').where((label) => label.isNotEmpty).toList();

      setState(() {
        isModelLoaded = true;
      });
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      await _controller.initialize();

      _controller.startImageStream((CameraImage image) {
        if (!isLoading && isModelLoaded) {
          setState(() {
            isLoading = true;
          });
          _runModel(image);
        }
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Failed to initialize camera: $e');
    }
  }

 Future<void> _runModel(CameraImage image) async {
  try {
    if (!isModelLoaded) {
      print('Model not loaded yet.');
      return;
    }

    // Preprocess the image
    Uint8List input = _preprocessImage(image);

    // Define the output tensors with the correct shapes
    final outputBoxes = List.filled(1 * 10 * 4, 0.0).reshape([1, 10, 4]); // [1, 10, 4]
    final outputScores = List.filled(1 * 10, 0.0).reshape([1, 10]);       // [1, 10]
    final outputClasses = List.filled(1 * 10, 0.0).reshape([1, 10]);      // [1, 10]
    final outputValidDetections = List.filled(1, 0.0);                    // [1]

    // Run inference
    _interpreter.run(input, {
      0: outputBoxes,
      1: outputScores,
      2: outputClasses,
      3: outputValidDetections,
    });

    // Parse results
    _detections = _parseDetections(outputBoxes, outputScores, outputClasses);

    setState(() {});
  } catch (e) {
    print('Error running model: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

Uint8List _preprocessImage(CameraImage image) {
  final int width = image.width;
  final int height = image.height;

  Uint8List rgbBytes = Uint8List(width * height * 3);

  // Extract YUV planes
  final Plane yPlane = image.planes[0];
  final Plane uPlane = image.planes[1];
  final Plane vPlane = image.planes[2];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yValue = yPlane.bytes[y * yPlane.bytesPerRow + x];
      final int uValue = uPlane.bytes[(y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2)];
      final int vValue = vPlane.bytes[(y ~/ 2) * vPlane.bytesPerRow + (x ~/ 2)];

      final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
      final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).clamp(0, 255).toInt();
      final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

      final int index = (y * width + x) * 3;
      rgbBytes[index] = r;
      rgbBytes[index + 1] = g;
      rgbBytes[index + 2] = b;
    }
  }

  // Resize to 300x300 (model input size)
  Uint8List resizedBytes = _resizeImage(rgbBytes, width, height, inputSize, inputSize);

  // If the model expects Float32, normalize to [-1, 1]
  // If Uint8 is expected, skip normalization
  if (_interpreter.getInputTensor(0).type == TfLiteType.kTfLiteFloat32) {
    Float32List normalizedBytes = Float32List(inputSize * inputSize * 3);
    for (int i = 0; i < resizedBytes.length; i++) {
      normalizedBytes[i] = (resizedBytes[i] - 127.5) / 127.5;
    }
    return Uint8List.view(normalizedBytes.buffer);
  }

  return resizedBytes; // For Uint8 input
}

Uint8List _resizeImage(Uint8List input, int srcWidth, int srcHeight, int dstWidth, int dstHeight) {
  final Uint8List output = Uint8List(dstWidth * dstHeight * 3);

  for (int y = 0; y < dstHeight; y++) {
    for (int x = 0; x < dstWidth; x++) {
      final int srcX = (x * srcWidth / dstWidth).floor();
      final int srcY = (y * srcHeight / dstHeight).floor();

      final int srcIndex = (srcY * srcWidth + srcX) * 3;
      final int dstIndex = (y * dstWidth + x) * 3;

      output[dstIndex] = input[srcIndex];
      output[dstIndex + 1] = input[srcIndex + 1];
      output[dstIndex + 2] = input[srcIndex + 2];
    }
  }

  return output;
}

List<Map<String, dynamic>> _parseDetections(
    List<dynamic> boxes, List<dynamic> scores, List<dynamic> classes) {
  List<Map<String, dynamic>> detections = [];
  for (int i = 0; i < min(scores[0].length, 10); i++) {
    if (scores[0][i] > threshold) {
      detections.add({
        'boundingBox': Rect.fromLTRB(
          boxes[0][i][1] * inputSize, // xmin
          boxes[0][i][0] * inputSize, // ymin
          boxes[0][i][3] * inputSize, // xmax
          boxes[0][i][2] * inputSize, // ymax
        ),
        'confidence': scores[0][i],
        'label': _labels[classes[0][i].toInt()],
      });
    }
  }
  return detections;
}


  
  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : CameraPreview(_controller),
          ..._detections.map((detection) {
            final box = detection['boundingBox'] as Rect;
            final label = detection['label'];
            final confidence = detection['confidence'];
            return Positioned(
              left: box.left,
              top: box.top,
              width: box.width,
              height: box.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(
                  '$label (${(confidence * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
