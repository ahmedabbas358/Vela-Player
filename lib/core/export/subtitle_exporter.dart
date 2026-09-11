import 'dart:convert';
import 'dart:io';
import '../subtitles/models/subtitle_cue.dart';

/// Utility to export subtitle cues back to SRT format
class SubtitleExporter {
  /// Export a list of [SubtitleCue] to SRT formatted string
  static String toSrt(List<SubtitleCue> cues) {
    final buffer = StringBuffer();

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer.writeln(i + 1);
      buffer.writeln(
          '${_formatTimestamp(cue.startTime)} --> ${_formatTimestamp(cue.endTime)}');

      // Prepend speaker if available
      if (cue.speaker != null && cue.speaker!.isNotEmpty) {
        buffer.writeln('[${cue.speaker}]: ${cue.text}');
      } else {
        buffer.writeln(cue.text);
      }
      buffer.writeln(); // blank separator
    }

    return buffer.toString();
  }

  /// Export cues to a file at [path]
  static Future<void> toSrtFile(List<SubtitleCue> cues, String path) async {
    final content = toSrt(cues);
    final file = File(path);
    await file.writeAsString(content, encoding: utf8);
  }

  /// Export cues to WebVTT format
  static String toVtt(List<SubtitleCue> cues) {
    final buffer = StringBuffer();
    buffer.writeln('WEBVTT');
    buffer.writeln();

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer.writeln(i + 1);
      buffer.writeln(
          '${_formatVttTimestamp(cue.startTime)} --> ${_formatVttTimestamp(cue.endTime)}');

      if (cue.speaker != null && cue.speaker!.isNotEmpty) {
        buffer.writeln('<v ${cue.speaker}>${cue.text}</v>');
      } else {
        buffer.writeln(cue.text);
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  // SRT timestamp format: HH:MM:SS,mmm
  static String _formatTimestamp(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$h:$m:$s,$ms';
  }

  // VTT timestamp format: HH:MM:SS.mmm
  static String _formatVttTimestamp(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}
