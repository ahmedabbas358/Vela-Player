/// Audio profile presets tailored for specific media types in Vela Player.
enum AudioProfileType {
  anime,
  movies,
  music,
  podcasts,
  sports,
  custom,
}

class AudioProfile {
  final AudioProfileType type;
  final String name;
  final String description;
  final List<double> equalizerGains; // 10 bands (31Hz to 16kHz)
  final double bassBoostPercent;
  final double virtualizerPercent;
  final bool nightModeEnabled;
  final bool dialogueEnhancer;
  final double preampGainDb;

  const AudioProfile({
    required this.type,
    required this.name,
    required this.description,
    required this.equalizerGains,
    this.bassBoostPercent = 0.0,
    this.virtualizerPercent = 0.0,
    this.nightModeEnabled = false,
    this.dialogueEnhancer = false,
    this.preampGainDb = 0.0,
  });

  static const AudioProfile anime = AudioProfile(
    type: AudioProfileType.anime,
    name: 'أنمي (Anime)',
    description: 'توضيح طبقات صوت الشخصيات وموسيقى الخلفية (OST) بدقة نقية.',
    equalizerGains: [1.0, 1.5, 0.5, 0.0, 1.0, 3.0, 4.0, 3.0, 2.0, 1.5],
    bassBoostPercent: 20.0,
    virtualizerPercent: 30.0,
    dialogueEnhancer: true,
  );

  static const AudioProfile movies = AudioProfile(
    type: AudioProfileType.movies,
    name: 'أفلام سينمائية (Movies)',
    description: 'صوت محيطي واسع، تعزيز الانفجارات والحوار المركزي للفيلم.',
    equalizerGains: [4.0, 3.5, 2.0, 0.5, 0.0, 1.5, 2.5, 3.0, 2.0, 3.5],
    bassBoostPercent: 40.0,
    virtualizerPercent: 50.0,
    dialogueEnhancer: true,
  );

  static const AudioProfile music = AudioProfile(
    type: AudioProfileType.music,
    name: 'موسيقى (Hi-Fi Music)',
    description: 'توازن صوتي دقيق وأقصى دقة لأدق التفاصيل الموسيقية.',
    equalizerGains: [2.5, 2.0, 1.0, 0.0, -0.5, 0.0, 1.5, 2.0, 2.5, 3.0],
    bassBoostPercent: 15.0,
    virtualizerPercent: 25.0,
  );

  static const AudioProfile podcasts = AudioProfile(
    type: AudioProfileType.podcasts,
    name: 'بودكاست وكلام (Podcasts)',
    description:
        'عزل تام للترددات المنخفضة المزعجة وإبراز مخارج الحروف والنطق.',
    equalizerGains: [-4.0, -2.0, 0.0, 2.0, 4.5, 5.0, 3.5, 1.0, 0.0, -1.0],
    bassBoostPercent: 0.0,
    virtualizerPercent: 0.0,
    dialogueEnhancer: true,
  );

  static const AudioProfile sports = AudioProfile(
    type: AudioProfileType.sports,
    name: 'مباريات ورياضة (Sports)',
    description: 'توسيع صوت هتاف الجماهير مع إبراز صوت المعلق الرياضي.',
    equalizerGains: [3.0, 2.0, 0.5, 0.0, 1.0, 3.5, 3.0, 1.5, 1.0, 1.0],
    bassBoostPercent: 25.0,
    virtualizerPercent: 45.0,
    dialogueEnhancer: true,
  );

  static const List<AudioProfile> allProfiles = [
    anime,
    movies,
    music,
    podcasts,
    sports,
  ];
}
