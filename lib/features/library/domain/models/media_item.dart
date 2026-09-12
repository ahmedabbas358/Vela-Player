enum MediaType { movie, tvShow, anime, music, clip }

/// Rich media item model for Vela's local Netflix-grade library.
class MediaItem {
  final String id;
  final String title;
  final String filePathOrUrl;
  final MediaType type;
  final int durationMs;
  final int lastPositionMs;
  final String? posterPath;
  final String? backdropPath;
  final String? seriesName;
  final int? seasonNumber;
  final int? episodeNumber;
  final String videoCodec;
  final String resolution;
  final double fps;
  final bool isHdr;
  final bool is10Bit;
  final bool isFavorite;
  final DateTime addedAt;
  final DateTime? lastWatchedAt;

  const MediaItem({
    required this.id,
    required this.title,
    required this.filePathOrUrl,
    required this.type,
    required this.durationMs,
    this.lastPositionMs = 0,
    this.posterPath,
    this.backdropPath,
    this.seriesName,
    this.seasonNumber,
    this.episodeNumber,
    this.videoCodec = 'HEVC',
    this.resolution = '1080p',
    this.fps = 24.0,
    this.isHdr = false,
    this.is10Bit = false,
    this.isFavorite = false,
    required this.addedAt,
    this.lastWatchedAt,
  });

  bool get hasStartedWatching => lastPositionMs > 0;
  bool get isCompleted =>
      durationMs > 0 && lastPositionMs >= (durationMs * 0.95);

  double get watchProgressFraction {
    if (durationMs <= 0) return 0.0;
    return (lastPositionMs / durationMs).clamp(0.0, 1.0);
  }

  MediaItem copyWith({
    String? id,
    String? title,
    String? filePathOrUrl,
    MediaType? type,
    int? durationMs,
    int? lastPositionMs,
    String? posterPath,
    String? backdropPath,
    String? seriesName,
    int? seasonNumber,
    int? episodeNumber,
    String? videoCodec,
    String? resolution,
    double? fps,
    bool? isHdr,
    bool? is10Bit,
    bool? isFavorite,
    DateTime? addedAt,
    DateTime? lastWatchedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      filePathOrUrl: filePathOrUrl ?? this.filePathOrUrl,
      type: type ?? this.type,
      durationMs: durationMs ?? this.durationMs,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      seriesName: seriesName ?? this.seriesName,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      videoCodec: videoCodec ?? this.videoCodec,
      resolution: resolution ?? this.resolution,
      fps: fps ?? this.fps,
      isHdr: isHdr ?? this.isHdr,
      is10Bit: is10Bit ?? this.is10Bit,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }
}
