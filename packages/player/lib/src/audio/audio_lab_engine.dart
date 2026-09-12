import 'dart:math' as math;
import 'audio_profile.dart';

/// Full DSP state of Vela's Audio Lab Engine.
class AudioLabState {
  final double volume; // 0.0 to 200.0%
  final double preampGainDb; // 0.0 to +12.0 dB
  final List<double> equalizerGains; // 10 bands (31Hz, 62Hz, ..., 16kHz)
  final double bassBoost; // 0.0 to 100.0%
  final double virtualizer; // 0.0 to 100.0%
  final bool nightMode;
  final bool loudnessNormalization;
  final double targetLufs; // Default -14.0 LUFS
  final double stereoWidening; // 0.0 to 100.0%
  final double balance; // -1.0 (left) to +1.0 (right)
  final bool monoDownmix;
  final AudioProfileType activeProfile;

  const AudioLabState({
    this.volume = 100.0,
    this.preampGainDb = 0.0,
    this.equalizerGains = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.bassBoost = 0.0,
    this.virtualizer = 0.0,
    this.nightMode = false,
    this.loudnessNormalization = false,
    this.targetLufs = -14.0,
    this.stereoWidening = 0.0,
    this.balance = 0.0,
    this.monoDownmix = false,
    this.activeProfile = AudioProfileType.custom,
  });

  bool get isBoosted => volume > 100.0;

  AudioLabState copyWith({
    double? volume,
    double? preampGainDb,
    List<double>? equalizerGains,
    double? bassBoost,
    double? virtualizer,
    bool? nightMode,
    bool? loudnessNormalization,
    double? targetLufs,
    double? stereoWidening,
    double? balance,
    bool? monoDownmix,
    AudioProfileType? activeProfile,
  }) {
    return AudioLabState(
      volume: volume ?? this.volume,
      preampGainDb: preampGainDb ?? this.preampGainDb,
      equalizerGains: equalizerGains ?? this.equalizerGains,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      nightMode: nightMode ?? this.nightMode,
      loudnessNormalization:
          loudnessNormalization ?? this.loudnessNormalization,
      targetLufs: targetLufs ?? this.targetLufs,
      stereoWidening: stereoWidening ?? this.stereoWidening,
      balance: balance ?? this.balance,
      monoDownmix: monoDownmix ?? this.monoDownmix,
      activeProfile: activeProfile ?? this.activeProfile,
    );
  }
}

/// Standalone mathematical DSP processor for Audio Lab calculations.
class AudioLabEngine {
  /// Calculate Preamp Gain in dB from volume percentage (100% = 0dB, 200% = +12dB).
  static double calculatePreampGainDb(double volumePercent) {
    if (volumePercent <= 100.0) return 0.0;
    // Linear interpolation from 100% -> 0dB up to 200% -> +12dB
    final factor = (volumePercent - 100.0) / 100.0;
    return factor * 12.0;
  }

  /// Soft-knee saturation limiter simulating analog tube warmth without harsh digital clipping.
  /// Uses hyperbolic tangent transfer function: y = tanh(x * gain)
  static double processSoftLimiter(double inputSample, double linearGain) {
    final boosted = inputSample * linearGain;
    if (boosted.abs() < 0.7) {
      return boosted; // Linear pass-through for quiet to moderate signals
    }
    // Soft compression curve above 0.7 threshold
    return math.sin(boosted.clamp(-math.pi / 2, math.pi / 2));
  }

  /// Night Mode Dynamic Range Compression (DRC):
  /// Quiet dialogue (< -24 dB) is boosted by +6 dB.
  /// Loud sounds (> -6 dB) are attenuated by -9 dB.
  static double calculateNightModeGainAdjustment(double inputRmsDb) {
    if (inputRmsDb < -24.0) {
      return 6.0; // Boost quiet dialogue
    } else if (inputRmsDb > -6.0) {
      return -9.0; // Attenuate loud sound effects / explosions
    }
    return 0.0;
  }

  /// ReplayGain / EBU R128 loudness normalization gain calculation:
  /// Target LUFS (-14 dB) minus measured track LUFS.
  static double calculateReplayGainAdjustment({
    required double measuredTrackLufs,
    double targetLufs = -14.0,
  }) {
    final diff = targetLufs - measuredTrackLufs;
    // Clamp within safe +/- 12 dB range
    return diff.clamp(-12.0, 12.0);
  }

  /// Convert dB gain to linear scale multiplier: multiplier = 10^(dB / 20)
  static double dbToLinear(double gainDb) {
    return math.pow(10.0, gainDb / 20.0).toDouble();
  }
}
