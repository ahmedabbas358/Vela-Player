import 'playback_engine_type.dart';
import '../../models/decoder_mode.dart';

/// Engine recommendation output with clear architectural justification.
class EngineRecommendation {
  final PlaybackEngineType engine;
  final DecoderMode decoderMode;
  final String reason;
  final bool requiresHdrToneMapping;
  final bool supportsLosslessPassthrough;

  const EngineRecommendation({
    required this.engine,
    required this.decoderMode,
    required this.reason,
    this.requiresHdrToneMapping = false,
    this.supportsLosslessPassthrough = false,
  });
}

/// Smart Engine Selector: Dynamically inspects media container, video codec,
/// bit-depth, audio track format, and subtitle complexity to choose the optimal
/// playback engine and decoder without user friction.
class SmartEngineSelector {
  const SmartEngineSelector();

  EngineRecommendation selectOptimalEngine({
    required String filePathOrUrl,
    String? containerExtension,
    String? videoCodec,
    int bitDepth = 8,
    String? audioCodec,
    bool hasAdvancedAssSubtitles = false,
    bool isAndroid = true,
    bool isIos = false,
    bool isDisplayHdrCapable = true,
  }) {
    final ext =
        (containerExtension ?? _extractExtension(filePathOrUrl)).toLowerCase();
    final vCodec = (videoCodec ?? '').toLowerCase();
    final aCodec = (audioCodec ?? '').toLowerCase();

    // 1. Anime with 10-bit Hi10P or complex styled ASS subtitles:
    // Route to libmpv for pixel-perfect libass rendering and 10-bit precision.
    if (bitDepth > 8 || hasAdvancedAssSubtitles) {
      return EngineRecommendation(
        engine: PlaybackEngineType.libmpv,
        decoderMode: bitDepth > 8 ? DecoderMode.hwPlus : DecoderMode.hw,
        reason: hasAdvancedAssSubtitles
            ? 'تم اختيار libmpv لتشغيل ترجمات ASS التفاعلية المتقدمة عبر libass بدقة متناهية.'
            : 'تم اختيار libmpv لدعم ترميز 10-Bit Hi10P بدون banding أو تشويه لوني.',
        requiresHdrToneMapping: !isDisplayHdrCapable,
        supportsLosslessPassthrough: true,
      );
    }

    // 2. DTS-HD / Dolby TrueHD / Surround Audio passthrough:
    if (aCodec.contains('dts') ||
        aCodec.contains('truehd') ||
        aCodec.contains('e-ac3')) {
      if (isAndroid) {
        return const EngineRecommendation(
          engine: PlaybackEngineType.media3,
          decoderMode: DecoderMode.hw,
          reason:
              'تم اختيار Media3 مع التمرير المباشر للصوت (Audio Passthrough) إلى المكبر الخارجي.',
          supportsLosslessPassthrough: true,
        );
      }
    }

    // 3. Rare or legacy containers (AVI, FLV, RealVideo, VC-1, MPEG-2 TS):
    if (ext == 'avi' ||
        ext == 'flv' ||
        vCodec.contains('vc-1') ||
        vCodec.contains('mpeg2')) {
      return const EngineRecommendation(
        engine: PlaybackEngineType.libvlc,
        decoderMode: DecoderMode.sw,
        reason:
            'تم تفعيل LibVLC كأقوى محرك توافقي للصيغ النادرة والترميزات التراثية القديمة.',
      );
    }

    // 4. Primary Modern Path (H.264, HEVC 8-bit, AV1, VP9 in MKV/MP4/WebM):
    if (isIos) {
      return EngineRecommendation(
        engine: PlaybackEngineType.avFoundation,
        decoderMode: DecoderMode.hw,
        reason:
            'تم اختيار Apple AVFoundation للأداء الأقصى وتوفير استهلاك البطارية على iOS.',
        requiresHdrToneMapping: !isDisplayHdrCapable,
      );
    }

    // Default Android path: AndroidX Media3 1.11.0
    return EngineRecommendation(
      engine: PlaybackEngineType.media3,
      decoderMode: DecoderMode.hw,
      reason:
          'تم اختيار AndroidX Media3 (1.11.0) مع تسريع عتادي كامل (Hardware Decoding).',
      requiresHdrToneMapping: !isDisplayHdrCapable,
      supportsLosslessPassthrough: true,
    );
  }

  static String _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return '';
    return path.substring(dotIndex + 1);
  }
}
