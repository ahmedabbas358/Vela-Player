/// GPU / AI Video Enhancement & Super Resolution Configuration in Vela Player.
class VideoEnhancerConfig {
  /// AI / GPU Super Resolution Upscaling (e.g. 480p / 720p -> 1080p / 4K)
  final bool superResolutionEnabled;

  /// Super resolution upscale factor (1.0x, 1.5x, 2.0x)
  final double upscaleMultiplier;

  /// Adaptive unsharp masking / edge crispness (0.0 to 1.0)
  final double sharpenLevel;

  /// GPU debanding filter to eliminate color banding artifacts in anime skies & gradients
  final bool debandingEnabled;

  /// Spatial / temporal noise reduction (0.0 to 1.0)
  final double denoiseLevel;

  /// Perceptual color saturation & vibrancy boost
  final bool chromaEnhancement;

  /// Tone-mapping to gracefully render HDR10 / HDR10+ / Dolby Vision on SDR displays
  final bool hdrToSdrToneMapping;

  /// Active thermal guard: throttles down expensive shaders if device reaches > 42°C
  final bool thermalProtectionGuard;

  const VideoEnhancerConfig({
    this.superResolutionEnabled = false,
    this.upscaleMultiplier = 1.0,
    this.sharpenLevel = 0.0,
    this.debandingEnabled = true, // Safe and lightweight on modern GPUs
    this.denoiseLevel = 0.0,
    this.chromaEnhancement = false,
    this.hdrToSdrToneMapping = true,
    this.thermalProtectionGuard = true,
  });

  VideoEnhancerConfig copyWith({
    bool? superResolutionEnabled,
    double? upscaleMultiplier,
    double? sharpenLevel,
    bool? debandingEnabled,
    double? denoiseLevel,
    bool? chromaEnhancement,
    bool? hdrToSdrToneMapping,
    bool? thermalProtectionGuard,
  }) {
    return VideoEnhancerConfig(
      superResolutionEnabled:
          superResolutionEnabled ?? this.superResolutionEnabled,
      upscaleMultiplier: upscaleMultiplier ?? this.upscaleMultiplier,
      sharpenLevel: sharpenLevel ?? this.sharpenLevel,
      debandingEnabled: debandingEnabled ?? this.debandingEnabled,
      denoiseLevel: denoiseLevel ?? this.denoiseLevel,
      chromaEnhancement: chromaEnhancement ?? this.chromaEnhancement,
      hdrToSdrToneMapping: hdrToSdrToneMapping ?? this.hdrToSdrToneMapping,
      thermalProtectionGuard:
          thermalProtectionGuard ?? this.thermalProtectionGuard,
    );
  }

  Map<String, dynamic> toJson() => {
        'superResolutionEnabled': superResolutionEnabled,
        'upscaleMultiplier': upscaleMultiplier,
        'sharpenLevel': sharpenLevel,
        'debandingEnabled': debandingEnabled,
        'denoiseLevel': denoiseLevel,
        'chromaEnhancement': chromaEnhancement,
        'hdrToSdrToneMapping': hdrToSdrToneMapping,
        'thermalProtectionGuard': thermalProtectionGuard,
      };
}
