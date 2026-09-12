import 'unified_subtitle_cue.dart';

/// Document format types supported by Vela Subtitle Intelligence Studio.
enum SubtitleSourceFormat {
  srt,
  ass,
  ssa,
  vtt,
  ttml,
  pgs,
  embedded,
}

/// A snapshot version of the subtitle document in non-destructive history.
class SubtitleVersionSnapshot {
  final int versionNumber;
  final String label;
  final String description;
  final DateTime createdAt;
  final List<UnifiedSubtitleCue> cues;

  const SubtitleVersionSnapshot({
    required this.versionNumber,
    required this.label,
    required this.description,
    required this.createdAt,
    required this.cues,
  });
}

/// Unified Subtitle Document: The canonical, loss-free Intermediate Representation (IR)
/// for all subtitle formats inside Vela Player.
///
/// Invariant: The original source file is strictly immutable.
/// Every modification (sync, repair, translation, styling) generates a derived version.
class UnifiedSubtitleDocument {
  final String documentId;
  final String title;
  final SubtitleSourceFormat format;
  final String languageCode;
  final String sourceFingerprint;
  final List<UnifiedSubtitleCue> cues;
  final Map<String, dynamic> rawHeaders;
  final int currentVersion;
  final List<SubtitleVersionSnapshot> versionHistory;

  UnifiedSubtitleDocument({
    required this.documentId,
    required this.title,
    required this.format,
    this.languageCode = 'und',
    required this.sourceFingerprint,
    required this.cues,
    this.rawHeaders = const {},
    this.currentVersion = 1,
    List<SubtitleVersionSnapshot>? versionHistory,
  }) : versionHistory = versionHistory ??
            [
              SubtitleVersionSnapshot(
                versionNumber: 1,
                label: 'النسخة الأصلية (Original)',
                description: 'الملف الأصلي المحفوظ دون أي تعديل.',
                createdAt: DateTime.now(),
                cues: List.unmodifiable(cues),
              ),
            ];

  int get totalCues => cues.length;

  int get totalDurationMs {
    if (cues.isEmpty) return 0;
    return cues.last.endMs;
  }

  /// Create a new derived version (e.g. after sync, repair, translation, or styling)
  UnifiedSubtitleDocument deriveNewVersion({
    required String label,
    required String description,
    required List<UnifiedSubtitleCue> newCues,
  }) {
    final nextVersion = currentVersion + 1;
    final newSnapshot = SubtitleVersionSnapshot(
      versionNumber: nextVersion,
      label: label,
      description: description,
      createdAt: DateTime.now(),
      cues: List.unmodifiable(newCues),
    );

    return UnifiedSubtitleDocument(
      documentId: documentId,
      title: title,
      format: format,
      languageCode: languageCode,
      sourceFingerprint: sourceFingerprint,
      cues: newCues,
      rawHeaders: rawHeaders,
      currentVersion: nextVersion,
      versionHistory: [...versionHistory, newSnapshot],
    );
  }

  /// Revert to a specific past version
  UnifiedSubtitleDocument revertToVersion(int versionNumber) {
    final snapshot = versionHistory.firstWhere(
      (s) => s.versionNumber == versionNumber,
      orElse: () => versionHistory.first,
    );

    return UnifiedSubtitleDocument(
      documentId: documentId,
      title: title,
      format: format,
      languageCode: languageCode,
      sourceFingerprint: sourceFingerprint,
      cues: List.from(snapshot.cues),
      rawHeaders: rawHeaders,
      currentVersion: snapshot.versionNumber,
      versionHistory: versionHistory,
    );
  }
}
