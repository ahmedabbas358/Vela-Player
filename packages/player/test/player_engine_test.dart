import 'package:flutter_test/flutter_test.dart';
import 'package:player/player.dart';

void main() {
  group('SmartEngineSelector Tests', () {
    const selector = SmartEngineSelector();

    test('recommends libmpv for 10-bit Hi10P anime content', () {
      final rec = selector.selectOptimalEngine(
        filePathOrUrl: 'video.mkv',
        videoCodec: 'HEVC',
        bitDepth: 10,
        isAndroid: true,
      );

      expect(rec.engine, equals(PlaybackEngineType.libmpv));
      expect(rec.decoderMode, equals(DecoderMode.hwPlus));
      expect(rec.reason, contains('10-Bit Hi10P'));
    });

    test('recommends libmpv for complex ASS subtitles', () {
      final rec = selector.selectOptimalEngine(
        filePathOrUrl: 'anime_episode.mkv',
        hasAdvancedAssSubtitles: true,
        isAndroid: true,
      );

      expect(rec.engine, equals(PlaybackEngineType.libmpv));
      expect(rec.reason, contains('libass'));
    });

    test(
        'recommends Media3 with Audio Passthrough for DTS-HD MA surround audio on Android',
        () {
      final rec = selector.selectOptimalEngine(
        filePathOrUrl: 'movie.mkv',
        audioCodec: 'DTS-HD MA 5.1',
        isAndroid: true,
      );

      expect(rec.engine, equals(PlaybackEngineType.media3));
      expect(rec.supportsLosslessPassthrough, isTrue);
    });

    test('recommends LibVLC for legacy AVI/FLV/VC-1 containers', () {
      final rec = selector.selectOptimalEngine(
        filePathOrUrl: 'classic_film.avi',
        videoCodec: 'VC-1',
        isAndroid: true,
      );

      expect(rec.engine, equals(PlaybackEngineType.libvlc));
      expect(rec.decoderMode, equals(DecoderMode.sw));
    });

    test('recommends AVFoundation on iOS for standard HEVC 8-bit', () {
      final rec = selector.selectOptimalEngine(
        filePathOrUrl: 'trailer.mp4',
        videoCodec: 'HEVC',
        bitDepth: 8,
        isAndroid: false,
        isIos: true,
      );

      expect(rec.engine, equals(PlaybackEngineType.avFoundation));
      expect(rec.decoderMode, equals(DecoderMode.hw));
    });
  });

  group('AudioLabEngine Tests', () {
    test('calculates preamp gain correctly up to +12dB for 200% boost', () {
      expect(AudioLabEngine.calculatePreampGainDb(100.0), equals(0.0));
      expect(AudioLabEngine.calculatePreampGainDb(150.0), equals(6.0));
      expect(AudioLabEngine.calculatePreampGainDb(200.0), equals(12.0));
    });

    test('soft limiter saturates smoothly without digital clipping', () {
      final normal = AudioLabEngine.processSoftLimiter(0.5, 1.0);
      expect(normal, equals(0.5));

      final boostedHigh = AudioLabEngine.processSoftLimiter(0.9, 2.0);
      expect(boostedHigh, lessThanOrEqualTo(1.0));
      expect(boostedHigh, greaterThanOrEqualTo(-1.0));
    });

    test('calculates Night Mode DRC gain adjustments', () {
      // Quiet dialogue boosted
      expect(
          AudioLabEngine.calculateNightModeGainAdjustment(-30.0), equals(6.0));
      // Loud sounds attenuated
      expect(
          AudioLabEngine.calculateNightModeGainAdjustment(0.0), equals(-9.0));
      // Moderate sounds unchanged
      expect(
          AudioLabEngine.calculateNightModeGainAdjustment(-14.0), equals(0.0));
    });

    test('calculates ReplayGain EBU R128 adjustment accurately', () {
      // Track is too loud (-10 LUFS vs target -14 LUFS) -> -4dB reduction
      expect(
        AudioLabEngine.calculateReplayGainAdjustment(measuredTrackLufs: -10.0),
        equals(-4.0),
      );
      // Track is too quiet (-20 LUFS vs target -14 LUFS) -> +6dB boost
      expect(
        AudioLabEngine.calculateReplayGainAdjustment(measuredTrackLufs: -20.0),
        equals(6.0),
      );
    });
  });

  group('AudioProfile & VideoEnhancer Tests', () {
    test('verifies standard curated audio profiles exist', () {
      expect(AudioProfile.allProfiles.length, equals(5));
      expect(AudioProfile.anime.dialogueEnhancer, isTrue);
      expect(AudioProfile.movies.virtualizerPercent, greaterThan(0));
    });

    test(
        'VideoEnhancerConfig initializes with safe defaults and active debanding',
        () {
      const config = VideoEnhancerConfig();
      expect(config.debandingEnabled, isTrue);
      expect(config.thermalProtectionGuard, isTrue);
      expect(config.superResolutionEnabled, isFalse);
    });
  });
}
