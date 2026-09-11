/// Profile of an identified character including extracted visual color palette.
class CharacterProfile {
  final String characterId;
  final String name;
  final String? gender;
  final String? hairColorHex;
  final String? eyeColorHex;
  final String? clothingColorHex;
  final String assignedSubtitleColorHex;
  final double confidence;

  const CharacterProfile({
    required this.characterId,
    required this.name,
    this.gender,
    this.hairColorHex,
    this.eyeColorHex,
    this.clothingColorHex,
    required this.assignedSubtitleColorHex,
    this.confidence = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'characterId': characterId,
        'name': name,
        'gender': gender,
        'hairColorHex': hairColorHex,
        'eyeColorHex': eyeColorHex,
        'clothingColorHex': clothingColorHex,
        'assignedSubtitleColorHex': assignedSubtitleColorHex,
        'confidence': confidence,
      };

  factory CharacterProfile.fromJson(Map<String, dynamic> json) => CharacterProfile(
        characterId: json['characterId'] as String,
        name: json['name'] as String,
        gender: json['gender'] as String?,
        hairColorHex: json['hairColorHex'] as String?,
        eyeColorHex: json['eyeColorHex'] as String?,
        clothingColorHex: json['clothingColorHex'] as String?,
        assignedSubtitleColorHex: json['assignedSubtitleColorHex'] as String,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      );
}
