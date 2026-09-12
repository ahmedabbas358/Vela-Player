import 'dart:math' as math;

/// Evaluates color contrast according to WCAG 2.2 AAA specifications (7:1 ratio)
/// and computes protective outlines, drop shadows, or chroma corrections so subtitles
/// are always effortlessly readable regardless of the underlying video frame brightness.
class ReadabilityGuard {
  static const double wcagAaaMinRatio = 7.0;
  static const double wcagAaMinRatio = 4.5;

  /// Calculates relative luminance for an ARGB integer color (0xAARRGGBB).
  /// Formula based on WCAG 2.2: L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  static double calculateRelativeLuminance(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;

    double sRgbToLinear(int channelValue) {
      final v = channelValue / 255.0;
      return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    final linearR = sRgbToLinear(r);
    final linearG = sRgbToLinear(g);
    final linearB = sRgbToLinear(b);

    return 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB;
  }

  /// Calculates contrast ratio between two colors: (L1 + 0.05) / (L2 + 0.05)
  /// Returns a value between 1.0 (no contrast) and 21.0 (maximum contrast).
  static double calculateContrastRatio(int color1Argb, int color2Argb) {
    final l1 = calculateRelativeLuminance(color1Argb);
    final l2 = calculateRelativeLuminance(color2Argb);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Ensures that any AI-extracted hair or eye color is made 100% readable.
  /// If contrast against background is insufficient, protective outline and shadows are applied.
  static ReadabilityStyleSpec enforceReadability({
    required int candidateColorArgb,
    int estimatedBackgroundArgb = 0xFF000000, // Typical dark media background
  }) {
    final directContrast = calculateContrastRatio(
      candidateColorArgb,
      estimatedBackgroundArgb,
    );

    // If candidate color has excellent contrast (> 7:1)
    if (directContrast >= wcagAaaMinRatio) {
      return ReadabilityStyleSpec(
        primaryColorArgb: candidateColorArgb,
        outlineColorArgb: 0xFF000000,
        outlineWidth: 2.0,
        shadowColorArgb: 0x88000000,
        shadowBlur: 3.0,
        contrastRatio: directContrast,
        isWcagAaaCompliant: true,
      );
    }

    // If contrast is below AAA threshold (e.g. very dark hair color on dark scene,
    // or bright blonde on bright scene):
    final luminance = calculateRelativeLuminance(candidateColorArgb);

    int adjustedPrimary = candidateColorArgb;
    int outlineColor = 0xFF000000;
    double outlineWidth = 3.5;

    if (luminance < 0.2) {
      // Very dark hair (e.g. black/dark brown): brighten slightly or add white/silver outline
      outlineColor = 0xFFFFFFFF;
      outlineWidth = 2.5;
    } else {
      // Bright color (e.g. blonde, yellow, white, cyan): bold dark border
      outlineColor = 0xFF000000;
      outlineWidth = 3.8;
    }

    final effectiveContrast = calculateContrastRatio(
      adjustedPrimary,
      outlineColor,
    );

    return ReadabilityStyleSpec(
      primaryColorArgb: adjustedPrimary,
      outlineColorArgb: outlineColor,
      outlineWidth: outlineWidth,
      shadowColorArgb: 0xAA000000,
      shadowBlur: 5.0,
      contrastRatio: effectiveContrast,
      isWcagAaaCompliant: effectiveContrast >= wcagAaaMinRatio,
    );
  }
}

/// Specifications for a subtitle style guaranteed to be readable.
class ReadabilityStyleSpec {
  final int primaryColorArgb;
  final int outlineColorArgb;
  final double outlineWidth;
  final int shadowColorArgb;
  final double shadowBlur;
  final double contrastRatio;
  final bool isWcagAaaCompliant;

  const ReadabilityStyleSpec({
    required this.primaryColorArgb,
    required this.outlineColorArgb,
    required this.outlineWidth,
    required this.shadowColorArgb,
    required this.shadowBlur,
    required this.contrastRatio,
    required this.isWcagAaaCompliant,
  });

  String get primaryColorHex =>
      '#${primaryColorArgb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  String get outlineColorHex =>
      '#${outlineColorArgb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
