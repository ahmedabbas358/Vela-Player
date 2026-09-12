import 'package:test/test.dart';
import 'package:subtitle_core/subtitle_core.dart';

void main() {
  group('SrtParser', () {
    test('parses standard SRT with timestamps and speakers correctly', () {
      const srt = '''
1
00:01:20,000 --> 00:01:23,500
Levi: We need to leave.

2
00:01:24,000 --> 00:01:26,000
Right behind you.
''';
      final cues = SrtParser.parse(srt);
      expect(cues.length, equals(2));
      expect(cues[0].startMs, equals(80000));
      expect(cues[0].endMs, equals(83500));
      expect(cues[0].speakerName, equals('Levi'));
      expect(cues[0].text, equals('We need to leave.'));
      expect(cues[1].speakerName, isNull);
      expect(cues[1].text, equals('Right behind you.'));
    });
  });

  group('AssParser', () {
    test('parses ASS Dialogue events and cleans override tags', () {
      const ass = '''
[Script Info]
Title: Sample

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:01:20.50,0:01:23.00,Default,Eren,0,0,0,,{\\pos(192,240)}Hear me!\\NAll subjects of Ymir.
''';
      final cues = AssParser.parse(ass);
      expect(cues.length, equals(1));
      expect(cues[0].startMs, equals(80500));
      expect(cues[0].endMs, equals(83000));
      expect(cues[0].speakerName, equals('Eren'));
      expect(cues[0].text, equals('Hear me!\nAll subjects of Ymir.'));
    });
  });

  group('SubtitleHealthEvaluator', () {
    test('detects overlapping cues and calculates health score', () {
      final cues = [
        const UnifiedSubtitleCue(
            id: '1', index: 1, startMs: 1000, endMs: 3000, text: 'First line'),
        const UnifiedSubtitleCue(
            id: '2',
            index: 2,
            startMs: 2500,
            endMs: 4000,
            text: 'Overlapping line'),
      ];

      final report = SubtitleHealthEvaluator.evaluate(cues);
      expect(report.overlappingCuesCount, equals(1));
      expect(report.overallScore, lessThan(100));

      final repaired = SubtitleHealthEvaluator.autoRepair(cues);
      expect(repaired[0].endMs, lessThanOrEqualTo(repaired[1].startMs));
    });
  });

  group('SubtitleDriftCorrector', () {
    test('applies global offset and drift interpolation', () {
      final cues = [
        const UnifiedSubtitleCue(
            id: '1', index: 1, startMs: 10000, endMs: 12000, text: 'Hello'),
        const UnifiedSubtitleCue(
            id: '2', index: 2, startMs: 50000, endMs: 52000, text: 'World'),
      ];

      final shifted = SubtitleDriftCorrector.applyGlobalOffset(cues, 1500);
      expect(shifted[0].startMs, equals(11500));
      expect(shifted[0].endMs, equals(13500));

      final drifted = SubtitleDriftCorrector.applyDriftCorrection(
        cues: cues,
        t1Ms: 10000,
        offset1Ms: 1000,
        t2Ms: 50000,
        offset2Ms: 3000,
      );
      expect(drifted[0].startMs, equals(11000));
      expect(drifted[1].startMs, equals(53000));
    });
  });

  group('AcousticAutoSync', () {
    test('automatically detects delayed speech and aligns subtitle cues', () {
      // Subtitle cue starts at 1000ms
      final cues = [
        const UnifiedSubtitleCue(
          id: 'cue_1',
          index: 1,
          startMs: 1000,
          endMs: 3000,
          text: 'Voice speech here',
        ),
      ];

      // Audio voice activity actually occurs at 2500ms (1500ms delay!)
      final voiceIntervals = [
        const VoiceActivityInterval(
          startMs: 2500,
          endMs: 4500,
          confidence: 0.95,
        ),
      ];

      final result = AcousticAutoSync.alignWithAudio(
        voiceIntervals: voiceIntervals,
        cues: cues,
      );

      // Should find the 1500ms offset
      expect(result.optimalOffsetMs, equals(1500));
      expect(result.confidence, greaterThan(0.5));
      expect(result.synchronizedCues[0].startMs, equals(2500));
      expect(result.synchronizedCues[0].endMs, equals(4500));
    });
  });
}

