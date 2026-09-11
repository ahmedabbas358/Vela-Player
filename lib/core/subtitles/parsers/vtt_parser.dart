import '../models/subtitle_cue.dart';

class VttParser {
  /// Parse raw WebVTT text content into a list of [SubtitleCue]
  static List<SubtitleCue> parse(String content) {
    final List<SubtitleCue> cues = [];
    if (content.trim().isEmpty) return cues;

    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n\s*\n'));

    int cueIndex = 1;

    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      // Skip WEBVTT header block
      if (lines[0].toUpperCase().startsWith('WEBVTT') ||
          lines[0].startsWith('NOTE')) {
        continue;
      }

      int timeLineIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          timeLineIndex = i;
          break;
        }
      }

      if (timeLineIndex == -1 || timeLineIndex >= lines.length) continue;

      final timeLine = lines[timeLineIndex];
      final timeParts = timeLine.split(RegExp(r'\s*-->\s*'));
      if (timeParts.length < 2) continue;

      // Take just the start and end timestamp (strip VTT positioning settings like align:start)
      final startStr = timeParts[0].trim();
      final endStr = timeParts[1].trim().split(RegExp(r'\s+'))[0];

      final start = _parseVttTimestamp(startStr);
      final end = _parseVttTimestamp(endStr);

      if (start == null || end == null) continue;

      final textLines = lines.sublist(timeLineIndex + 1);
      if (textLines.isEmpty) continue;

      // Strip tags like <v SpeakerName> or <b>
      final rawText = textLines.join('\n');
      String cleanText = rawText;
      String? speaker;

      final voiceTagMatch = RegExp(
        r'<v(?:\.[\w-]+)?\s+([^>]+)>(.*)',
        dotAll: true,
      ).firstMatch(rawText);
      if (voiceTagMatch != null) {
        speaker = voiceTagMatch.group(1)?.trim();
        cleanText =
            voiceTagMatch.group(2)?.replaceAll(RegExp(r'</v>'), '') ?? rawText;
      }

      // Remove general HTML formatting tags for plain rendering (keep text)
      cleanText = cleanText.replaceAll(RegExp(r'<[^>]*>'), '');

      cues.add(
        SubtitleCue(
          index: cueIndex++,
          startTime: start,
          endTime: end,
          text: cleanText.trim(),
          speaker: speaker,
        ),
      );
    }

    cues.sort((a, b) => a.startTime.compareTo(b.startTime));
    return cues;
  }

  static Duration? _parseVttTimestamp(String timestamp) {
    try {
      final parts = timestamp.trim().replaceAll(',', '.').split(':');
      int hours = 0;
      int minutes = 0;
      double secondsWithMs = 0.0;

      if (parts.length == 3) {
        // HH:MM:SS.mmm
        hours = int.parse(parts[0]);
        minutes = int.parse(parts[1]);
        secondsWithMs = double.parse(parts[2]);
      } else if (parts.length == 2) {
        // MM:SS.mmm
        minutes = int.parse(parts[0]);
        secondsWithMs = double.parse(parts[1]);
      } else {
        return null;
      }

      final seconds = secondsWithMs.floor();
      final milliseconds = ((secondsWithMs - seconds) * 1000).round();

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } catch (_) {
      return null;
    }
  }
}
