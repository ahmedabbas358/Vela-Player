import '../models/unified_subtitle_cue.dart';

/// Implements multi-point synchronization and progressive timeline drift correction.
class SubtitleDriftCorrector {
  /// Applies a uniform global offset (in milliseconds) across all cues.
  static List<UnifiedSubtitleCue> applyGlobalOffset(
    List<UnifiedSubtitleCue> cues,
    int offsetMs,
  ) {
    if (offsetMs == 0) return cues;
    return cues.map((cue) {
      final newStart = (cue.startMs + offsetMs).clamp(0, 0x7FFFFFFF);
      final newEnd = (cue.endMs + offsetMs).clamp(newStart + 100, 0x7FFFFFFF);
      return cue.copyWith(startMs: newStart, endMs: newEnd);
    }).toList();
  }

  /// Corrects progressive timeline drift using two anchor calibration points.
  /// 
  /// [t1Ms] and [offset1Ms]: First calibration point time and its desync offset.
  /// [t2Ms] and [offset2Ms]: Second calibration point time and its desync offset.
  static List<UnifiedSubtitleCue> applyDriftCorrection({
    required List<UnifiedSubtitleCue> cues,
    required int t1Ms,
    required int offset1Ms,
    required int t2Ms,
    required int offset2Ms,
  }) {
    if (t1Ms == t2Ms) {
      return applyGlobalOffset(cues, offset1Ms);
    }

    final double timeSpan = (t2Ms - t1Ms).toDouble();
    final double offsetDelta = (offset2Ms - offset1Ms).toDouble();

    return cues.map((cue) {
      // Calculate progressive linear offset for start and end
      final double progressStart = (cue.startMs - t1Ms) / timeSpan;
      final int startShift = (offset1Ms + (progressStart * offsetDelta)).round();

      final double progressEnd = (cue.endMs - t1Ms) / timeSpan;
      final int endShift = (offset1Ms + (progressEnd * offsetDelta)).round();

      final newStart = (cue.startMs + startShift).clamp(0, 0x7FFFFFFF);
      final newEnd = (cue.endMs + endShift).clamp(newStart + 200, 0x7FFFFFFF);

      return cue.copyWith(startMs: newStart, endMs: newEnd);
    }).toList();
  }

  /// Aligns the subtitle track between two matched anchors:
  /// Anchor 1: Subtitle time [subA1Ms] matches Video time [vidA1Ms]
  /// Anchor 2: Subtitle time [subA2Ms] matches Video time [vidA2Ms]
  static List<UnifiedSubtitleCue> applyAnchorSync({
    required List<UnifiedSubtitleCue> cues,
    required int subA1Ms,
    required int vidA1Ms,
    required int subA2Ms,
    required int vidA2Ms,
  }) {
    final offset1 = vidA1Ms - subA1Ms;
    final offset2 = vidA2Ms - subA2Ms;

    return applyDriftCorrection(
      cues: cues,
      t1Ms: subA1Ms,
      offset1Ms: offset1,
      t2Ms: subA2Ms,
      offset2Ms: offset2,
    );
  }
}
