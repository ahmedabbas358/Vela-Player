enum AIJobType {
  speechToSubtitle,
  contextualTranslation,
  acousticAutoSync,
  speakerDiarization,
  characterVisionProfile,
  screenOcr,
}

enum AIJobStatus {
  queued,
  processing,
  completed,
  failed,
  cancelled,
}

/// Request payload to initiate an AI job on the Gateway.
class AIJobRequest {
  final String projectId;
  final AIJobType jobType;
  final Map<String, dynamic> parameters;
  final int maxCreditsAllowed;

  const AIJobRequest({
    required this.projectId,
    required this.jobType,
    required this.parameters,
    this.maxCreditsAllowed = 100,
  });

  Map<String, dynamic> toJson() => {
        'projectId': projectId,
        'jobType': jobType.name,
        'parameters': parameters,
        'maxCreditsAllowed': maxCreditsAllowed,
      };
}

/// Status and result of an AI job.
class AIJobResponse {
  final String jobId;
  final AIJobStatus status;
  final int progressPercentage;
  final int creditsUsed;
  final Map<String, dynamic>? resultPayload;
  final String? errorMessage;

  const AIJobResponse({
    required this.jobId,
    required this.status,
    this.progressPercentage = 0,
    this.creditsUsed = 0,
    this.resultPayload,
    this.errorMessage,
  });

  bool get isDone => status == AIJobStatus.completed || status == AIJobStatus.failed;

  factory AIJobResponse.fromJson(Map<String, dynamic> json) => AIJobResponse(
        jobId: json['jobId'] as String,
        status: AIJobStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AIJobStatus.queued,
        ),
        progressPercentage: json['progressPercentage'] as int? ?? 0,
        creditsUsed: json['creditsUsed'] as int? ?? 0,
        resultPayload: json['resultPayload'] as Map<String, dynamic>?,
        errorMessage: json['errorMessage'] as String?,
      );
}
