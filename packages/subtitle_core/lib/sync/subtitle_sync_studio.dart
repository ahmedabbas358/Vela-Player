import '../models/unified_subtitle_cue.dart';
import 'drift_corrector.dart';

/// Supported standard video framerates for FPS drift timing conversion.
enum VideoFpsStandard {
  fps23976(23.976, '23.976 fps (Film / NTSC)'),
  fps24000(24.0, '24.0 fps (True Cinema)'),
  fps25000(25.0, '25.0 fps (PAL / European Broadcast)'),
  fps29970(29.970, '29.97 fps (NTSC Television)'),
  fps30000(30.0, '30.0 fps (Standard Web Video)'),
  fps60000(60.0, '60.0 fps (High Framerate)');

  final double rate;
  final String label;
  const VideoFpsStandard(this.rate, this.label);
}

/// Anchor point for multi-point nonlinear timeline synchronization.
class SyncAnchorPoint {
  final int sourceCueIndex;
  final int sourceTimestampMs;
  final int targetVideoTimestampMs;

  const SyncAnchorPoint({
    required this.sourceCueIndex,
    required this.sourceTimestampMs,
    required this.targetVideoTimestampMs,
  });

  int get offsetMs => targetVideoTimestampMs - sourceTimestampMs;
}

/// Subtitle Sync Studio: Multi-tier synchronization engine combining
/// Global Offset, FPS Linear Drift correction, and Multi-anchor calibration.
class SubtitleSyncStudio {
  /// 1. Apply global constant offset (shift all cues by deltaMs)
  static List<UnifiedSubtitleCue> applyGlobalOffset(
    List<UnifiedSubtitleCue> cues,
    int offsetMs,
  ) {
    return SubtitleDriftCorrector.applyGlobalOffset(cues, offsetMs);
  }

  /// 2. Convert subtitle timings between two standard framerates (e.g. 23.976 -> 25.0 FPS)
  static List<UnifiedSubtitleCue> convertFramerateDrift(
    List<UnifiedSubtitleCue> cues, {
    required VideoFpsStandard sourceFps,
    required VideoFpsStandard targetFps,
  }) {
    if (sourceFps == targetFps) return cues;

    // Time scaling factor: t_target = t_source * (sourceFps / targetFps)
    final ratio = sourceFps.rate / targetFps.rate;

    return cues.map((cue) {
      final newStart = (cue.startMs * ratio).round();
      final newEnd = (cue.endMs * ratio).round();
      return cue.copyWith(
        startMs: newStart > 0 ? newStart : 0,
        endMs: newEnd > newStart ? newEnd : newStart + 500,
      );
    }).toList();
  }

  /// 3. Multi-anchor linear interpolation
  /// Given two anchor points (e.g. anchor at start, anchor at end of movie),
  /// calculates exact slope `a` and intercept `b` to align all intermediate cues:
  /// t' = a * t + b
  static List<UnifiedSubtitleCue> calibrateMultiAnchor(
    List<UnifiedSubtitleCue> cues, {
    required SyncAnchorPoint anchor1,
    required SyncAnchorPoint anchor2,
  }) {
    final t1 = anchor1.sourceTimestampMs.toDouble();
    final t2 = anchor2.sourceTimestampMs.toDouble();
    final y1 = anchor1.targetVideoTimestampMs.toDouble();
    final y2 = anchor2.targetVideoTimestampMs.toDouble();

    if ((t2 - t1).abs() < 1000) {
      // Anchors too close to each other, fallback to average offset
      final avgOffset = ((anchor1.offsetMs + anchor2.offsetMs) / 2).round();
      return applyGlobalOffset(cues, avgOffset);
    }

    final slope = (y2 - y1) / (t2 - t1);
    final intercept = y1 - (slope * t1);

    return cues.map((cue) {
      final newStart = ((slope * cue.startMs) + intercept).round();
      final newEnd = ((slope * cue.endMs) + intercept).round();
      return cue.copyWith(
        startMs: newStart > 0 ? newStart : 0,
        endMs: newEnd > newStart ? newEnd : newStart + 500,
      );
    }).toList();
  }
}
