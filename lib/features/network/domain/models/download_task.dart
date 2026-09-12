enum DownloadStatus { queued, downloading, paused, completed, failed }

/// A background download job converting remote network stream to local library file.
class DownloadTask {
  final String id;
  final String title;
  final String remoteUrl;
  final String localDestinationPath;
  final int bytesDownloaded;
  final int totalBytes;
  final double speedKbps;
  final DownloadStatus status;
  final bool wifiOnly;
  final DateTime createdAt;

  const DownloadTask({
    required this.id,
    required this.title,
    required this.remoteUrl,
    required this.localDestinationPath,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.speedKbps = 0.0,
    this.status = DownloadStatus.queued,
    this.wifiOnly = true,
    required this.createdAt,
  });

  double get progressFraction {
    if (totalBytes <= 0) return 0.0;
    return (bytesDownloaded / totalBytes).clamp(0.0, 1.0);
  }

  String get progressPercentage =>
      '${(progressFraction * 100).toStringAsFixed(1)}%';

  DownloadTask copyWith({
    String? id,
    String? title,
    String? remoteUrl,
    String? localDestinationPath,
    int? bytesDownloaded,
    int? totalBytes,
    double? speedKbps,
    DownloadStatus? status,
    bool? wifiOnly,
    DateTime? createdAt,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      title: title ?? this.title,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localDestinationPath: localDestinationPath ?? this.localDestinationPath,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      speedKbps: speedKbps ?? this.speedKbps,
      status: status ?? this.status,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
