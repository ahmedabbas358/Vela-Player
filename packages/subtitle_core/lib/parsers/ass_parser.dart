import '../models/unified_subtitle_cue.dart';

/// High-performance parser for Advanced SubStation Alpha (.ass / .ssa) subtitle files.
class AssParser {
  /// Parses raw ASS/SSA content into a list of [UnifiedSubtitleCue].
  static List<UnifiedSubtitleCue> parse(String content) {
    if (content.isEmpty) return [];

    final lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final List<UnifiedSubtitleCue> cues = [];

    bool inEventsSection = false;
    List<String> formatFields = [];
    int indexCounter = 1;

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.startsWith('[') && line.endsWith(']')) {
        inEventsSection = line.toLowerCase() == '[events]';
        continue;
      }

      if (!inEventsSection || line.isEmpty || line.startsWith(';')) {
        continue;
      }

      if (line.startsWith('Format:')) {
        final formatStr = line.substring('Format:'.length).trim();
        formatFields = formatStr.split(',').map((f) => f.trim().toLowerCase()).toList();
        continue;
      }

      if (line.startsWith('Dialogue:')) {
        final dialogueStr = line.substring('Dialogue:'.length).trim();
        final cue = _parseDialogueLine(dialogueStr, formatFields, indexCounter);
        if (cue != null) {
          cues.add(cue);
          indexCounter++;
        }
      }
    }

    return cues;
  }

  static UnifiedSubtitleCue? _parseDialogueLine(
    String dialogueStr,
    List<String> formatFields,
    int index,
  ) {
    // Default ASS Format fallback if header was omitted
    final fields = formatFields.isNotEmpty
        ? formatFields
        : ['layer', 'start', 'end', 'style', 'name', 'marginl', 'marginr', 'marginv', 'effect', 'text'];

    final textIndex = fields.indexOf('text');
    final startIndex = fields.indexOf('start');
    final endIndex = fields.indexOf('end');
    final nameIndex = fields.indexOf('name');
    final styleIndex = fields.indexOf('style');

    if (textIndex == -1 || startIndex == -1 || endIndex == -1) return null;

    // Split only up to the textIndex so text commas are preserved
    final parts = _splitWithLimit(dialogueStr, fields.length);
    if (parts.length <= textIndex) return null;

    final startMs = _parseAssTimestamp(parts[startIndex].trim());
    final endMs = _parseAssTimestamp(parts[endIndex].trim());
    final styleName = styleIndex != -1 ? parts[styleIndex].trim() : 'default';
    final speaker = nameIndex != -1 && parts[nameIndex].trim().isNotEmpty ? parts[nameIndex].trim() : null;

    final rawText = parts[textIndex].trim();

    // Clean ASS tags like {\pos(100,200)}, {\an8}, \N (newline), etc.
    String cleanText = rawText
        .replaceAll(r'\N', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\h', ' ')
        .replaceAll(RegExp(r'\{[^}]*\}'), '')
        .trim();

    return UnifiedSubtitleCue(
      id: 'ass_$index',
      index: index,
      startMs: startMs,
      endMs: endMs,
      text: cleanText,
      speakerName: speaker,
      styleKey: styleName,
      rawFormatting: rawText != cleanText ? rawText : null,
    );
  }

  static List<String> _splitWithLimit(String input, int limit) {
    final result = <String>[];
    int start = 0;
    for (int i = 0; i < limit - 1; i++) {
      final commaIndex = input.indexOf(',', start);
      if (commaIndex == -1) break;
      result.add(input.substring(start, commaIndex));
      start = commaIndex + 1;
    }
    result.add(input.substring(start));
    return result;
  }

  static int _parseAssTimestamp(String timestamp) {
    // Format: H:MM:SS.CC or HH:MM:SS.CC (Centiseconds)
    final match = RegExp(r'(\d+):(\d{2}):(\d{2})[.](\d{2,3})').firstMatch(timestamp);
    if (match == null) return 0;

    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    final seconds = int.parse(match.group(3)!);
    var fractionStr = match.group(4)!;

    int ms = 0;
    if (fractionStr.length == 2) {
      ms = int.parse(fractionStr) * 10; // Centiseconds to milliseconds
    } else {
      ms = int.parse(fractionStr.padRight(3, '0').substring(0, 3));
    }

    return (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + ms;
  }
}
