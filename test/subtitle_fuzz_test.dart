import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_core/parsers/ass_parser.dart';
import 'package:subtitle_core/parsers/srt_parser.dart';
import 'package:subtitle_core/parsers/vtt_parser.dart';
import 'package:subtitle_core/repair/subtitle_health_evaluator.dart';

void main() {
  group('Vela Player Root Subtitle Fixture & Fuzz Suite', () {
    test(
      'SRT parser handles real-world edge cases with 0 unhandled exceptions',
      () {
        const edgeCaseSrt = '''
\uFEFF1
01:02:03,45 --> 01:02:06,8
Vela Subtitle: Resilient parser.

2
00:00:10.500 --> 00:00:15.800
Dot millisecond separator.

3
00:00:20,000 --> 00:00:20,040
Micro flash.
''';

        final cues = SrtParser.parse(edgeCaseSrt);
        expect(cues.length, 3);
        expect(cues[0].startMs, (3600 + 2 * 60 + 3) * 1000 + 450);

        final health = SubtitleHealthEvaluator.evaluate(cues);
        expect(health.shortFlashCount, greaterThan(0));

        final repaired = SubtitleHealthEvaluator.autoRepair(cues);
        final repairedHealth = SubtitleHealthEvaluator.evaluate(repaired);
        expect(repairedHealth.shortFlashCount, equals(0));
      },
    );

    test('Parser fuzzing smoke test with 100 randomized mutated inputs', () {
      final rng = Random(1337);
      final seeds = [
        '1\n00:00:01,000 --> 00:00:04,000\nFuzz Seed\n',
        'WEBVTT\n\n00:01.000 --> 00:04.000\n<v Narrator>Test\n',
        '[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\nDialogue: 0,0:00:01.00,0:00:04.00,Default,,0,0,0,,ASS Tag\n',
      ];

      for (int i = 0; i < 100; i++) {
        final seed = seeds[rng.nextInt(seeds.length)];
        final cut = rng.nextInt(seed.length);
        final mutated =
            seed.substring(0, cut) +
            String.fromCharCodes(List.generate(5, (_) => rng.nextInt(128))) +
            seed.substring(cut);

        expect(() => SrtParser.parse(mutated), returnsNormally);
        expect(() => VttParser.parse(mutated), returnsNormally);
        expect(() => AssParser.parse(mutated), returnsNormally);
      }
    });
  });
}
