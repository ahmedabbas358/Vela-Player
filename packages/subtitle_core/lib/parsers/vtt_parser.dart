import '../models/unified_subtitle_cue.dart';

/// High-performance parser for WebVTT (.vtt) subtitle files.
/// Includes support for UTF-8 BOM, voice tags, and flexible timestamp formats.
class VttParser {
  static final RegExp _timingRegex = RegExp(
    r'(?:(\d{1,2}):)?(\d{1,2}):(\d{1,2})\.(\d{1,4})\s*-->\s*(?:(\d{1,2}):)?(\d{1,2}):(\d{1,2})\.(\d{1,4})',
  );

  /// Parses raw WebVTT content string into a list of [UnifiedSubtitleCue].
  static List<UnifiedSubtitleCue> parse(String content) {
    if (content.isEmpty) return [];

    var cleaned = content;
    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
    }

    final normalized = cleaned.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n{2,}'));
    final List<UnifiedSubtitleCue> cues = [];

    int indexCounter = 1;

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      // Skip WEBVTT header block
      if (lines.first.startsWith('WEBVTT') || lines.first.startsWith('NOTE')) {
        continue;
      }

      int timeLineIndex = -1;
      Match? match;

      for (int i = 0; i < lines.length; i++) {
        final currentMatch = _timingRegex.firstMatch(lines[i]);
        if (currentMatch != null) {
          timeLineIndex = i;
          match = currentMatch;
          break;
        }
      }

      if (match == null || timeLineIndex == -1) continue;

      final startH = match.group(1) != null ? int.parse(match.group(1)!) : 0;
      final startM = int.parse(match.group(2)!);
      final startS = int.parse(match.group(3)!);
      final startMs = _normalizeMillis(match.group(4)!);

      final endH = match.group(5) != null ? int.parse(match.group(5)!) : 0;
      final endM = int.parse(match.group(6)!);
      final endS = int.parse(match.group(7)!);
      final endMs = _normalizeMillis(match.group(8)!);

      final startTime =
          (startH * 3600000) + (startM * 60000) + (startS * 1000) + startMs;
      final endTime = (endH * 3600000) + (endM * 60000) + (endS * 1000) + endMs;

      final textLines = lines.sublist(timeLineIndex + 1);
      final rawText = textLines.join('\n').trim();

      // Extract voice tag <v Speaker>
      String? speaker;
      String cleanText = rawText;

      final vttVoiceMatch =
          RegExp(r'<v\s+([^>]+)>(.*)', dotAll: true).firstMatch(rawText);
      if (vttVoiceMatch != null) {
        speaker = vttVoiceMatch.group(1)?.trim();
        cleanText = vttVoiceMatch.group(2)?.trim() ?? rawText;
      }

      // Strip remaining WebVTT tags (e.g. <c.color>, <b>, <timestamp>)
      cleanText = cleanText.replaceAll(RegExp(r'<[^>]*>'), '');

      cues.add(
        UnifiedSubtitleCue(
          id: 'vtt_$indexCounter',
          index: indexCounter,
          startMs: startTime,
          endMs: endTime,
          text: cleanText,
          speakerName: speaker,
          rawFormatting: rawText != cleanText ? rawText : null,
        ),
      );

      indexCounter++;
    }

    return cues;
  }

  static int _normalizeMillis(String millisStr) {
    if (millisStr.length >= 3) {
      return int.parse(millisStr.substring(0, 3));
    }
    return int.parse(millisStr.padRight(3, '0'));
  }
}
