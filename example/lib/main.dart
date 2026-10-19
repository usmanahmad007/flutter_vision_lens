import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';
import 'package:image_picker/image_picker.dart';

void main() {
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

/// Interactive screen with camera simulation and multimodal vision overlay.
class VisionLensDemoScreen extends StatefulWidget {
  /// Creates the [VisionLensDemoScreen].
  const VisionLensDemoScreen({super.key});

  @override
  State<VisionLensDemoScreen> createState() => _VisionLensDemoScreenState();
}

class _VisionLensDemoScreenState extends State<VisionLensDemoScreen> {
  late final VisionLensController _controller;
  late VisionAiAdapter _adapter;
  Uint8List? _customImageBytes;

  @override
  void initState() {
    super.initState();
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
        VisionObject(
          id: '3',
          label: 'Receipt Code',
          confidence: 0.91,
          normalizedRect: Rect.fromLTWH(0.25, 0.58, 0.50, 0.18),
          highlightColor: Color(0xFFFFD700),
        ),
      ],
    );

    // Default to offline mock adapter so it works without any API keys!
    _adapter = const MockVisionAdapter();
  }

  @override
  void dispose() {
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
        _controller.clearSelection();
      });
    }
  }

  void _clearCustomImage() {
    setState(() {
      _customImageBytes = null;
      _controller.clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_customImageBytes != null ? 'Testing On Your Picture 📷' : 'Flutter Vision Lens 🔍'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_customImageBytes != null)
            IconButton(
              tooltip: 'Reset to Sample View',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _clearCustomImage,
            ),
          IconButton(
            tooltip: 'Upload / Pick Picture',
            icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.cyanAccent),
            onPressed: _pickCustomImage,
          ),
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
        child: _customImageBytes != null
            ? Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: Image.memory(
                  _customImageBytes!,
                  fit: BoxFit.contain,
                ),
              )
            : _buildCameraSimulationView(),
      ),
    );
  }

  Widget _buildCameraSimulationView() {
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
                'Tap, lasso, or box-select any area below, or upload your own picture!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18.0),

              // Upload Button
              ElevatedButton.icon(
                onPressed: _pickCustomImage,
                icon: const Icon(Icons.upload_file_rounded, size: 18.0),
                label: const Text('Upload Your Own Picture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withAlpha(40),
                  foregroundColor: Colors.cyanAccent,
                  side: const BorderSide(color: Colors.cyanAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
              ),

              const SizedBox(height: 24.0),

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
              const SizedBox(height: 12.0),
              _buildSimulationCard(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Invoice SKU #FL-VISION-2026',
                subtitle: 'Select with bounding box to extract numbers (OCR)',
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
