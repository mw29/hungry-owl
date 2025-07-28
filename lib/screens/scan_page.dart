import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

List<CameraDescription> cameras = [];

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? controller;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        await controller?.initialize();
        if (!mounted) {
          return;
        }
        setState(() {});
      }
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          print('User denied camera access.');
          break;
        default:
          print('Handle other errors: ${e.code}');
          break;
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    final CameraController cameraController = controller!;

    if (cameraController.value.isTakingPicture) {
      return;
    }

    try {
      final XFile file = await cameraController.takePicture();
      setState(() {
        _imageFile = file;
      });
    } on CameraException catch (e) {
      print('Error taking picture: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Food')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile == null
                ? CameraPreview(controller!)
                : Image.file(File(_imageFile!.path)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera_alt),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = null; 
                        });
                      },
                      child: const Icon(Icons.refresh),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}