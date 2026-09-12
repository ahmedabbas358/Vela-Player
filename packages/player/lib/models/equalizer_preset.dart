/// Standard 10-band graphic equalizer frequencies in Hz.
const List<int> kEqualizerFrequencies = [
  31,
  62,
  125,
  250,
  500,
  1000,
  2000,
  4000,
  8000,
  16000,
];

/// Preset definitions for the 10-band equalizer.
class EqualizerPreset {
  final String id;
  final String titleAr;
  final String titleEn;
  final List<double> bandGainsDb; // 10 values, range: -12.0 to +12.0 dB

  const EqualizerPreset({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bandGainsDb,
  });

  static const EqualizerPreset flat = EqualizerPreset(
    id: 'flat',
    titleAr: 'طبيعي (Flat)',
    titleEn: 'Flat',
    bandGainsDb: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  );

  static const EqualizerPreset bassBoost = EqualizerPreset(
    id: 'bass_boost',
    titleAr: 'تضخيم الجهير (Bass Boost)',
    titleEn: 'Bass Boost',
    bandGainsDb: [7.0, 6.0, 5.0, 3.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  );

  static const EqualizerPreset vocalClarity = EqualizerPreset(
    id: 'vocal_clarity',
    titleAr: 'نقاء الحوارات (Vocal Boost)',
    titleEn: 'Vocal Clarity',
    bandGainsDb: [-2.0, -1.0, 0.0, 2.0, 5.0, 6.0, 5.0, 3.0, 1.0, 0.0],
  );

  static const EqualizerPreset cinema = EqualizerPreset(
    id: 'cinema',
    titleAr: 'سينما مجسمة (Cinema 3D)',
    titleEn: 'Cinema',
    bandGainsDb: [4.0, 3.0, 1.0, 0.0, 2.0, 3.0, 4.0, 5.0, 4.0, 3.0],
  );

  static const EqualizerPreset rock = EqualizerPreset(
    id: 'rock',
    titleAr: 'روك وحماسي (Rock)',
    titleEn: 'Rock',
    bandGainsDb: [5.0, 4.0, 2.0, -1.0, -2.0, 0.0, 2.0, 4.0, 5.0, 6.0],
  );

  static const EqualizerPreset nightMode = EqualizerPreset(
    id: 'night_mode',
    titleAr: 'الوضع الليلي (Night Mode)',
    titleEn: 'Night Mode',
    bandGainsDb: [-5.0, -4.0, -2.0, 2.0, 4.0, 4.0, 3.0, 0.0, -2.0, -4.0],
  );

  static const List<EqualizerPreset> allPresets = [
    flat,
    bassBoost,
    vocalClarity,
    cinema,
    rock,
    nightMode,
  ];
}
