import 'dart:math' as math;

import '../models/character_palette.dart';
import 'readability_guard.dart';

/// 3D Point in CIE-L*a*b* perceptually uniform color space.
class LabColor {
  final double l; // 0 to 100
  final double a; // -128 to +127
  final double b; // -128 to +127

  const LabColor(this.l, this.a, this.b);

  double distanceTo(LabColor other) {
    final dl = l - other.l;
    final da = a - other.a;
    final db = b - other.b;
    return math.sqrt(dl * dl + da * da + db * db);
  }

  /// Converts RGB (0-255) to CIE-L*a*b*.
  factory LabColor.fromRGB(int r, int g, int b) {
    // 1. Convert to linear sRGB
    double toLinear(int c) {
      final v = c / 255.0;
      return v > 0.04045
          ? math.pow((v + 0.055) / 1.055, 2.4).toDouble()
          : v / 12.92;
    }

    final lr = toLinear(r);
    final lg = toLinear(g);
    final lb = toLinear(b);

    // 2. Convert to CIE-XYZ (D65 Illuminant)
    final x = (lr * 0.4124564 + lg * 0.3575761 + lb * 0.1804375) / 0.95047;
    final y = (lr * 0.2126729 + lg * 0.7151522 + lb * 0.0721750) / 1.00000;
    final z = (lr * 0.0193339 + lg * 0.1191920 + lb * 0.9503041) / 1.08883;

    double f(double t) {
      return t > 0.008856
          ? math.pow(t, 1.0 / 3.0).toDouble()
          : (7.787 * t) + (16.0 / 116.0);
    }

    final fx = f(x);
    final fy = f(y);
    final fz = f(z);

    final l = (116.0 * fy) - 16.0;
    final a = 500.0 * (fx - fy);
    final bVal = 200.0 * (fy - fz);

    return LabColor(l, a, bVal);
  }

  /// Converts CIE-L*a*b* back to ARGB integer.
  int toArgb() {
    final fy = (l + 16.0) / 116.0;
    final fx = (a / 500.0) + fy;
    final fz = fy - (b / 200.0);

    double fInv(double t) {
      return t > 0.206893
          ? math.pow(t, 3.0).toDouble()
          : (t - 16.0 / 116.0) / 7.787;
    }

    final x = fInv(fx) * 0.95047;
    final y = fInv(fy) * 1.00000;
    final z = fInv(fz) * 1.08883;

    // Convert XYZ to linear RGB
    final lr = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
    final lg = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
    final lb = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;

    int toGamma(double v) {
      final clamped = v.clamp(0.0, 1.0);
      final g = clamped > 0.0031308
          ? (1.055 * math.pow(clamped, 1.0 / 2.4) - 0.055)
          : (12.92 * clamped);
      return (g * 255.0).round().clamp(0, 255);
    }

    final redInt = toGamma(lr);
    final greenInt = toGamma(lg);
    final blueInt = toGamma(lb);

    return 0xFF000000 | (redInt << 16) | (greenInt << 8) | blueInt;
  }

}

/// Advanced visual color extraction engine for character hair and eye palettes.
/// Operates on segmented image masks using K-Means (k=3) clustering in CIE-L*a*b* space.
class CharacterColorExtractor {
  /// Extracts the dominant pigment color from a set of RGB pixels, ignoring
  /// specular reflections (highlights) and dark shadows.
  static int extractDominantColor(List<int> argbPixels, {int k = 3}) {
    if (argbPixels.isEmpty) {
      return 0xFFFFFFFF; // Fallback to clean white
    }

    // Convert valid pixels to CIE-L*a*b* (filtering extreme highlights and deep shadows)
    final labPoints = <LabColor>[];
    for (final pixel in argbPixels) {
      final r = (pixel >> 16) & 0xFF;
      final g = (pixel >> 8) & 0xFF;
      final b = pixel & 0xFF;

      final lab = LabColor.fromRGB(r, g, b);
      // Filter out pure specular white shine (L > 96) and extreme deep shadows (L < 8)
      if (lab.l >= 8.0 && lab.l <= 96.0) {
        labPoints.add(lab);
      }
    }

    if (labPoints.isEmpty) {
      return argbPixels.first;
    }

    // Run K-Means clustering (k=3) to find the primary pigment cluster
    final clusters = _runKMeans(labPoints, k: math.min(k, labPoints.length));

    // Select the largest cluster centroid
    clusters.sort((a, b) => b.members.length.compareTo(a.members.length));
    final dominantCentroid = clusters.first.centroid;

    return dominantCentroid.toArgb();
  }

  /// Creates a finalized, WCAG-AAA validated character profile from detected hair and eye pixels.
  static CharacterProfile createCharacterProfile({
    required String characterId,
    required String characterName,
    String? gender,
    required List<int> hairPixels,
    required List<int> eyePixels,
    double confidence = 0.95,
  }) {
    final dominantHairArgb = extractDominantColor(hairPixels);
    final dominantEyeArgb = extractDominantColor(eyePixels);

    final hairHex = _toHex(dominantHairArgb);
    final eyeHex = _toHex(dominantEyeArgb);

    // Enforce Readability Guard on hair color (default choice for character subtitles)
    final readableStyle = ReadabilityGuard.enforceReadability(
      candidateColorArgb: dominantHairArgb,
    );

    return CharacterProfile(
      characterId: characterId,
      name: characterName,
      gender: gender,
      hairColorHex: hairHex,
      eyeColorHex: eyeHex,
      assignedSubtitleColorHex: readableStyle.primaryColorHex,
      confidence: confidence,
    );
  }

  static String _toHex(int argb) {
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static List<_KMeansCluster> _runKMeans(List<LabColor> points, {int k = 3}) {
    final random = math.Random(42);
    final centroids = <LabColor>[];

    // Initialize centroids
    for (int i = 0; i < k; i++) {
      centroids.add(points[random.nextInt(points.length)]);
    }

    List<_KMeansCluster> clusters = [];

    // Run 8 iterations of Lloyd's algorithm
    for (int iter = 0; iter < 8; iter++) {
      clusters = List.generate(k, (i) => _KMeansCluster(centroids[i]));

      // Assign points to nearest centroid
      for (final p in points) {
        int nearestIdx = 0;
        double minDist = double.infinity;

        for (int i = 0; i < k; i++) {
          final dist = p.distanceTo(centroids[i]);
          if (dist < minDist) {
            minDist = dist;
            nearestIdx = i;
          }
        }
        clusters[nearestIdx].members.add(p);
      }

      // Recompute centroids
      for (int i = 0; i < k; i++) {
        if (clusters[i].members.isNotEmpty) {
          double sumL = 0;
          double sumA = 0;
          double sumB = 0;
          for (final m in clusters[i].members) {
            sumL += m.l;
            sumA += m.a;
            sumB += m.b;
          }
          final count = clusters[i].members.length;
          centroids[i] = LabColor(sumL / count, sumA / count, sumB / count);
          clusters[i] = _KMeansCluster(centroids[i], clusters[i].members);
        }
      }
    }

    return clusters;
  }
}

class _KMeansCluster {
  final LabColor centroid;
  final List<LabColor> members;

  _KMeansCluster(this.centroid, [List<LabColor>? members])
      : members = members ?? [];
}
