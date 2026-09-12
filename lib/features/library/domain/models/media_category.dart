import 'media_item.dart';

/// Categories for Netflix-style browsing in Vela Library.
enum MediaCategory {
  home('الرئيسية (Home)'),
  continueWatching('متابعة المشاهدة (Continue Watching)'),
  recentlyAdded('أضيف حديثاً (Recently Added)'),
  movies('أفلام (Movies)'),
  tvShows('مسلسلات (TV Shows)'),
  anime('أنمي (Anime)'),
  downloads('التنزيلات (Downloads)'),
  favorites('المفضلة (Favorites)');

  final String label;
  const MediaCategory(this.label);
}

/// Curated sample media items representing local media with realistic metadata.
class SampleMediaLibrary {
  static List<MediaItem> get items => [
    MediaItem(
      id: 'media_1',
      title: 'Big Buck Bunny (4K HDR)',
      filePathOrUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      type: MediaType.movie,
      durationMs: 596000,
      lastPositionMs: 184000, // 3:04 watched
      backdropPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
      videoCodec: 'H.264 / AVC (High@L4.1)',
      resolution: '1080p (60fps)',
      fps: 60.0,
      isHdr: false,
      isFavorite: true,
      addedAt: DateTime.now().subtract(const Duration(days: 2)),
      lastWatchedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MediaItem(
      id: 'media_2',
      title: 'Elephant Dream (10-bit Hi10P)',
      filePathOrUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      type: MediaType.anime,
      durationMs: 653000,
      lastPositionMs: 240000,
      backdropPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
      seriesName: 'CGI Shorts',
      seasonNumber: 1,
      episodeNumber: 1,
      videoCodec: 'HEVC Main10 (10-bit)',
      resolution: '4K UHD',
      fps: 24.0,
      isHdr: true,
      is10Bit: true,
      isFavorite: true,
      addedAt: DateTime.now().subtract(const Duration(days: 5)),
      lastWatchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MediaItem(
      id: 'media_3',
      title: 'Sintel (Dolby Surround 5.1)',
      filePathOrUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      type: MediaType.movie,
      durationMs: 888000,
      lastPositionMs: 0,
      backdropPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
      videoCodec: 'HEVC / H.265',
      resolution: '1080p',
      fps: 24.0,
      isHdr: true,
      isFavorite: false,
      addedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MediaItem(
      id: 'media_4',
      title: 'Tears of Steel (Sci-Fi VFX)',
      filePathOrUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      type: MediaType.movie,
      durationMs: 734000,
      lastPositionMs: 512000,
      backdropPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
      videoCodec: 'AV1 (libdav1d)',
      resolution: '4K UHD',
      fps: 24.0,
      isHdr: true,
      isFavorite: true,
      addedAt: DateTime.now().subtract(const Duration(days: 7)),
      lastWatchedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
}
