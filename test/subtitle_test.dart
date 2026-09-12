import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vela_player/core/subtitles/models/subtitle_style.dart';
import 'package:vela_player/core/subtitles/parsers/srt_parser.dart';
import 'package:vela_player/core/subtitles/parsers/vtt_parser.dart';
import 'package:vela_player/core/subtitles/subtitle_manager.dart';

void main() {
  group('Subtitle Parsers Tests', () {
    test('SrtParser parses valid SRT cues with timestamps and speakers', () {
      const srtData = '''1
00:00:01,500 --> 00:00:04,000
[مذيع]: مرحباً بكم في نشرة الأخبار.

2
00:00:05,200 --> 00:00:08,750
اليوم نقدم لكم أفضل مشغل ترجمة.
''';

      final cues = SrtParser.parse(srtData);
      expect(cues.length, equals(2));

      expect(
        cues[0].startTime,
        equals(const Duration(seconds: 1, milliseconds: 500)),
      );
      expect(cues[0].endTime, equals(const Duration(seconds: 4)));
      expect(cues[0].speaker, equals('مذيع'));
      expect(cues[0].text, equals('مرحباً بكم في نشرة الأخبار.'));

      expect(
        cues[1].startTime,
        equals(const Duration(seconds: 5, milliseconds: 200)),
      );
      expect(
        cues[1].endTime,
        equals(const Duration(seconds: 8, milliseconds: 750)),
      );
      expect(cues[1].speaker, isNull);
      expect(cues[1].text, equals('اليوم نقدم لكم أفضل مشغل ترجمة.'));
    });

    test('VttParser parses WebVTT format', () {
      const vttData = '''WEBVTT - Demo file

1
00:01.000 --> 00:03.500
<v Alice>Hello from WebVTT!</v>

2
00:04.000 --> 00:07.000
Enjoying the smart video player.
''';

      final cues = VttParser.parse(vttData);
      expect(cues.length, equals(2));

      expect(cues[0].startTime, equals(const Duration(seconds: 1)));
      expect(
        cues[0].endTime,
        equals(const Duration(seconds: 3, milliseconds: 500)),
      );
      expect(cues[0].speaker, equals('Alice'));
      expect(cues[0].text, equals('Hello from WebVTT!'));
    });
  });

  group('SubtitleNotifier Management & Timeline Sync', () {
    test('Active cue lookup and offset delay adjustment', () {
      const sample = '''1
00:00:02,000 --> 00:00:05,000
Cue One

2
00:00:06,000 --> 00:00:09,000
Cue Two
''';

      final notifier = SubtitleNotifier();
      notifier.loadContent(sample, fileName: 'test.srt');

      // Before cue 1
      notifier.updatePosition(const Duration(seconds: 1));
      expect(notifier.state.activeCue, isNull);

      // In cue 1
      notifier.updatePosition(const Duration(seconds: 3));
      expect(notifier.state.activeCue?.text, equals('Cue One'));

      // Between cue 1 and 2
      notifier.updatePosition(const Duration(milliseconds: 5500));
      expect(notifier.state.activeCue, isNull);

      // In cue 2
      notifier.updatePosition(const Duration(seconds: 7));
      expect(notifier.state.activeCue?.text, equals('Cue Two'));

      // Adjust offset by +1.5s (+1500ms delay)
      notifier.adjustOffset(const Duration(milliseconds: 1500));
      // At 7.0s - 1.5s = 5.5s (between cues)
      notifier.updatePosition(const Duration(seconds: 7));
      expect(notifier.state.activeCue, isNull);

      // At 8.0s - 1.5s = 6.5s (inside Cue Two)
      notifier.updatePosition(const Duration(seconds: 8));
      expect(notifier.state.activeCue?.text, equals('Cue Two'));
    });

    test('SubtitleStyle preset application', () {
      final notifier = SubtitleNotifier();
      expect(
        notifier.state.style.textColor,
        equals(SubtitleStyle.classicWhite.textColor),
      );

      notifier.updateStyle(SubtitleStyle.animeYellow);
      expect(notifier.state.style.fontFamily, equals('Tajawal'));
      expect(notifier.state.style.textColor, equals(const Color(0xFFFFD54F)));
    });
  });
}
