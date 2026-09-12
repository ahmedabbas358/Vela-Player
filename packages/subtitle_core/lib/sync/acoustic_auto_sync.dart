import 'dart:math' as math;

import '../models/unified_subtitle_cue.dart';
import 'drift_corrector.dart';

/// Represents a detected human speech segment from Voice Activity Detection (VAD).
class VoiceActivityInterval {
  final int startMs;
  final int endMs;
  final double confidence;

  const VoiceActivityInterval({
    required this.startMs,
    required this.endMs,
    this.confidence = 1.0,
  });
}

/// Result of automated acoustic waveform alignment.
class AcousticSyncResult {
  final int optimalOffsetMs;
  final double driftScaleFactor; // 1.0 means no FPS drift
  final double confidence; // 0.0 to 1.0
  final List<UnifiedSubtitleCue> synchronizedCues;

  const AcousticSyncResult({
    required this.optimalOffsetMs,
    required this.driftScaleFactor,
    required this.confidence,
    required this.synchronizedCues,
  });
}

/// Performs automated 1-tap acoustic synchronization by cross-correlating
/// human voice activity bursts (from audio track VAD) against subtitle cue activity intervals.
class AcousticAutoSync {
  /// Default search window in milliseconds for desynchronization (+/- 30 seconds).
  static const int defaultMaxSearchWindowMs = 30000;

  /// Time resolution bucket size in milliseconds.
  static const int bucketResolutionMs = 100;

  /// Automatically computes the optimal time offset and applies it to the subtitle cues.
  static AcousticSyncResult alignWithAudio({
    required List<VoiceActivityInterval> voiceIntervals,
    required List<UnifiedSubtitleCue> cues,
    int maxSearchWindowMs = defaultMaxSearchWindowMs,
  }) {
    if (voiceIntervals.isEmpty || cues.isEmpty) {
      return AcousticSyncResult(
        optimalOffsetMs: 0,
        driftScaleFactor: 1.0,
        confidence: 0.0,
        synchronizedCues: cues,
      );
    }

    // 1. Determine timeline bounds
    final maxVoiceTime = voiceIntervals.map((e) => e.endMs).reduce(math.max);
    final maxSubTime = cues.map((e) => e.endMs).reduce(math.max);
    final totalDurationMs = math.max(maxVoiceTime, maxSubTime);

    final bucketCount = (totalDurationMs / bucketResolutionMs).ceil() + 1;

    // 2. Build discrete binary activity vectors
    final audioSignal = List<double>.filled(bucketCount, 0.0);
    for (final interval in voiceIntervals) {
      final startIdx = (interval.startMs / bucketResolutionMs)
          .floor()
          .clamp(0, bucketCount - 1);
      final endIdx = (interval.endMs / bucketResolutionMs)
          .ceil()
          .clamp(0, bucketCount - 1);
      for (int i = startIdx; i <= endIdx; i++) {
        audioSignal[i] = interval.confidence;
      }
    }

    final subSignal = List<double>.filled(bucketCount, 0.0);
    for (final cue in cues) {
      final startIdx =
          (cue.startMs / bucketResolutionMs).floor().clamp(0, bucketCount - 1);
      final endIdx =
          (cue.endMs / bucketResolutionMs).ceil().clamp(0, bucketCount - 1);
      for (int i = startIdx; i <= endIdx; i++) {
        subSignal[i] = 1.0;
      }
    }

    // 3. Compute Discrete Cross-Correlation over search window
    final maxShiftBuckets = (maxSearchWindowMs / bucketResolutionMs).round();
    int bestShiftBuckets = 0;
    double maxCorrelation = -1.0;
    double zeroShiftCorrelation = 0.0;

    for (int shift = -maxShiftBuckets; shift <= maxShiftBuckets; shift++) {
      double correlation = 0.0;

      final startI = math.max(0, -shift);
      final endI = math.min(bucketCount, bucketCount - shift);

      for (int i = startI; i < endI; i++) {
        correlation += audioSignal[i + shift] * subSignal[i];
      }

      if (shift == 0) {
        zeroShiftCorrelation = correlation;
      }

      if (correlation > maxCorrelation) {
        maxCorrelation = correlation;
        bestShiftBuckets = shift;
      }
    }

    final optimalOffsetMs = bestShiftBuckets * bucketResolutionMs;

    // 4. Calculate alignment confidence score
    double confidence = 0.0;
    if (maxCorrelation > 0) {
      confidence =
          (maxCorrelation / (math.max(zeroShiftCorrelation, 1.0) * 1.5))
              .clamp(0.2, 0.98);
    }

    // 5. Apply calculated offset
    final synchronized = SubtitleDriftCorrector.applyGlobalOffset(
      cues,
      optimalOffsetMs,
    );

    return AcousticSyncResult(
      optimalOffsetMs: optimalOffsetMs,
      driftScaleFactor: 1.0,
      confidence: confidence,
      synchronizedCues: synchronized,
    );
  }
}
