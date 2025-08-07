import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_app/providers/user_state.dart';
import 'package:scan_app/screens/food_data.dart';
import 'package:scan_app/screens/manual_entry.dart';
import 'package:scan_app/screens/profile.dart';
import 'package:scan_app/screens/symptom_settings.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  FlashMode _flashMode = FlashMode.off;

  bool _isLoading = false;
  bool _hasPermission = false;
  bool _noCameras = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraAvailability();
  }

  Future<void> _checkCameraAvailability() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        setState(() {
          _noCameras = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _requestCameraPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

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

  void _toggleFlash() {
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.torch;
      } else {
        _flashMode = FlashMode.off;
      }
      _controller!.setFlashMode(_flashMode);
    });
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    try {
      final XFile file = await _controller!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodData(imagePath: file.path),
        ),
      );
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        _hasPermission
            ? CameraPreview(_controller!)
            : Center(child: _buildPermissionUI()),
        const SymptomSettings(),
      ];

  Widget _buildPermissionUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_noCameras) ...[
          ElevatedButton(
            onPressed: _requestCameraPermissions,
            child: const Text("Request Camera Permission"),
          ),
          const SizedBox(height: 16),
          const Text("or"),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManualEntryScreen(),
              ),
            );
          },
          child: const Text('Enter Food Manually'),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              "Error: $_errorMessage",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (previous, next) {});
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan App"),
        actions: [
          if (_hasPermission)
            IconButton(
              icon: Icon(_flashMode == FlashMode.torch
                  ? Icons.flash_on
                  : Icons.flash_off),
              onPressed: _toggleFlash,
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
      floatingActionButton: _selectedIndex == 0 && _hasPermission
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'home_fab',
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualEntryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Manual Entry',
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
