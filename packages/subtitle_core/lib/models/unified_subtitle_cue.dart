/// Represents a single subtitle cue inside Vela's Unified Subtitle Model.
/// All formats (SRT, ASS, VTT, TTML) normalize into this representation.
class UnifiedSubtitleCue {
  final String id;
  final int index;
  final int startMs;
  final int endMs;
  final String text;
  final String? originalText;
  final String? speakerId;
  final String? speakerName;
  final String? characterId;
  final String? characterColorHex;
  final String styleKey;
  final double confidenceScore;
  final String? rawFormatting;

  const UnifiedSubtitleCue({
    required this.id,
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.text,
    this.originalText,
    this.speakerId,
    this.speakerName,
    this.characterId,
    this.characterColorHex,
    this.styleKey = 'default',
    this.confidenceScore = 1.0,
    this.rawFormatting,
  });

  int get durationMs => endMs - startMs;

  /// Characters per second (CPS) reading speed
  double get readingSpeedCps {
    final durSec = durationMs / 1000.0;
    if (durSec <= 0.0) return 0.0;
    return text.replaceAll('\n', ' ').trim().length / durSec;
  }

  /// Check if the cue is active at a specific player position in milliseconds
  bool isActiveAt(int positionMs) =>
      positionMs >= startMs && positionMs <= endMs;

  UnifiedSubtitleCue copyWith({
    String? id,
    int? index,
    int? startMs,
    int? endMs,
    String? text,
    String? originalText,
    String? speakerId,
    String? speakerName,
    String? characterId,
    String? characterColorHex,
    String? styleKey,
    double? confidenceScore,
    String? rawFormatting,
  }) {
    return UnifiedSubtitleCue(
      id: id ?? this.id,
      index: index ?? this.index,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      text: text ?? this.text,
      originalText: originalText ?? this.originalText,
      speakerId: speakerId ?? this.speakerId,
      speakerName: speakerName ?? this.speakerName,
      characterId: characterId ?? this.characterId,
      characterColorHex: characterColorHex ?? this.characterColorHex,
      styleKey: styleKey ?? this.styleKey,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      rawFormatting: rawFormatting ?? this.rawFormatting,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'startMs': startMs,
        'endMs': endMs,
        'durationMs': durationMs,
        'text': text,
        'originalText': originalText,
        'speakerId': speakerId,
        'speakerName': speakerName,
        'characterId': characterId,
        'characterColorHex': characterColorHex,
        'styleKey': styleKey,
        'readingSpeedCps': readingSpeedCps,
        'confidenceScore': confidenceScore,
      };
}
