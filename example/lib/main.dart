import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VisionLensDemoApp());
}

/// Demonstration application showcasing flutter_vision_lens capabilities.
class VisionLensDemoApp extends StatelessWidget {
  /// Creates the [VisionLensDemoApp].
  const VisionLensDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Vision Lens Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
      ),
      home: const VisionLensDemoScreen(),
    );
  }
}

/// Interactive screen supporting live real camera feed, picture upload,
/// and simulated vision objects.
class VisionLensDemoScreen extends StatefulWidget {
  /// Creates the [VisionLensDemoScreen].
  const VisionLensDemoScreen({super.key});

  @override
  State<VisionLensDemoScreen> createState() => _VisionLensDemoScreenState();
}

class _VisionLensDemoScreenState extends State<VisionLensDemoScreen>
    with WidgetsBindingObserver {
  late final VisionLensController _controller;
  late VisionAiAdapter _adapter;

  // Real Camera state
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _useLiveCamera = true;
  String? _cameraErrorMessage;

  // Uploaded picture state
  Uint8List? _customImageBytes;

  // In-app API Key (persists in state only, never committed to git)
  String? _geminiApiKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VisionLensController(
      style: VisionLensStyle.appleIntelligence(),
      initialObjects: const [
        VisionObject(
          id: '1',
          label: 'Smart Watch',
          confidence: 0.96,
          normalizedRect: Rect.fromLTWH(0.12, 0.28, 0.35, 0.20),
          highlightColor: Color(0xFF00E5FF),
        ),
        VisionObject(
          id: '2',
          label: 'Math Equation',
          confidence: 0.94,
          normalizedRect: Rect.fromLTWH(0.55, 0.32, 0.35, 0.16),
          highlightColor: Color(0xFFFF4081),
        ),
      ],
    );

    // Default to offline MockVisionAdapter so developers can run immediately.
    _adapter = const MockVisionAdapter();

    // Initialize the real hardware camera
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController(cameraController.description);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameras = cameras;
        await _setupCameraController(cameras[0]);
      } else {
        setState(() {
          _useLiveCamera = false;
          _cameraErrorMessage = 'No physical cameras detected on this device.';
        });
      }
    } catch (e) {
      setState(() {
        _useLiveCamera = false;
        _cameraErrorMessage = 'Camera permission or initialization error: $e';
      });
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    await _cameraController?.dispose();

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _cameraErrorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _cameraErrorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isCameraInitialized = false);
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _switchStyle(VisionLensStyle newStyle) {
    setState(() {
      _controller.style = newStyle;
    });
  }

  Future<void> _pickCustomImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _customImageBytes = bytes;
        _useLiveCamera = false;
        _controller.clearSelection();
      });
    }
  }

  void _clearCustomImage() {
    setState(() {
      _customImageBytes = null;
      _useLiveCamera = true;
      _controller.clearSelection();
    });
  }

  void _showApiKeyDialog() {
    final textController = TextEditingController(text: _geminiApiKey ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: const Row(
          children: [
            Icon(Icons.key_rounded, color: Colors.amberAccent),
            SizedBox(width: 8),
            Text(
              'Gemini API Key',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your Gemini API key to activate live multimodal AI recognition on camera:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter your Gemini API key...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _geminiApiKey = null;
                _adapter = const MockVisionAdapter();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Switched to Mock Vision AI')),
              );
            },
            child: const Text('Use Mock AI', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              final key = textController.text.trim();
              if (key.isNotEmpty) {
                setState(() {
                  _geminiApiKey = key;
                  _adapter = GeminiVisionAdapter(apiKey: key);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚡ Gemini Multimodal AI Activated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save & Activate',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _useLiveCamera
              ? 'Live Camera Lens 📷'
              : (_customImageBytes != null
                  ? 'Testing On Your Picture 🖼️'
                  : 'Interactive Simulation ✨'),
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Clear custom image and return to camera
          if (_customImageBytes != null)
            IconButton(
              tooltip: 'Clear Picture & Return to Camera',
              icon: const Icon(Icons.close_rounded),
              onPressed: _clearCustomImage,
            ),

          // Live Camera toggle
          if (_cameras.isNotEmpty)
            IconButton(
              tooltip: _useLiveCamera ? 'Switch to Simulation' : 'Switch to Live Camera',
              icon: Icon(
                _useLiveCamera ? Icons.camera_alt : Icons.camera_alt_outlined,
                color: _useLiveCamera ? Colors.cyanAccent : Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _useLiveCamera = !_useLiveCamera;
                  _customImageBytes = null;
                  _controller.clearSelection();
                });
              },
            ),

          // Flip camera (front/back)
          if (_useLiveCamera && _cameras.length > 1)
            IconButton(
              tooltip: 'Flip Camera',
              icon: const Icon(Icons.flip_camera_ios_rounded),
              onPressed: _switchCamera,
            ),

          // Flash/Torch toggle
          if (_useLiveCamera)
            IconButton(
              tooltip: _isFlashOn ? 'Turn Flash Off' : 'Turn Flash On',
              icon: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isFlashOn ? Colors.amberAccent : Colors.white70,
              ),
              onPressed: _toggleFlash,
            ),

          // Pick picture from gallery
          IconButton(
            tooltip: 'Pick Picture',
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: _pickCustomImage,
          ),

          // Configure API Key
          IconButton(
            tooltip: 'Configure Gemini API Key',
            icon: Icon(
              Icons.key_rounded,
              color: _geminiApiKey != null ? Colors.amberAccent : Colors.white70,
            ),
            onPressed: _showApiKeyDialog,
          ),

          // Theme selector
          PopupMenuButton<String>(
            tooltip: 'Choose Visual Theme',
            icon: const Icon(Icons.palette_outlined),
            onSelected: (value) {
              if (value == 'apple') {
                _switchStyle(VisionLensStyle.appleIntelligence());
              } else if (value == 'google') {
                _switchStyle(VisionLensStyle.googleLens());
              } else if (value == 'cyberpunk') {
                _switchStyle(VisionLensStyle.cyberpunk());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'apple',
                child: Text('Apple Visual Intelligence Style'),
              ),
              const PopupMenuItem(
                value: 'google',
                child: Text('Google Lens Style'),
              ),
              const PopupMenuItem(
                value: 'cyberpunk',
                child: Text('Cyberpunk Neon Style'),
              ),
            ],
          ),
        ],
      ),
      body: VisionLensOverlay(
        controller: _controller,
        adapter: _adapter,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_customImageBytes != null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Image.memory(
          _customImageBytes!,
          fit: BoxFit.contain,
        ),
      );
    }

    if (_useLiveCamera) {
      return _buildCameraView();
    }

    return _buildSimulationView();
  }

  Widget _buildCameraView() {
    if (_cameraErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded, size: 48, color: Colors.orangeAccent),
              const SizedBox(height: 12),
              Text(
                _cameraErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Retry Camera'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.cyanAccent),
            SizedBox(height: 16),
            Text(
              'Connecting to Real Camera...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize?.height ?? constraints.maxWidth,
              height: _cameraController!.value.previewSize?.width ?? constraints.maxHeight,
              child: CameraPreview(_cameraController!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulationView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14141E), Color(0xFF0A0A10)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.center_focus_weak_rounded,
                size: 56.0,
                color: Colors.cyanAccent,
              ),
              const SizedBox(height: 12.0),
              const Text(
                'Interactive Visual Intelligence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Tap, lasso, or box-select any area below, or toggle to Live Camera above!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20.0),
              _buildSimulationCard(
                icon: Icons.watch_rounded,
                title: 'Smart Watch Display',
                subtitle: 'Tap to inspect hardware specs or translate display',
              ),
              const SizedBox(height: 12.0),
              _buildSimulationCard(
                icon: Icons.functions_rounded,
                title: 'Math Equation: 3x + 15 = 45',
                subtitle: 'Draw a lasso around the equation to solve step-by-step',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulationCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11.5,
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
