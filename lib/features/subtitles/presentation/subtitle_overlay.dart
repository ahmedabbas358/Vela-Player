import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/subtitles/models/subtitle_cue.dart';
import '../../../core/subtitles/models/subtitle_style.dart';
import '../../../core/subtitles/subtitle_manager.dart';

/// Renders the active subtitle cue with rich visual styling and draggable positioning
class SubtitleOverlay extends ConsumerStatefulWidget {
  final bool enableDrag;

  const SubtitleOverlay({super.key, this.enableDrag = true});

  @override
  ConsumerState<SubtitleOverlay> createState() => _SubtitleOverlayState();
}

class _SubtitleOverlayState extends ConsumerState<SubtitleOverlay> {
  Offset? _dragOffset;

  TextStyle _getGoogleFont(String family, {required TextStyle baseStyle}) {
    try {
      switch (family.toLowerCase()) {
        case 'cairo':
          return GoogleFonts.cairo(textStyle: baseStyle);
        case 'tajawal':
          return GoogleFonts.tajawal(textStyle: baseStyle);
        case 'amiri':
          return GoogleFonts.amiri(textStyle: baseStyle);
        case 'outfit':
          return GoogleFonts.outfit(textStyle: baseStyle);
        case 'rubik':
          return GoogleFonts.rubik(textStyle: baseStyle);
        case 'roboto':
        default:
          return GoogleFonts.roboto(textStyle: baseStyle);
      }
    } catch (_) {
      return baseStyle.copyWith(fontFamily: family);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subtitleProvider);
    final cue = subState.activeCue;
    final style = subState.style;

    if (!subState.isVisible || cue == null || cue.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate default position based on style.verticalPositionPercentage
        final defaultY = screenHeight * style.verticalPositionPercentage;
        final position =
            _dragOffset ??
            style.customOffset ??
            Offset(screenWidth / 2, defaultY);

        return Stack(
          children: [
            Positioned(
              left: widget.enableDrag
                  ? (position.dx - (screenWidth * 0.45)).clamp(
                      16.0,
                      screenWidth - 100.0,
                    )
                  : 16.0,
              right: widget.enableDrag ? null : 16.0,
              top: (position.dy - 30.0).clamp(20.0, screenHeight - 80.0),
              child: GestureDetector(
                onPanUpdate: widget.enableDrag
                    ? (details) {
                        setState(() {
                          _dragOffset = Offset(
                            (_dragOffset?.dx ?? position.dx) + details.delta.dx,
                            (_dragOffset?.dy ?? position.dy) + details.delta.dy,
                          );
                        });
                      }
                    : null,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                    child: _buildSubtitleText(cue, style),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubtitleText(SubtitleCue cue, SubtitleStyle style) {
    // Dynamic speaker color support (preparation for Phase 4 AI Character Coloring)
    final effectiveTextColor = cue.speakerColor ?? style.textColor;

    final baseStyle = TextStyle(
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      letterSpacing: style.letterSpacing,
      height: style.lineHeight,
    );

    final fontStyle = _getGoogleFont(style.fontFamily, baseStyle: baseStyle);

    Widget content;

    if (style.outlineWidth > 0) {
      // Stack two text layers: outline layer behind + filled text layer in front
      content = Stack(
        alignment: Alignment.center,
        children: [
          // Outline stroke layer
          Text(
            cue.text,
            textAlign: TextAlign.center,
            style: fontStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = style.outlineWidth * 2
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..color = style.outlineColor,
            ),
          ),
          // Filled foreground layer with soft glow shadow
          Text(
            cue.text,
            textAlign: TextAlign.center,
            style: fontStyle.copyWith(
              color: effectiveTextColor,
              shadows: style.glowRadius > 0
                  ? [
                      Shadow(
                        color: style.glowColor,
                        blurRadius: style.glowRadius,
                        offset: const Offset(0, 1.5),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        cue.text,
        textAlign: TextAlign.center,
        style: fontStyle.copyWith(
          color: effectiveTextColor,
          shadows: style.glowRadius > 0
              ? [
                  Shadow(
                    color: style.glowColor,
                    blurRadius: style.glowRadius,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      );
    }

    if (style.showBackgroundBox) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: style.boxPadding * 1.5,
          vertical: style.boxPadding,
        ),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: content,
      );
    }

    return content;
  }
}
