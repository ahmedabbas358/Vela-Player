/// Enumerates the supported underlying playback engines in Vela Player.
enum PlaybackEngineType {
  /// AndroidX Media3 (1.11.0+) ExoPlayer engine - Primary on Android.
  media3,

  /// Apple AVPlayer / AVFoundation engine - Primary on iOS & macOS.
  avFoundation,

  /// libmpv engine - Advanced rendering, Hi10P (10-bit), custom shaders, advanced ASS.
  libmpv,

  /// LibVLC engine - Comprehensive codec and legacy container support.
  libvlc,

  /// Custom high-performance fallback engine.
  custom,
}

extension PlaybackEngineTypeExt on PlaybackEngineType {
  String get displayName {
    switch (this) {
      case PlaybackEngineType.media3:
        return 'AndroidX Media3 (1.11.0)';
      case PlaybackEngineType.avFoundation:
        return 'Apple AVFoundation';
      case PlaybackEngineType.libmpv:
        return 'libmpv Core';
      case PlaybackEngineType.libvlc:
        return 'LibVLC Engine';
      case PlaybackEngineType.custom:
        return 'Custom Engine';
    }
  }

  bool get supportsHdr10Plus =>
      this == PlaybackEngineType.media3 || this == PlaybackEngineType.libmpv;

  bool get supports10BitAnime =>
      this == PlaybackEngineType.libmpv || this == PlaybackEngineType.libvlc;

  bool get supportsDirectDtsPassthrough =>
      this == PlaybackEngineType.media3 || this == PlaybackEngineType.libvlc;
}
