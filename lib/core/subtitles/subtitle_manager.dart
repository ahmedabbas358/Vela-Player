import 'package:flutter_riverpod/legacy.dart';

import 'models/subtitle_cue.dart';
import 'models/subtitle_style.dart';
import 'parsers/subtitle_parser_factory.dart';

/// State of subtitle engine
class SubtitleState {
  final List<SubtitleCue> cues;
  final Duration offset;
  final SubtitleCue? activeCue;
  final SubtitleStyle style;
  final String? fileName;
  final bool isVisible;

  const SubtitleState({
    this.cues = const [],
    this.offset = Duration.zero,
    this.activeCue,
    this.style = SubtitleStyle.classicWhite,
    this.fileName,
    this.isVisible = true,
  });

  SubtitleState copyWith({
    List<SubtitleCue>? cues,
    Duration? offset,
    SubtitleCue? activeCue,
    bool clearActiveCue = false,
    SubtitleStyle? style,
    String? fileName,
    bool? isVisible,
  }) {
    return SubtitleState(
      cues: cues ?? this.cues,
      offset: offset ?? this.offset,
      activeCue: clearActiveCue ? null : (activeCue ?? this.activeCue),
      style: style ?? this.style,
      fileName: fileName ?? this.fileName,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Subtitle State Notifier managing loaded cues, real-time matching, and offsets
class SubtitleNotifier extends StateNotifier<SubtitleState> {
  SubtitleNotifier() : super(const SubtitleState());

  /// Load subtitle content from a raw string (auto-detecting SRT, VTT, ASS/SSA)
  void loadContent(String content, {String? fileName}) {
    final parsed = SubtitleParserFactory.parse(content, fileName: fileName);

    state = state.copyWith(
      cues: parsed,
      fileName: fileName,
      offset: Duration.zero,
      clearActiveCue: true,
    );
  }

  /// Update active cue based on current video playback position
  void updatePosition(Duration position) {
    if (state.cues.isEmpty || !state.isVisible) {
      if (state.activeCue != null) {
        state = state.copyWith(clearActiveCue: true);
      }
      return;
    }

    // Apply current offset to the query time
    final adjustedPosition = position - state.offset;
    final cue = _findCueAt(adjustedPosition);

    if (cue != state.activeCue) {
      state = state.copyWith(activeCue: cue, clearActiveCue: cue == null);
    }
  }

  /// Adjust subtitle delay offset by [delta] (e.g. Duration(milliseconds: 100))
  void adjustOffset(Duration delta) {
    final newOffset = state.offset + delta;
    state = state.copyWith(offset: newOffset);
  }

  /// Reset delay offset to zero
  void resetOffset() {
    state = state.copyWith(offset: Duration.zero);
  }

  /// Update subtitle visual styling
  void updateStyle(SubtitleStyle newStyle) {
    state = state.copyWith(style: newStyle);
  }

  /// Toggle subtitle visibility on/off
  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  /// Fast binary search to find the active cue at [position]
  SubtitleCue? _findCueAt(Duration position) {
    final cues = state.cues;
    if (cues.isEmpty) return null;

    int low = 0;
    int high = cues.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final cue = cues[mid];

      if (cue.isActiveAt(position)) {
        return cue;
      } else if (position < cue.startTime) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    // Linear fallback for overlapping cues
    for (final c in cues) {
      if (c.isActiveAt(position)) return c;
    }

    return null;
  }
}

final subtitleProvider = StateNotifierProvider<SubtitleNotifier, SubtitleState>(
  (ref) {
    return SubtitleNotifier();
  },
);
