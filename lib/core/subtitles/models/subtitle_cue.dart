import 'package:flutter/material.dart';

/// Represents a single timed subtitle cue
class SubtitleCue {
  final int index;
  final Duration startTime;
  final Duration endTime;
  final String text;
  final String? speaker;
  final Color? speakerColor;

  const SubtitleCue({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.text,
    this.speaker,
    this.speakerColor,
  });

  /// Check if this cue should be displayed at [position]
  bool isActiveAt(Duration position) {
    return position >= startTime && position <= endTime;
  }

  SubtitleCue copyWith({
    int? index,
    Duration? startTime,
    Duration? endTime,
    String? text,
    String? speaker,
    Color? speakerColor,
  }) {
    return SubtitleCue(
      index: index ?? this.index,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
      speaker: speaker ?? this.speaker,
      speakerColor: speakerColor ?? this.speakerColor,
    );
  }

  /// Offset cue timing by [offset]
  SubtitleCue withOffset(Duration offset) {
    final newStart = startTime + offset;
    final newEnd = endTime + offset;
    return copyWith(
      startTime: newStart < Duration.zero ? Duration.zero : newStart,
      endTime: newEnd < Duration.zero ? Duration.zero : newEnd,
    );
  }

  @override
  String toString() =>
      'SubtitleCue(index: $index, start: $startTime, end: $endTime, text: "$text")';
}
