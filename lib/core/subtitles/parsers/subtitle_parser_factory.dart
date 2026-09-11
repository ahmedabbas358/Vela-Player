import '../models/subtitle_cue.dart';
import 'srt_parser.dart';
import 'vtt_parser.dart';
import 'ass_parser.dart';

/// Auto-detect and parse subtitle files by content or extension
class SubtitleParserFactory {
  /// Parse subtitle content with auto-detection of format.
  /// [fileName] helps determine format from extension.
  /// Falls back to content-based detection if no filename is given.
  static List<SubtitleCue> parse(String content, {String? fileName}) {
    final ext = _extractExtension(fileName);

    // Extension-based detection
    switch (ext) {
      case 'srt':
        return SrtParser.parse(content);
      case 'vtt':
      case 'webvtt':
        return VttParser.parse(content);
      case 'ass':
      case 'ssa':
        return AssParser.parse(content);
    }

    // Content-based detection fallback
    final trimmed = content.trim();
    if (trimmed.toUpperCase().startsWith('WEBVTT')) {
      return VttParser.parse(content);
    }
    if (trimmed.contains('[Script Info]') || trimmed.contains('[Events]')) {
      return AssParser.parse(content);
    }

    // Default: try SRT (most common)
    return SrtParser.parse(content);
  }

  /// Supported subtitle file extensions
  static const List<String> supportedExtensions = [
    'srt',
    'vtt',
    'webvtt',
    'ass',
    'ssa',
  ];

  static String? _extractExtension(String? fileName) {
    if (fileName == null) return null;
    final dotIdx = fileName.lastIndexOf('.');
    if (dotIdx == -1 || dotIdx == fileName.length - 1) return null;
    return fileName.substring(dotIdx + 1).toLowerCase();
  }
}
