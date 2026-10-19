import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../adapters/vision_ai_adapter.dart';
import '../controllers/vision_lens_controller.dart';

/// Floating result card displaying multimodal intelligence insights,
/// quick action prompt chips, and copy actions.
class VisionLensResultSheet extends StatelessWidget {
  /// The vision controller managing state.
  final VisionLensController controller;

  /// Callback when a quick action prompt chip is tapped.
  final void Function(String prompt)? onPromptSelected;

  /// Callback when the dismiss/close button is tapped.
  final VoidCallback? onClose;

  /// Creates a [VisionLensResultSheet].
  const VisionLensResultSheet({
    super.key,
    required this.controller,
    this.onPromptSelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final style = controller.style;
    final isAnalyzing = controller.isAnalyzing;
    final result = controller.analysisResult;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withAlpha(240),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: style.primaryColor.withAlpha(90),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: style.primaryColor.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 18.0,
                  color: style.primaryColor,
                ),
              ),
              const SizedBox(width: 10.0),
              const Expanded(
                child: Text(
                  'Visual Intelligence',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (result != null && result.isNotEmpty)
                IconButton(
                  tooltip: 'Copy Output',
                  icon: const Icon(Icons.copy_rounded, size: 18.0, color: Colors.white70),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              IconButton(
                tooltip: 'Dismiss',
                icon: const Icon(Icons.close_rounded, size: 20.0, color: Colors.white70),
                onPressed: onClose ?? () => controller.clearSelection(),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Content body
          if (isAnalyzing) ...[
            Row(
              children: [
                SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(style.primaryColor),
                  ),
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Analyzing visual region with AI...',
                  style: TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
              ],
            ),
          ] else if (result != null && result.isNotEmpty) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180.0),
              child: SingleChildScrollView(
                child: Text(
                  result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'Select an action below or ask a custom question about this area:',
              style: TextStyle(color: Colors.white70, fontSize: 13.0),
            ),
          ],

          const SizedBox(height: 14.0),

          // Quick Action Prompt Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.search_rounded,
                  label: 'Explain',
                  onTap: () => onPromptSelected?.call(VisionAiAdapter.promptExplain),
                ),
                const SizedBox(width: 8.0),
                _buildActionChip(
                  icon: Icons.text_fields_rounded,
                  label: 'Extract Text',
                  onTap: () => onPromptSelected?.call(VisionAiAdapter.promptOCR),
                ),
                const SizedBox(width: 8.0),
                _buildActionChip(
                  icon: Icons.translate_rounded,
                  label: 'Translate',
                  onTap: () => onPromptSelected?.call(VisionAiAdapter.promptTranslate()),
                ),
                const SizedBox(width: 8.0),
                _buildActionChip(
                  icon: Icons.calculate_rounded,
                  label: 'Solve',
                  onTap: () => onPromptSelected?.call(VisionAiAdapter.promptSolve),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: Colors.white),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
