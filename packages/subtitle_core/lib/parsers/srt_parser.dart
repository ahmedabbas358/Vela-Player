import '../models/unified_subtitle_cue.dart';

/// High-performance parser for SubRip (.srt) subtitle files.
class SrtParser {
  static final RegExp _timingRegex = RegExp(
    r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})',
  );

  /// Parses raw SRT content string into a list of [UnifiedSubtitleCue].
  static List<UnifiedSubtitleCue> parse(String content) {
    if (content.isEmpty) return [];

    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n{2,}'));
    final List<UnifiedSubtitleCue> cues = [];

    int indexCounter = 1;

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 2) continue;

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

      final startMs = _parseTimestamp(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      );

      final endMs = _parseTimestamp(
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        int.parse(match.group(7)!),
        int.parse(match.group(8)!),
      );

      final textLines = lines.sublist(timeLineIndex + 1);
      final rawText = textLines.join('\n').trim();

      // Check for speaker tag e.g. "John: Hello" or "<v John>Hello"
      String? speaker;
      String cleanText = rawText;

      final speakerMatch =
          RegExp(r'^<v\s+([^>]+)>(.*)$', dotAll: true).firstMatch(rawText) ??
              RegExp(r'^([A-Za-z0-9_\-\s]{2,20}):\s+(.*)$', dotAll: true)
                  .firstMatch(rawText);

      if (speakerMatch != null) {
        speaker = speakerMatch.group(1)?.trim();
        cleanText = speakerMatch.group(2)?.trim() ?? rawText;
      }

      // Strip basic HTML formatting for text storage, preserve rawFormatting
      cleanText = cleanText.replaceAll(RegExp(r'<[^>]*>'), '');

      cues.add(
        UnifiedSubtitleCue(
          id: 'srt_$indexCounter',
          index: indexCounter,
          startMs: startMs,
          endMs: endMs,
          text: cleanText,
          speakerName: speaker,
          rawFormatting: rawText != cleanText ? rawText : null,
        ),
      );

      indexCounter++;
    }

    return cues;
  }

  static int _parseTimestamp(
      int hours, int minutes, int seconds, int milliseconds) {
    return (hours * 3600000) +
        (minutes * 60000) +
        (seconds * 1000) +
        milliseconds;
  }
}
