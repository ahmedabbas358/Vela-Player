import 'package:flutter/material.dart';
import 'package:player/player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/player/player_service.dart';

/// Bottom sheet for Decoder switching, Aspect Ratio, A-B Repeat, and Kids Lock.
class PlayerSettingsSheet extends StatelessWidget {
  final PlayerService playerService;

  const PlayerSettingsSheet({super.key, required this.playerService});

  static Future<void> show(BuildContext context, PlayerService playerService) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerSettingsSheet(playerService: playerService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: playerService,
      builder: (context, _) {
        final state = playerService.state;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F111A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppColors.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'إعدادات المشغل المتقدمة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),

              // 1. Decoder Engine Mode (HW / HW+ / SW)
              const Text(
                'محرك فك الترميز (Decoder Engine):',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: DecoderMode.values.map((mode) {
                  final isSelected = state.decoderMode == mode;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.04),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => playerService.setDecoderMode(mode),
                        child: Text(
                          mode.labelAr,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 2. Aspect Ratio Mode
              const Text(
                'نسبة أبعاد الشاشة (Aspect Ratio):',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAspectChip(
                      'ملاءمة الشاشة (Fit)',
                      VideoAspectMode.fit,
                      state.aspectMode,
                    ),
                    _buildAspectChip(
                      'ملء الشاشة (Fill)',
                      VideoAspectMode.fill,
                      state.aspectMode,
                    ),
                    _buildAspectChip(
                      'الأصلي (1:1)',
                      VideoAspectMode.original,
                      state.aspectMode,
                    ),
                    _buildAspectChip(
                      '16:9 عريض',
                      VideoAspectMode.ratio16x9,
                      state.aspectMode,
                    ),
                    _buildAspectChip(
                      '21:9 سينمائي',
                      VideoAspectMode.ratio21x9,
                      state.aspectMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. A-B Repeat Loop
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.repeat_one_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'تكرار مقطع (A-B Repeat) لتعلم اللغات',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (state.abRepeat.isActive)
                          TextButton(
                            onPressed: playerService.clearAbRepeat,
                            child: const Text(
                              'إلغاء التكرار',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.abRepeat.pointA != null
                                  ? AppColors.primary
                                  : Colors.white12,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.flag_outlined, size: 16),
                            label: Text(
                              state.abRepeat.pointA != null
                                  ? 'نقطة A: ${_formatDuration(state.abRepeat.pointA!)}'
                                  : 'تحديد نقطة A',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: playerService.setAbRepeatPointA,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.abRepeat.pointB != null
                                  ? AppColors.accent
                                  : Colors.white12,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(
                              Icons.sports_score_outlined,
                              size: 16,
                            ),
                            label: Text(
                              state.abRepeat.pointB != null
                                  ? 'نقطة B: ${_formatDuration(state.abRepeat.pointB!)}'
                                  : 'تحديد نقطة B',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: state.abRepeat.pointA != null
                                ? playerService.setAbRepeatPointB
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Kids Lock Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade900.withValues(
                      alpha: 0.3,
                    ),
                    foregroundColor: Colors.amberAccent,
                    side: const BorderSide(color: Colors.amberAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text(
                    'قفل الأطفال (تجميد اللمس على الشاشة)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    playerService.setKidsLocked(true);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAspectChip(
    String label,
    VideoAspectMode mode,
    VideoAspectMode current,
  ) {
    final isSelected = current == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white10,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 12,
        ),
        onSelected: (selected) {
          if (selected) {
            playerService.setAspectMode(mode);
          }
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
