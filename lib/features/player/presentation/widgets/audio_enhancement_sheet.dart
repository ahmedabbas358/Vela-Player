import 'package:flutter/material.dart';
import 'package:player/player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/player/player_service.dart';

/// Modal bottom sheet for controlling 10-Band Equalizer, 200% Audio Boost, and Night Mode.
class AudioEnhancementSheet extends StatefulWidget {
  final PlayerService playerService;

  const AudioEnhancementSheet({
    super.key,
    required this.playerService,
  });

  static Future<void> show(BuildContext context, PlayerService playerService) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AudioEnhancementSheet(playerService: playerService),
    );
  }

  @override
  State<AudioEnhancementSheet> createState() => _AudioEnhancementSheetState();
}

class _AudioEnhancementSheetState extends State<AudioEnhancementSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.playerService,
      builder: (context, _) {
        final state = widget.playerService.state;

        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Color(0xFF0F111A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white12, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              // Sheet Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white10, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.graphic_eq_rounded,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'استوديو الصوتيات المتقدم (Audio Studio)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'تضخيم 200% • معادل 10 نطاقات • الوضع الليلي',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primaryLight,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.equalizer, size: 18),
                    text: 'المعادل الصوتي (EQ)',
                  ),
                  Tab(
                    icon: Icon(Icons.volume_up_rounded, size: 18),
                    text: 'تضخيم ومؤثرات الصوت',
                  ),
                ],
              ),

              // Tab Contents
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: 10-Band Graphic Equalizer
                    _buildEqualizerTab(state),

                    // Tab 2: Audio Boost, Night Mode, Delay, Tracks
                    _buildEnhancementsTab(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEqualizerTab(PlayerStateData state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Presets chips
        const Text(
          'الأنماط الجاهزة (Presets):',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: EqualizerPreset.allPresets.map((preset) {
              final isSelected = state.equalizerPreset.id == preset.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(preset.titleAr),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white10,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      widget.playerService.setEqualizerPreset(preset);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // 10 Frequency Band Sliders
        const Text(
          'تعديل النطاقات الترددية (10-Band Gains):',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(10, (index) {
              final freq = kEqualizerFrequencies[index];
              final gain = state.equalizerGains[index];
              final freqLabel = freq >= 1000 ? '${freq ~/ 1000}k' : '$freq';

              return Column(
                children: [
                  Text(
                    '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: gain > 0
                          ? AppColors.accent
                          : (gain < 0 ? Colors.orangeAccent : Colors.white54),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: gain,
                          min: -12.0,
                          max: 12.0,
                          onChanged: (val) {
                            widget.playerService.setBandGain(index, val);
                          },
                        ),
                      ),
                    ),
                  ),
                  Text(
                    freqLabel,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancementsTab(PlayerStateData state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 200% Audio Boost Slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: state.isAudioBoosted
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: state.isAudioBoosted
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.isAudioBoosted
                            ? Icons.offline_bolt_rounded
                            : Icons.volume_up_rounded,
                        color: state.isAudioBoosted
                            ? AppColors.accent
                            : AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'مستوى الصوت ومضخم الصوت (Audio Boost)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: state.isAudioBoosted
                          ? AppColors.accent
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.volume.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: state.volume,
                min: 0.0,
                max: 200.0,
                activeColor: state.isAudioBoosted
                    ? AppColors.accent
                    : AppColors.primary,
                inactiveColor: Colors.white12,
                onChanged: (val) {
                  widget.playerService.setVolume(val);
                },
              ),
              if (state.isAudioBoosted)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '⚡ تفعيل التضخيم العالي (+12dB Preamp Boost) مع حماية ضد تشويه الصوت (Soft Limiter).',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Night Mode Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.nights_stay_rounded, color: Colors.amberAccent),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوضع الليلي (Night Mode)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'موازنة الصوت: رفع الهمس وخفض الانفجارات المفاجئة',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: state.isNightMode,
                activeTrackColor: Colors.amberAccent,
                activeThumbColor: Colors.white,
                onChanged: (_) {
                  widget.playerService.toggleNightMode();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Audio Delay (Sync) Adjustment
        Container(
          padding: const EdgeInsets.all(16),
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
                  const Text(
                    'تأخير / تقديم الصوت عن الصورة:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${state.audioDelayMs > 0 ? '+' : ''}${state.audioDelayMs} ms',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      widget.playerService
                          .setAudioDelay(state.audioDelayMs - 100);
                    },
                    child: const Text('-100 ms'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      widget.playerService.setAudioDelay(0);
                    },
                    child: const Text('إعادة ضبط (0)'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      widget.playerService
                          .setAudioDelay(state.audioDelayMs + 100);
                    },
                    child: const Text('+100 ms'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Audio Tracks Selection
        if (state.audioTracks.isNotEmpty) ...[
          const Text(
            'المسارات الصوتية المتاحة:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...state.audioTracks.map((track) {
            final isSelected = state.selectedAudioTrack == track;
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.audiotrack,
                color: isSelected ? AppColors.primaryLight : Colors.white54,
              ),
              title: Text(
                track.title ?? track.language ?? 'مسار ${track.id}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primaryLight)
                  : null,
              onTap: () {
                widget.playerService.setAudioTrack(track);
              },
            );
          }),
        ],
      ],
    );
  }
}
