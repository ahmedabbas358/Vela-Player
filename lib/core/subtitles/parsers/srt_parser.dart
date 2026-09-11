import '../models/subtitle_cue.dart';

class SrtParser {
  /// Parse raw SRT text content into a list of [SubtitleCue]
  static List<SubtitleCue> parse(String content) {
    final List<SubtitleCue> cues = [];
    if (content.trim().isEmpty) return cues;

    // Normalize line endings to \n
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n\s*\n'));

    int fallbackIndex = 1;

    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (lines.length < 2) continue;

      int cueIndex = fallbackIndex;
      int timeLineIndex = 0;

      // Check if first line is a numeric cue index
      final parsedIndex = int.tryParse(lines[0]);
      if (parsedIndex != null) {
        cueIndex = parsedIndex;
        timeLineIndex = 1;
      }

      if (timeLineIndex >= lines.length) continue;

      final timeLine = lines[timeLineIndex];
      final timeParts = timeLine.split(RegExp(r'\s*-->\s*'));
      if (timeParts.length != 2) continue;

      final start = _parseTimestamp(timeParts[0]);
      final end = _parseTimestamp(timeParts[1]);

      if (start == null || end == null) continue;

      final textLines = lines.sublist(timeLineIndex + 1);
      if (textLines.isEmpty) continue;

      final text = textLines.join('\n');

      // Check for speaker pattern, e.g. "Name: Text", "[Name]: Text", or "[Name] Text"
      String cleanText = text;
      String? speaker;
      final speakerMatch = RegExp(r'^(?:\[([^\]]+)\]:?|([A-Za-z0-9_\u0600-\u06FF\s]+):)\s*(.*)$', dotAll: true)
          .firstMatch(text);
      if (speakerMatch != null) {
        speaker = (speakerMatch.group(1) ?? speakerMatch.group(2))?.trim();
        cleanText = speakerMatch.group(3)?.trim() ?? text;
        if (cleanText.startsWith(':')) {
          cleanText = cleanText.substring(1).trim();
        }
      }

      cues.add(
        SubtitleCue(
          index: cueIndex,
          startTime: start,
          endTime: end,
          text: cleanText,
          speaker: speaker,
        ),
      );

      fallbackIndex++;
    }

    // Sort by startTime
    cues.sort((a, b) => a.startTime.compareTo(b.startTime));
    return cues;
  }

  static Duration? _parseTimestamp(String timestamp) {
    try {
      final trimmed = timestamp.trim();
      // Format: 00:01:23,456 or 00:01:23.456
      final parts = trimmed.replaceAll(',', '.').split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secParts = parts[2].split('.');
        final seconds = int.parse(secParts[0]);
        final milliseconds =
            secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;

        return Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
