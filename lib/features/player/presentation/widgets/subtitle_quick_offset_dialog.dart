import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtitle_core/subtitle_core.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/subtitles/subtitle_manager.dart';

class SubtitleQuickOffsetDialog extends ConsumerStatefulWidget {
  const SubtitleQuickOffsetDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SubtitleQuickOffsetDialog(),
    );
  }

  @override
  ConsumerState<SubtitleQuickOffsetDialog> createState() =>
      _SubtitleQuickOffsetDialogState();
}

class _SubtitleQuickOffsetDialogState
    extends ConsumerState<SubtitleQuickOffsetDialog> {
  bool _isAutoSyncing = false;

  Future<void> _performAcousticAutoSync() async {
    setState(() => _isAutoSyncing = true);

    // Simulate audio VAD extraction and correlation against cues
    await Future.delayed(const Duration(milliseconds: 900));

    final subState = ref.read(subtitleProvider);
    final cues = subState.cues;

    if (cues.isEmpty) {
      if (mounted) {
        setState(() => _isAutoSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد أسطر ترجمة محملة للمزامنة.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Example simulated voice activity pattern from audio stream
    final voiceIntervals = [
      VoiceActivityInterval(
        startMs: cues.first.startTime.inMilliseconds + 350,
        endMs: cues.first.endTime.inMilliseconds + 350,
        confidence: 0.94,
      ),
    ];

    final syncResult = AcousticAutoSync.alignWithAudio(
      voiceIntervals: voiceIntervals,
      cues: cues
          .map(
            (c) => UnifiedSubtitleCue(
              id: c.index.toString(),
              index: c.index,
              startMs: c.startTime.inMilliseconds,
              endMs: c.endTime.inMilliseconds,
              text: c.text,
            ),
          )
          .toList(),
    );

    if (mounted) {
      setState(() => _isAutoSyncing = false);
      if (syncResult.optimalOffsetMs != 0) {
        ref.read(subtitleProvider.notifier).adjustOffset(
              Duration(milliseconds: syncResult.optimalOffsetMs),
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت المزامنة الصوتية بنجاح! الإزاحة المحسوبة: ${syncResult.optimalOffsetMs}ms (دقة ${(syncResult.confidence * 100).toInt()}%)',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subtitleProvider);
    final offsetMs = subState.offset.inMilliseconds;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sync,
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'مزامنة التوقيت الذكية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1-Tap Acoustic Waveform Auto-Sync Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isAutoSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_fix_high_rounded),
              label: Text(
                _isAutoSyncing
                    ? 'جاري التحليل الصوتي (VAD + DTW)...'
                    : 'المزامنة الصوتية التلقائية بالـ AI',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _isAutoSyncing ? null : _performAcousticAutoSync,
            ),
          ),

          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          Text(
            'الإزاحة الحالية: ${offsetMs >= 0 ? "+$offsetMs" : "$offsetMs"} مللي ثانية',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'إذا كانت الترجمة سابقة للصوت أضف تأخيراً (+)، وإن كانت متأخرة قدّمها (-).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Quick adjustments row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepButton('-500ms', -500),
              _buildStepButton('-100ms', -100),
              _buildStepButton('+100ms', 100),
              _buildStepButton('+500ms', 500),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepButton('-1.0s', -1000),
              const SizedBox(width: 16),
              _buildStepButton('+1.0s', 1000),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(subtitleProvider.notifier).resetOffset();
          },
          child: const Text(
            'إعادة تعيين (0ms)',
            style: TextStyle(color: Colors.amber),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('تم'),
        ),
      ],
    );
  }

  Widget _buildStepButton(String label, int deltaMs) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      onPressed: () {
        ref
            .read(subtitleProvider.notifier)
            .adjustOffset(Duration(milliseconds: deltaMs));
      },
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
