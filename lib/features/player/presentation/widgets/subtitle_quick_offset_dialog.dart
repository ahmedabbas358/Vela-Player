import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/subtitles/subtitle_manager.dart';

class SubtitleQuickOffsetDialog extends ConsumerWidget {
  const SubtitleQuickOffsetDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SubtitleQuickOffsetDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'مزامنة الترجمة اليدوية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الإزاحة الحالية: ${offsetMs >= 0 ? "+$offsetMs" : "$offsetMs"} مللي ثانية',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'إذا كانت الترجمة سابقة للصوت أضف تأخيراً (+)، وإن كانت متأخرة قدّمها (-).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          // Quick adjustments row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepButton(ref, '-500ms', -500),
              _buildStepButton(ref, '-100ms', -100),
              _buildStepButton(ref, '+100ms', 100),
              _buildStepButton(ref, '+500ms', 500),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepButton(ref, '-1.0s', -1000),
              const SizedBox(width: 16),
              _buildStepButton(ref, '+1.0s', 1000),
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

  Widget _buildStepButton(WidgetRef ref, String label, int deltaMs) {
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
