/// Diagnostics and Health Score evaluation for a subtitle track.
class SubtitleHealthReport {
  final int overallScore; // 0 to 100
  final int totalCues;
  final int overlappingCuesCount;
  final int negativeDurationCount;
  final int shortFlashCount;
  final int excessiveSpeedCount;
  final int brokenEncodingCount;
  final List<String> issuesSummary;

  const SubtitleHealthReport({
    required this.overallScore,
    required this.totalCues,
    required this.overlappingCuesCount,
    required this.negativeDurationCount,
    required this.shortFlashCount,
    required this.excessiveSpeedCount,
    required this.brokenEncodingCount,
    required this.issuesSummary,
  });

  bool get isHealthy => overallScore >= 90;
  bool get requiresReview => overallScore < 80;

  Map<String, dynamic> toJson() => {
        'overallScore': overallScore,
        'totalCues': totalCues,
        'overlappingCuesCount': overlappingCuesCount,
        'negativeDurationCount': negativeDurationCount,
        'shortFlashCount': shortFlashCount,
        'excessiveSpeedCount': excessiveSpeedCount,
        'brokenEncodingCount': brokenEncodingCount,
        'issuesSummary': issuesSummary,
        'isHealthy': isHealthy,
      };
}
