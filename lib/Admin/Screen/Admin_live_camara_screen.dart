import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'dart:math';

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
  List<dynamic> _detections = [];
  static const int inputSize = 300; // Input size for the SSD MobileNet model
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
      final rawLabels =
          await DefaultAssetBundle.of(context).loadString('asset/images/ssd_mobilenet.txt');
      _labels = rawLabels.split('\n');

      setState(() {
        isModelLoaded = true;
      });
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Obtain a list of available cameras
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      await _controller.initialize();

      // Start the image stream and process the frames
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
      // Ensure the model is loaded
      if (!isModelLoaded) return;

      // Preprocess the image
      final input = _preprocessImage(image);

      // Define the output tensors
      final outputBoxes = List.filled(1 * 1917 * 4, 0.0).reshape([1, 1917, 4]);
      final outputClasses = List.filled(1 * 1917, 0.0).reshape([1, 1917]);
      final outputScores = List.filled(1 * 1917, 0.0).reshape([1, 1917]);

      // Run inference
      _interpreter.runForMultipleInputs([input], {
        0: outputBoxes,
        1: outputScores,
        2: outputClasses,
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
    // Resize and normalize the image
    // Convert to Uint8List format
    // You may need to implement resizing and normalization based on the input requirements of your model.
    Uint8List processedImage = Uint8List(inputSize * inputSize * 3);
    return processedImage;
  }

  List<Map<String, dynamic>> _parseDetections(
      dynamic boxes,
      dynamic scores,
      dynamic classes) {
      dynamic detections = [];
    for (int i = 0; i < scores[0].length; i++) {
      if (scores[0][i] > threshold) {
        detections.add({
          'boundingBox': Rect.fromLTRB(
            boxes[0][i][0],
            boxes[0][i][1],
            boxes[0][i][2],
            boxes[0][i][3],
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
