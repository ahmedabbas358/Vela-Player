/// Bounding box Region of Interest (ROI) for burned-in subtitle detection.
class SubtitleRoi {
  final double topPercent; // e.g. 0.75 (bottom 25% of frame)
  final double bottomPercent; // e.g. 0.98
  final double leftPercent; // e.g. 0.05
  final double rightPercent; // e.g. 0.95

  const SubtitleRoi({
    this.topPercent = 0.75,
    this.bottomPercent = 0.98,
    this.leftPercent = 0.05,
    this.rightPercent = 0.95,
  });
}

/// Raw recognized text entry with timestamp from an OCR pass.
class OcrFrameDetection {
  final int timestampMs;
  final String detectedText;
  final double confidence;

  const OcrFrameDetection({
    required this.timestampMs,
    required this.detectedText,
    required this.confidence,
  });
}

/// Clustered subtitle cue produced by grouping consecutive matching OCR detections.
class ExtractedOcrCue {
  final int index;
  final int startMs;
  final int endMs;
  final String text;
  final double averageConfidence;

  const ExtractedOcrCue({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.text,
    required this.averageConfidence,
  });
}

/// Burned-In Subtitle OCR Engine:
/// Analyzes video streams with hardcoded subtitles, detects text in subtitle ROI,
/// and clusters frames into standard timed subtitle cues without touching the video.
class BurnedInSubtitleOcrEngine {
  /// Clusters sequential OCR frame detections into timed subtitle cues.
  /// If adjacent frames have high text similarity (Levenshtein / normalized equality),
  /// they are merged into one continuous cue.
  static List<ExtractedOcrCue> clusterDetections(
    List<OcrFrameDetection> detections, {
    int maxGapToleranceMs = 600,
    double similarityThreshold = 0.7,
  }) {
    if (detections.isEmpty) return [];

    final List<ExtractedOcrCue> cues = [];
    String currentText = detections[0].detectedText.trim();
    int currentStartMs = detections[0].timestampMs;
    int currentEndMs = currentStartMs + 500;
    double confidenceSum = detections[0].confidence;
    int frameCount = 1;

    for (int i = 1; i < detections.length; i++) {
      final det = detections[i];
      final text = det.detectedText.trim();
      final gap = det.timestampMs - currentEndMs;

      final similarity = _calculateSimilarity(currentText, text);

      if (similarity >= similarityThreshold && gap <= maxGapToleranceMs) {
        // Same subtitle line extended
        currentEndMs = det.timestampMs + 500;
        confidenceSum += det.confidence;
        frameCount++;
      } else {
        // Emit previous cue if not blank
        if (currentText.isNotEmpty) {
          cues.add(ExtractedOcrCue(
            index: cues.length + 1,
            startMs: currentStartMs,
            endMs: currentEndMs,
            text: currentText,
            averageConfidence: confidenceSum / frameCount,
          ));
        }

        // Start new cue
        currentText = text;
        currentStartMs = det.timestampMs;
        currentEndMs = currentStartMs + 500;
        confidenceSum = det.confidence;
        frameCount = 1;
      }
    }

    // Emit final cue
    if (currentText.isNotEmpty) {
      cues.add(ExtractedOcrCue(
        index: cues.length + 1,
        startMs: currentStartMs,
        endMs: currentEndMs,
        text: currentText,
        averageConfidence: confidenceSum / frameCount,
      ));
    }

    return cues;
  }

  /// Calculates string similarity between two consecutive OCR text reads.
  static double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Simple word overlap coefficient
    final words1 = s1.split(RegExp(r'\s+')).toSet();
    final words2 = s2.split(RegExp(r'\s+')).toSet();
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    if (union == 0) return 0.0;
    return intersection / union;
  }
}
