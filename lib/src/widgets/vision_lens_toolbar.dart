import 'package:flutter/material.dart';
import '../controllers/vision_lens_controller.dart';
import '../models/vision_lens_mode.dart';

/// Floating mode selector pill allowing users to switch between
/// Tap-to-Inspect, Freehand Lasso, and Bounding Box selection.
class VisionLensToolbar extends StatelessWidget {
  /// The active vision controller.
  final VisionLensController controller;

  /// Creates a [VisionLensToolbar].
  const VisionLensToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final style = controller.style;
    final currentMode = controller.mode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withAlpha(220),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: Colors.white.withAlpha(35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            icon: Icons.touch_app_rounded,
            tooltip: 'Tap to Inspect',
            isSelected: currentMode == VisionLensMode.tapInspect,
            activeColor: style.primaryColor,
            onTap: () => controller.mode = VisionLensMode.tapInspect,
          ),
          const SizedBox(width: 4.0),
          _buildModeButton(
            icon: Icons.gesture_rounded,
            tooltip: 'Freehand Lasso',
            isSelected: currentMode == VisionLensMode.lasso,
            activeColor: style.primaryColor,
            onTap: () => controller.mode = VisionLensMode.lasso,
          ),
          const SizedBox(width: 4.0),
          _buildModeButton(
            icon: Icons.crop_free_rounded,
            tooltip: 'Bounding Box',
            isSelected: currentMode == VisionLensMode.boundingBox,
            activeColor: style.primaryColor,
            onTap: () => controller.mode = VisionLensMode.boundingBox,
          ),
          if (controller.activeRegion != null) ...[
            const SizedBox(width: 6.0),
            Container(
              width: 1.0,
              height: 20.0,
              color: Colors.white.withAlpha(40),
            ),
            const SizedBox(width: 6.0),
            _buildModeButton(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Clear Selection',
              isSelected: false,
              activeColor: Colors.white70,
              onTap: () => controller.clearSelection(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withAlpha(45) : Colors.transparent,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: activeColor.withAlpha(180), width: 1.2)
                : null,
          ),
          child: Icon(
            icon,
            size: 20.0,
            color: isSelected ? activeColor : Colors.white70,
          ),
        ),
      ),
    );
  }
}
