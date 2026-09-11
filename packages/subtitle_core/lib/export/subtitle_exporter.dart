import '../models/unified_subtitle_cue.dart';

/// Exports [UnifiedSubtitleCue] tracks back to standard subtitle formats.
class SubtitleExporter {
  /// Converts a list of cues into a standard SubRip (.srt) string.
  static String toSrt(List<UnifiedSubtitleCue> cues) {
    final buffer = StringBuffer();

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer.writeln(i + 1);
      buffer.writeln('${_formatSrtTimestamp(cue.startMs)} --> ${_formatSrtTimestamp(cue.endMs)}');

      if (cue.speakerName != null && cue.speakerName!.isNotEmpty) {
        buffer.writeln('${cue.speakerName}: ${cue.text}');
      } else {
        buffer.writeln(cue.text);
      }

      buffer.writeln(); // Blank line separator
    }

    return buffer.toString().trim();
  }

  /// Converts a list of cues into a standard WebVTT (.vtt) string.
  static String toVtt(List<UnifiedSubtitleCue> cues) {
    final buffer = StringBuffer();
    buffer.writeln('WEBVTT\n');

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer.writeln('${_formatVttTimestamp(cue.startMs)} --> ${_formatVttTimestamp(cue.endMs)}');

      if (cue.speakerName != null && cue.speakerName!.isNotEmpty) {
        buffer.writeln('<v ${cue.speakerName}>${cue.text}');
      } else {
        buffer.writeln(cue.text);
      }

      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  static String _formatSrtTimestamp(int totalMs) {
    final h = (totalMs ~/ 3600000).toString().padLeft(2, '0');
    final m = ((totalMs % 3600000) ~/ 60000).toString().padLeft(2, '0');
    final s = ((totalMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    final ms = (totalMs % 1000).toString().padLeft(3, '0');
    return '$h:$m:$s,$ms';
  }

  static String _formatVttTimestamp(int totalMs) {
    final h = (totalMs ~/ 3600000).toString().padLeft(2, '0');
    final m = ((totalMs % 3600000) ~/ 60000).toString().padLeft(2, '0');
    final s = ((totalMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    final ms = (totalMs % 1000).toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}
