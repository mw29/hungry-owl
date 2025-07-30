import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scan_app/screens/food_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  bool _isLoading = false;
  bool _hasPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermissions();
  }

  Future<void> _requestCameraPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _cameras = await availableCameras();

      if (_cameras!.isEmpty) {
        setState(() {
          _hasPermission = false;
          _errorMessage = "No cameras available";
          _isLoading = false;
        });
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _errorMessage = e.toString();
      });
      debugPrint("Camera permission/initialization error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan App")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasPermission
              ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CameraPreview(_controller!),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FoodData()),
                          );
                        },
                        child: const Text("Scan Food"),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _requestCameraPermissions,
                        child: const Text("Request Camera Permission"),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "Error: $_errorMessage",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}