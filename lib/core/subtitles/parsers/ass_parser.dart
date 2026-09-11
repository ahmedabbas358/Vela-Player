import '../models/subtitle_cue.dart';

/// Parser for basic ASS/SSA subtitle files.
/// Handles the [Events] section, extracting Dialogue lines with timing and text.
class AssParser {
  /// Parse raw ASS/SSA content into a list of [SubtitleCue]
  static List<SubtitleCue> parse(String content) {
    final List<SubtitleCue> cues = [];
    if (content.trim().isEmpty) return cues;

    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');

    // Find the [Events] section and its Format line
    bool inEventsSection = false;
    List<String> formatFields = [];

    int cueIndex = 1;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.toLowerCase() == '[events]') {
        inEventsSection = true;
        continue;
      }

      // If we hit another section header, stop
      if (trimmed.startsWith('[') && trimmed.endsWith(']') && inEventsSection) {
        break;
      }

      if (!inEventsSection) continue;

      // Parse Format line
      if (trimmed.toLowerCase().startsWith('format:')) {
        final formatStr = trimmed.substring('format:'.length);
        formatFields = formatStr.split(',').map((f) => f.trim().toLowerCase()).toList();
        continue;
      }

      // Parse Dialogue lines
      if (trimmed.startsWith('Dialogue:') || trimmed.startsWith('dialogue:')) {
        final dialogueStr = trimmed.substring('Dialogue:'.length).trimLeft();

        // ASS dialogue fields are comma-separated, but the Text field (last)
        // can contain commas, so we split only up to formatFields.length - 1
        final fieldCount = formatFields.isNotEmpty ? formatFields.length : 10;
        final parts = _splitDialogue(dialogueStr, fieldCount);

        if (parts.length < fieldCount) continue;

        // Find indices
        final startIdx = formatFields.indexOf('start');
        final endIdx = formatFields.indexOf('end');
        final textIdx = formatFields.indexOf('text');
        final nameIdx = formatFields.indexOf('name');

        if (startIdx == -1 || endIdx == -1 || textIdx == -1) continue;

        final start = _parseAssTimestamp(parts[startIdx]);
        final end = _parseAssTimestamp(parts[endIdx]);

        if (start == null || end == null) continue;

        // Clean ASS override tags like {\b1}, {\pos(x,y)}, etc.
        String rawText = parts[textIdx];
        rawText = rawText.replaceAll(RegExp(r'\{\\[^}]*\}'), '');
        // Replace \N and \n with actual newlines
        rawText = rawText.replaceAll(r'\N', '\n').replaceAll(r'\n', '\n');
        rawText = rawText.trim();

        if (rawText.isEmpty) continue;

        String? speaker;
        if (nameIdx != -1 && nameIdx < parts.length) {
          final name = parts[nameIdx].trim();
          if (name.isNotEmpty) speaker = name;
        }

        cues.add(
          SubtitleCue(
            index: cueIndex++,
            startTime: start,
            endTime: end,
            text: rawText,
            speaker: speaker,
          ),
        );
      }
    }

    cues.sort((a, b) => a.startTime.compareTo(b.startTime));
    return cues;
  }

  /// Split dialogue line into fields, respecting that the last field (Text)
  /// may contain commas
  static List<String> _splitDialogue(String line, int fieldCount) {
    final List<String> parts = [];
    int start = 0;

    for (int i = 0; i < fieldCount - 1; i++) {
      final commaIdx = line.indexOf(',', start);
      if (commaIdx == -1) break;
      parts.add(line.substring(start, commaIdx).trim());
      start = commaIdx + 1;
    }

    // The rest is the Text field (may contain commas)
    if (start < line.length) {
      parts.add(line.substring(start).trim());
    }

    return parts;
  }

  /// Parse ASS timestamp: H:MM:SS.CC (centiseconds)
  static Duration? _parseAssTimestamp(String timestamp) {
    try {
      final trimmed = timestamp.trim();
      final parts = trimmed.split(':');
      if (parts.length != 3) return null;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secParts = parts[2].split('.');
      final seconds = int.parse(secParts[0]);
      final centiseconds = secParts.length > 1 ? int.parse(secParts[1].padRight(2, '0').substring(0, 2)) : 0;

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: centiseconds * 10,
      );
    } catch (_) {
      return null;
    }
  }
}
