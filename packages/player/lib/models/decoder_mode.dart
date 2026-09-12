/// Decoding engines available in Vela Player (matching & exceeding MX Player).
enum DecoderMode {
  /// Direct hardware acceleration via platform decoders (MediaCodec on Android, VideoToolbox on iOS).
  /// Ultra-low power consumption, supports 4K/8K 60/120fps and HDR10/Dolby Vision.
  hw,

  /// Hardware-accelerated decoding with custom GPU shader rendering and color grading.
  /// Allows real-time brightness, contrast, and saturation adjustments.
  hwPlus,

  /// High-performance C++ software decoding (libmpv / FFmpeg 7+).
  /// Capable of decoding 10-bit Hi10P anime, legacy AVI/WMV, and damaged streams.
  sw;

  String get labelAr {
    switch (this) {
      case DecoderMode.hw:
        return 'عتادي (HW)';
      case DecoderMode.hwPlus:
        return 'عتادي بلس (HW+)';
      case DecoderMode.sw:
        return 'برمجي (SW)';
    }
  }

  String get labelEn {
    switch (this) {
      case DecoderMode.hw:
        return 'Hardware (HW)';
      case DecoderMode.hwPlus:
        return 'Hardware+ (HW+)';
      case DecoderMode.sw:
        return 'Software (SW)';
    }
  }

  String get descriptionAr {
    switch (this) {
      case DecoderMode.hw:
        return 'أعلى كفاءة في استهلاك البطارية وتشغيل 4K/8K HDR بسلاسة.';
      case DecoderMode.hwPlus:
        return 'فك ترميز عتادي مع معالجة وتحسين جودة الألوان عبر الشيدرز.';
      case DecoderMode.sw:
        return 'فك تشفير ناعم يشغل جميع صيغ الأنمي القديمة والملفات النادرة.';
    }
  }
}
