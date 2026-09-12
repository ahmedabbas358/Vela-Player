import '../models/unified_subtitle_cue.dart';

/// High-performance parser for SubRip (.srt) subtitle files.
/// Optimized with single-pass line scanning, resilient timestamp extraction, and UTF-8 BOM handling.
class SrtParser {
  static final RegExp _timingRegex = RegExp(
    r'(\d{1,2}):(\d{1,2}):(\d{1,2})[,.](\d{1,4})\s*-->\s*(\d{1,2}):(\d{1,2}):(\d{1,2})[,.](\d{1,4})',
  );

  /// Parses raw SRT content string into a list of [UnifiedSubtitleCue].
  static List<UnifiedSubtitleCue> parse(String content) {
    if (content.isEmpty) return [];

    var cleaned = content;
    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
    }

    final normalized = cleaned.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final List<UnifiedSubtitleCue> cues = [];

    int indexCounter = 1;
    int i = 0;
    final int lineCount = lines.length;

    while (i < lineCount) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        i++;
        continue;
      }

      // Check if current or next line has timing
      Match? match = _timingRegex.firstMatch(line);
      int timeLineIdx = i;

      if (match == null && i + 1 < lineCount) {
        match = _timingRegex.firstMatch(lines[i + 1].trim());
        if (match != null) {
          timeLineIdx = i + 1;
        }
      }

      if (match == null) {
        i++;
        continue;
      }

      final startMs = _parseTimestamp(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        _normalizeMillis(match.group(4)!),
      );

      final endMs = _parseTimestamp(
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        int.parse(match.group(7)!),
        _normalizeMillis(match.group(8)!),
      );

      // Collect subtitle text until blank line or EOF
      final textBuffer = StringBuffer();
      int textIdx = timeLineIdx + 1;
      while (textIdx < lineCount && lines[textIdx].trim().isNotEmpty) {
        if (textBuffer.isNotEmpty) textBuffer.write('\n');
        textBuffer.write(lines[textIdx].trim());
        textIdx++;
      }

      final rawText = textBuffer.toString();
      String cleanText = rawText;
      String? speaker;

      final speakerMatch =
          RegExp(r'^<v\s+([^>]+)>(.*)$', dotAll: true).firstMatch(rawText) ??
              RegExp(r'^([A-Za-z0-9_\-\s]{2,20}):\s+(.*)$', dotAll: true)
                  .firstMatch(rawText);

      if (speakerMatch != null) {
        speaker = speakerMatch.group(1)?.trim();
        cleanText = speakerMatch.group(2)?.trim() ?? rawText;
      }

      if (cleanText.contains('<')) {
        cleanText = cleanText.replaceAll(RegExp(r'<[^>]*>'), '');
      }

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
      i = textIdx + 1;
    }

    return cues;
  }

  static int _normalizeMillis(String millisStr) {
    if (millisStr.length >= 3) {
      return int.parse(millisStr.substring(0, 3));
    }
    return int.parse(millisStr.padRight(3, '0'));
  }

  static int _parseTimestamp(
      int hours, int minutes, int seconds, int milliseconds) {
    return (hours * 3600000) +
        (minutes * 60000) +
        (seconds * 1000) +
        milliseconds;
  }
}
