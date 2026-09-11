import 'package:flutter/material.dart';
import 'package:subtitle_core/subtitle_core.dart';
import 'package:design_system/design_system.dart';

/// Renders active subtitle cues on top of the video frame with character styling and outline contrast.
class SmartSubtitleOverlay extends StatelessWidget {
  final List<UnifiedSubtitleCue> activeCues;
  final double fontSize;
  final Color defaultTextColor;
  final Color outlineColor;
  final double outlineWidth;
  final Color shadowColor;
  final double bottomMargin;

  const SmartSubtitleOverlay({
    super.key,
    required this.activeCues,
    this.fontSize = 22.0,
    this.defaultTextColor = Colors.white,
    this.outlineColor = Colors.black,
    this.outlineWidth = 2.5,
    this.shadowColor = const Color(0xAA000000),
    this.bottomMargin = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    if (activeCues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomMargin,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: activeCues.map((cue) => _buildCueLine(cue)).toList(),
        ),
      ),
    );
  }

  Widget _buildCueLine(UnifiedSubtitleCue cue) {
    Color textColor = defaultTextColor;

    // Use character color if present
    if (cue.characterColorHex != null && cue.characterColorHex!.isNotEmpty) {
      final hex = cue.characterColorHex!.replaceAll('#', '');
      if (hex.length == 6) {
        textColor = Color(int.parse('FF$hex', radix: 16));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Text Outline (Stroke)
          if (outlineWidth > 0)
            Text(
              cue.text,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                fontSize: fontSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = outlineWidth * 2
                  ..color = outlineColor,
              ),
            ),

          // 2. Primary Foreground Text with Shadow
          Text(
            cue.text,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              fontSize: fontSize,
              color: textColor,
              shadows: [
                Shadow(
                  color: shadowColor,
                  blurRadius: 4.0,
                  offset: const Offset(1.5, 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
