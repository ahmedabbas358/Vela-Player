import '../models/unified_subtitle_cue.dart';
import 'srt_parser.dart';
import 'vtt_parser.dart';
import 'ass_parser.dart';

/// Auto-detects subtitle format from file extension or content and returns parsed cues.
class SubtitleParserFactory {
  static List<UnifiedSubtitleCue> parse({
    required String content,
    String? fileExtension,
  }) {
    if (content.trim().isEmpty) return [];

    final ext = fileExtension?.toLowerCase().replaceAll('.', '');

    // 1. Detect by extension if provided
    if (ext == 'srt') {
      return SrtParser.parse(content);
    } else if (ext == 'vtt' || ext == 'webvtt') {
      return VttParser.parse(content);
    } else if (ext == 'ass' || ext == 'ssa') {
      return AssParser.parse(content);
    }

    // 2. Auto-detect by content inspection
    final trimmed = content.trim();
    if (trimmed.startsWith('WEBVTT') || trimmed.contains('-->') && trimmed.contains('<v ')) {
      return VttParser.parse(content);
    } else if (trimmed.contains('[Script Info]') || trimmed.contains('[Events]') || trimmed.contains('Dialogue:')) {
      return AssParser.parse(content);
    }

    // Default to SRT parser
    return SrtParser.parse(content);
  }
}
