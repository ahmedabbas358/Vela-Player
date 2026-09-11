import '../models/unified_subtitle_cue.dart';
import '../models/subtitle_health_report.dart';

/// Heuristic evaluation and auto-repair engine for subtitle tracks.
class SubtitleHealthEvaluator {
  static const double maxRecommendedCps = 21.0;
  static const int minReadableDurationMs = 400;

  /// Evaluates subtitle quality and computes an overall health score (0-100).
  static SubtitleHealthReport evaluate(List<UnifiedSubtitleCue> cues) {
    if (cues.isEmpty) {
      return const SubtitleHealthReport(
        overallScore: 100,
        totalCues: 0,
        overlappingCuesCount: 0,
        negativeDurationCount: 0,
        shortFlashCount: 0,
        excessiveSpeedCount: 0,
        brokenEncodingCount: 0,
        issuesSummary: [],
      );
    }

    int overlaps = 0;
    int negativeDurations = 0;
    int shortFlashes = 0;
    int excessiveSpeed = 0;
    int brokenEncodings = 0;
    final issues = <String>[];

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];

      // Check negative or zero duration
      if (cue.endMs <= cue.startMs) {
        negativeDurations++;
      } else if (cue.durationMs < minReadableDurationMs) {
        shortFlashes++;
      }

      // Check overlap with previous cue
      if (i > 0) {
        final prevCue = cues[i - 1];
        if (cue.startMs < prevCue.endMs) {
          overlaps++;
        }
      }

      // Check reading speed
      if (cue.readingSpeedCps > maxRecommendedCps) {
        excessiveSpeed++;
      }

      // Check for broken characters / replacement glyphs
      if (cue.text.contains('\uFFFD') || cue.text.contains('?')) {
        brokenEncodings++;
      }
    }

    // Deduct penalties
    int penalties = 0;
    if (overlaps > 0) {
      penalties += (overlaps * 3).clamp(5, 25);
      issues.add('$overlaps overlapping dialogue cues detected');
    }
    if (negativeDurations > 0) {
      penalties += (negativeDurations * 5).clamp(10, 30);
      issues.add('$negativeDurations cues with invalid/negative timestamps');
    }
    if (shortFlashes > 0) {
      penalties += (shortFlashes * 2).clamp(5, 15);
      issues.add('$shortFlashes cues flash too briefly (<400ms)');
    }
    if (excessiveSpeed > 0) {
      penalties += (excessiveSpeed * 2).clamp(5, 20);
      issues.add(
          '$excessiveSpeed cues exceed comfortable reading speed (>21 cps)');
    }
    if (brokenEncodings > 0) {
      penalties += (brokenEncodings * 5).clamp(10, 35);
      issues
          .add('$brokenEncodings cues contain broken text encoding artifacts');
    }

    final score = (100 - penalties).clamp(0, 100);

    return SubtitleHealthReport(
      overallScore: score,
      totalCues: cues.length,
      overlappingCuesCount: overlaps,
      negativeDurationCount: negativeDurations,
      shortFlashCount: shortFlashes,
      excessiveSpeedCount: excessiveSpeed,
      brokenEncodingCount: brokenEncodings,
      issuesSummary: issues,
    );
  }

  /// Automatically fixes common subtitle anomalies (overlaps, negative duration, micro flashes).
  static List<UnifiedSubtitleCue> autoRepair(List<UnifiedSubtitleCue> cues) {
    if (cues.isEmpty) return [];

    final repaired = <UnifiedSubtitleCue>[];

    for (int i = 0; i < cues.length; i++) {
      var cue = cues[i];

      // Fix negative or zero durations
      if (cue.endMs <= cue.startMs) {
        final calculatedDur = (cue.text.length * 65).clamp(1200, 5000);
        cue = cue.copyWith(endMs: cue.startMs + calculatedDur);
      }

      // Fix micro flashes (less than 400ms)
      if (cue.durationMs < minReadableDurationMs) {
        cue = cue.copyWith(endMs: cue.startMs + minReadableDurationMs);
      }

      // Fix overlaps with previous cue
      if (repaired.isNotEmpty) {
        final prevIndex = repaired.length - 1;
        final prev = repaired[prevIndex];
        if (cue.startMs < prev.endMs) {
          // Adjust previous cue to end 25ms before current starts
          final adjustedPrevEnd =
              (cue.startMs - 25).clamp(prev.startMs + 300, cue.startMs);
          repaired[prevIndex] = prev.copyWith(endMs: adjustedPrevEnd);
        }
      }

      repaired.add(cue);
    }

    return repaired;
  }
}
