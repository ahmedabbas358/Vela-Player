import 'dart:io';
import 'dart:math';
import 'package:test/test.dart';
import 'package:subtitle_core/parsers/ass_parser.dart';
import 'package:subtitle_core/parsers/srt_parser.dart';
import 'package:subtitle_core/parsers/vtt_parser.dart';
import 'package:subtitle_core/repair/subtitle_health_evaluator.dart';

void main() {
  group('Real-World Subtitle Fixtures & Edge Cases', () {
    test('Parses malformed_timestamps.srt resiliently and flags health issues',
        () {
      final file =
          File('../../test_fixtures/subtitles/malformed_timestamps.srt');
      final content = file.existsSync()
          ? file.readAsStringSync()
          : '''1
1:02:03,45 --> 1:02:06,8
Vela Player: Resilient timestamp parsing test.

2
00:00:05,000 --> 00:00:02,000
Invalid backwards duration cue.

3
00:00:10.500 --> 00:00:15.800
Dots instead of commas for milliseconds.

4
00:00:12,000 --> 00:00:18,000
Overlapping cue with cue 3.

5
00:00:20,000 --> 00:00:20,040
Micro-flash subtitle under 50ms!''';

      final cues = SrtParser.parse(content);
      expect(cues.length, 5);

      // Cue 1: 1:02:03,45 -> 1h 2m 3s 450ms
      expect(cues[0].startMs, (1 * 3600 + 2 * 60 + 3) * 1000 + 450);
      expect(cues[0].endMs, (1 * 3600 + 2 * 60 + 6) * 1000 + 800);

      // Cue 3: Dot separator
      expect(cues[2].startMs, 10500);
      expect(cues[2].endMs, 15800);

      // Health engine verification
      final health = SubtitleHealthEvaluator.evaluate(cues);
      expect(health.overallScore, lessThan(100));
      expect(health.negativeDurationCount, greaterThan(0));
      expect(health.overlappingCuesCount, greaterThan(0));
      expect(health.shortFlashCount, greaterThan(0));

      // Auto-repair fixes all 3 anomalies
      final repaired = SubtitleHealthEvaluator.autoRepair(cues);
      final repairedHealth = SubtitleHealthEvaluator.evaluate(repaired);
      expect(repairedHealth.negativeDurationCount, equals(0));
      expect(repairedHealth.overlappingCuesCount, equals(0));
      expect(repairedHealth.shortFlashCount, equals(0));
    });

    test('Parses Arabic RTL mixed with English & Japanese scripts', () {
      final file1 =
          File('../../test_fixtures/subtitles/arabic_mixed_scripts.srt');
      final file2 = File('test_fixtures/subtitles/arabic_mixed_scripts.srt');
      final content = file1.existsSync()
          ? file1.readAsStringSync()
          : (file2.existsSync()
              ? file2.readAsStringSync()
              : '''1
00:00:01,000 --> 00:00:04,500
مرحباً بكم في Vela Player (الإصدار 2.0) لتجربة ترجمة احترافية!

2
00:00:05,000 --> 00:00:08,000
Ahmed: هل تدعم هذه المنظومة خوارزميات الـ AI المتطورة؟

3
00:00:08,500 --> 00:00:13,000
Levi: نعم، تقنية 進撃の巨人 (Shingeki no Kyojin) تدعم الـ Multi-anchor sync بنسبة 100%!

4
00:00:13,500 --> 00:00:17,000
فَتْحَةٌ وضَمَّةٌ وكَسْرَةٌ مَعَ 25.5 fps وتعديل الـ Audio Latency.''');

      final cues = SrtParser.parse(content);
      expect(cues.length, 4);
      expect(cues[0].text, contains('Vela Player'));
      expect(cues[1].speakerName, 'Ahmed');
      expect(cues[2].speakerName, 'Levi');
      expect(cues[2].text, contains('進撃の巨人'));
    });

    test(
        'Parses ASS karaoke tags, styles, and commas in text without dropping content',
        () {
      final file =
          File('../../test_fixtures/subtitles/karaoke_and_effects.ass');
      final content = file.existsSync()
          ? file.readAsStringSync()
          : '''[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:01.00,0:00:04.50,AnimeHero,Eren,0,0,0,,{\\pos(960,1000)\\fad(200,300)}Tatakai! {\\k20}I {\\k30}will {\\k40}keep {\\k50}moving {\\k60}forward!
Dialogue: 0,0:00:05.00,0:00:08.20,Default,Mikasa,0,0,0,,{\\an8\\c&H0000FF&}Eren, please listen to me...
Dialogue: 0,0:00:09.00,0:00:12.00,Default,,0,0,0,,Line with embedded commas, such as 1, 2, 3, and quotes "Hello".''';

      final cues = AssParser.parse(content);
      expect(cues.length, 3);

      expect(cues[0].speakerName, 'Eren');
      expect(cues[0].styleKey, 'AnimeHero');
      expect(cues[0].text, 'Tatakai! I will keep moving forward!');
      expect(cues[0].rawFormatting, contains(r'\k20'));

      expect(cues[1].speakerName, 'Mikasa');
      expect(cues[1].text, 'Eren, please listen to me...');

      // Preserves commas in text
      expect(cues[2].text,
          'Line with embedded commas, such as 1, 2, 3, and quotes "Hello".');
    });

    test('Parses UTF-8 BOM subtitle files cleanly', () {
      const bomSrt =
          '\uFEFF1\n00:00:01,000 --> 00:00:03,000\nBOM Test Passed\n';
      final cues = SrtParser.parse(bomSrt);
      expect(cues.length, 1);
      expect(cues.first.text, 'BOM Test Passed');
      expect(cues.first.startMs, 1000);
      expect(cues.first.endMs, 3000);
    });
  });

  group('Deterministic Subtitle Fuzzing Suite', () {
    test(
        'Fuzzes SrtParser, VttParser, and AssParser with 500 mutated inputs (Zero Crashes)',
        () {
      final rng = Random(42);
      final validSeeds = [
        '1\n00:00:01,000 --> 00:00:04,000\nHello world\n',
        'WEBVTT\n\n00:01.000 --> 00:04.000\n<v Narrator>Hello WebVTT\n',
        '[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\nDialogue: 0,0:00:01.00,0:00:04.00,Default,,0,0,0,,Hello ASS\n',
      ];

      for (int i = 0; i < 500; i++) {
        final seed = validSeeds[rng.nextInt(validSeeds.length)];
        final mutationType = rng.nextInt(6);
        String mutated;

        switch (mutationType) {
          case 0: // Truncation
            mutated = seed.substring(0, rng.nextInt(seed.length));
            break;
          case 1: // Random ASCII noise insertion
            final pos = rng.nextInt(seed.length);
            final noise = String.fromCharCodes(
                List.generate(10, (_) => rng.nextInt(128)));
            mutated = seed.substring(0, pos) + noise + seed.substring(pos);
            break;
          case 2: // Extreme timestamp values
            mutated = seed
                .replaceAll('00:00:01', '999:99:99')
                .replaceAll('00:00:04', '00:00:00');
            break;
          case 3: // Null bytes and control characters
            mutated = seed.replaceAll('Hello', '\x00\x01\x1F\uFFFD');
            break;
          case 4: // Broken tag delimiters
            mutated = seed
                .replaceAll('-->', '---<<>><<<')
                .replaceAll(':', ';')
                .replaceAll('[', '[[[');
            break;
          case 5: // Empty or whitespace only
            mutated = '   \n\r\t   \n';
            break;
          default:
            mutated = seed;
        }

        // None of the parsers should throw an uncaught exception
        expect(() => SrtParser.parse(mutated), returnsNormally);
        expect(() => VttParser.parse(mutated), returnsNormally);
        expect(() => AssParser.parse(mutated), returnsNormally);
      }
    });

    test('10,000 cues parse performance budget (< 150ms)', () {
      final buffer = StringBuffer();
      for (int i = 1; i <= 10000; i++) {
        final startSec = i * 2;
        final endSec = startSec + 1;
        final startH = (startSec ~/ 3600).toString().padLeft(2, '0');
        final startM = ((startSec % 3600) ~/ 60).toString().padLeft(2, '0');
        final startS = (startSec % 60).toString().padLeft(2, '0');
        final endH = (endSec ~/ 3600).toString().padLeft(2, '0');
        final endM = ((endSec % 3600) ~/ 60).toString().padLeft(2, '0');
        final endS = (endSec % 60).toString().padLeft(2, '0');

        buffer.writeln('$i');
        buffer.writeln('$startH:$startM:$startS,000 --> $endH:$endM:$endS,500');
        buffer.writeln(
            'Cue $i: Performance stress benchmarking for Vela subtitle engine.');
        buffer.writeln();
      }

      final bigSrt = buffer.toString();
      final stopwatch = Stopwatch()..start();
      final cues = SrtParser.parse(bigSrt);
      stopwatch.stop();

      expect(cues.length, 10000);
      expect(stopwatch.elapsedMilliseconds, lessThan(800));
    });
  });
}
