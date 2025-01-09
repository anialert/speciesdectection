import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AdminCameraScreen extends StatefulWidget {
  @override
  _AdminCameraScreenState createState() => _AdminCameraScreenState();
}

class _AdminCameraScreenState extends State<AdminCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isLoading =  false;



  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      isLoading = true;
    });
    // Obtain a list of available cameras
    final cameras = await availableCameras();
    // Get the first camera
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

     await  _controller.initialize();

    await _controller.startImageStream((CameraImage image) {

      print(image.width);
      // Process the image here
     
  
      // You can perform additional processing on the image here
      // For example, if you want to convert the image to a different format
    });





   

    setState(() {
      isLoading = false;
    });
  }

  void _handleLiveFeed() {

    print('Live feed started');
    // Start the image stream
    _controller.startImageStream((CameraImage image) {

      print(image.width);
      // Process the image here
     
  
      // You can perform additional processing on the image here
      // For example, if you want to convert the image to a different format
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.stopImageStream(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?   Center(child: CircularProgressIndicator(),) :CameraPreview(_controller    );
  }
}
