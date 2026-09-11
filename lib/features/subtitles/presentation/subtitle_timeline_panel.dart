import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/subtitles/subtitle_manager.dart';

/// Displays the raw subtitle text content in a scrollable timeline view,
/// highlighting the currently active cue
class SubtitleTimelinePanel extends ConsumerWidget {
  final ScrollController? scrollController;

  const SubtitleTimelinePanel({super.key, this.scrollController});

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ms = d.inMilliseconds.remainder(1000);

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${(ms ~/ 10).toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${(ms ~/ 10).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subtitleProvider);
    final cues = subState.cues;
    final activeCue = subState.activeCue;

    if (cues.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.subtitles_off_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 12),
              Text(
                'لا يوجد ملف ترجمة محمّل',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: cues.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final cue = cues[index];
        final isActive = activeCue?.index == cue.index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: AppColors.primary, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp row
              Row(
                children: [
                  Text(
                    '#${cue.index}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppColors.primaryLight
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_formatDuration(cue.startTime)} → ${_formatDuration(cue.endTime)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: isActive
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (cue.speaker != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (cue.speakerColor ?? AppColors.accent)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cue.speaker!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: cue.speakerColor ?? AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Subtitle text
              Text(
                cue.text,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
