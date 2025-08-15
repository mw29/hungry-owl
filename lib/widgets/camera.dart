import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hungryowl/screens/food_data.dart';
import 'package:hungryowl/screens/manual_entry.dart';

class Camera extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const Camera({super.key, required this.cameras});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? _controller;
  FlashMode _flashMode = FlashMode.off;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.cameras != null && widget.cameras!.isNotEmpty) {
      _initializeCamera(widget.cameras!.first);
    }
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    if (_controller == null) return;

    setState(() {
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      _controller!.setFlashMode(_flashMode);
    });
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile file = await _controller!.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodData(imagePath: file.path),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: _errorMessage != null
            ? Text(
                "Error: $_errorMessage",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            : const Text("No camera available"),
      );
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Positioned(
          bottom: 120,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Point your camera at a food item.\nTap the capture button to analyze it.",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                "Enter Food Manually",
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                backgroundColor: Colors.black38,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualEntryScreen(),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              heroTag: 'camera_fab',
              onPressed: _takePicture,
              child: const Icon(Icons.camera),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: Icon(
              _flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ),
      ],
    );
  }
}
