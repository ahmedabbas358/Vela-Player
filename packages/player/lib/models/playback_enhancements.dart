/// Audio enhancement configuration including 200% preamp boost and night mode.
class AudioEnhancementSettings {
  /// Volume percentage from 0.0 to 200.0% (values above 100.0 trigger preamp software boost).
  final double volumePercent;

  /// Whether soft-limiting compressor is active to prevent clipping distortion when boosted.
  final bool enableSoftLimiter;

  /// Night mode dynamic range compression (boosts whispers, suppresses loud explosions).
  final bool enableNightMode;

  /// Audio offset delay relative to video in milliseconds (-5000 to +5000 ms).
  final int audioDelayMs;

  const AudioEnhancementSettings({
    this.volumePercent = 100.0,
    this.enableSoftLimiter = true,
    this.enableNightMode = false,
    this.audioDelayMs = 0,
  });

  bool get isBoosted => volumePercent > 100.0;

  AudioEnhancementSettings copyWith({
    double? volumePercent,
    bool? enableSoftLimiter,
    bool? enableNightMode,
    int? audioDelayMs,
  }) {
    return AudioEnhancementSettings(
      volumePercent: volumePercent ?? this.volumePercent,
      enableSoftLimiter: enableSoftLimiter ?? this.enableSoftLimiter,
      enableNightMode: enableNightMode ?? this.enableNightMode,
      audioDelayMs: audioDelayMs ?? this.audioDelayMs,
    );
  }
}

/// A-B Repeat loop state for continuous segment rehearsal and language learning.
class AbRepeatState {
  final Duration? pointA;
  final Duration? pointB;
  final bool isActive;

  const AbRepeatState({
    this.pointA,
    this.pointB,
    this.isActive = false,
  });

  bool get isReady => pointA != null && pointB != null && pointB! > pointA!;

  AbRepeatState copyWith({
    Duration? Function()? pointA,
    Duration? Function()? pointB,
    bool? isActive,
  }) {
    return AbRepeatState(
      pointA: pointA != null ? pointA() : this.pointA,
      pointB: pointB != null ? pointB() : this.pointB,
      isActive: isActive ?? this.isActive,
    );
  }
}
