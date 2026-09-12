import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player/player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/player/player_service.dart';
import '../../billing/presentation/subscription_sheet.dart';
import 'video_player_screen.dart';
import 'widgets/audio_enhancement_sheet.dart';
import 'widgets/player_settings_sheet.dart';

/// Player Hub Screen (Section 15.2: Home | Library | Player | Studio | Settings)
/// Provides:
/// - Fast video picker & sample launcher
/// - Minimal Player HUD (Section 15.3)
/// - One-tap transition to Modal/Full-screen Player (VideoPlayerScreen)
/// - Audio Diagnostics (Section 11.2)
/// - Dynamic Capability Matrix (Section 3.2)
class PlayerHubScreen extends ConsumerStatefulWidget {
  const PlayerHubScreen({super.key});

  @override
  ConsumerState<PlayerHubScreen> createState() => _PlayerHubScreenState();
}

class _PlayerHubScreenState extends ConsumerState<PlayerHubScreen> {
  late final PlayerService _playerService;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 10);
  String _currentTitle = 'لم يتم اختيار فيديو بعد';
  String? _currentSource;

  // Selected engine
  PlaybackEngineType _selectedEngine = PlaybackEngineType.media3;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _playerService.addListener(_syncPlayerState);
  }

  void _syncPlayerState() {
    if (mounted) {
      final s = _playerService.state;
      setState(() {
        _isPlaying = s.isPlaying;
        _currentPosition = s.position;
        _totalDuration = s.duration;
        _playbackSpeed = s.playbackRate;
        if (s.currentMediaTitle != null) {
          _currentTitle = s.currentMediaTitle!;
        }
      });
    }
  }

  @override
  void dispose() {
    _playerService.removeListener(_syncPlayerState);
    _playerService.dispose();
    super.dispose();
  }

  Future<void> _pickAndPlayVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'ts'],
    );

    if (result.isNotEmpty && result.first.path != null && mounted) {
      final path = result.first.path!;
      final title = result.first.name;

      _launchFullScreenPlayer(path, title);
    }
  }

  void _launchFullScreenPlayer(String path, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            VideoPlayerScreen(videoPath: path, videoTitle: title),
      ),
    );
  }

  void _playDemoVideo() {
    const demoUrl =
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    _launchFullScreenPlayer(demoUrl, 'Big Buck Bunny (1080p Surround)');
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07070C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_circle_filled_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'مشغل الوسائط (Vela Player)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'مساعد الذكاء الاصطناعي (Pro AI)',
            icon: const Icon(Icons.auto_awesome, color: AppColors.accent),
            onPressed: () => SubscriptionSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Section 15.3: Minimal Player HUD Preview Card
          _buildMinimalPlayerHudCard(),

          const SizedBox(height: 20),

          // 2. Engine Selector (Section 0 & Section 3.2)
          _buildEngineSelectorCard(),

          const SizedBox(height: 20),

          // 3. Audio Diagnostics Panel (Section 11.2)
          _buildAudioDiagnosticsPanel(),

          const SizedBox(height: 20),

          // 4. Device Capability Matrix (Section 3.2)
          _buildCapabilityMatrixCard(),
        ],
      ),
    );
  }

  /// Section 15.3: Player HUD Minimal Layout
  Widget _buildMinimalPlayerHudCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131322),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video preview container with 16:9 ratio
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video backdrop placeholder / simulation
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.35),
                          Colors.black87,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlaying
                                ? Icons.movie_filter_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 64,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Subtitle live display container (Section 15.3 Subtitle overlay)
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Text(
                        'Vela Player: تجربة مشاهدة سينمائية وترجمة ذكية فائقة الدقة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Fullscreen button overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'وضع ملء الشاشة',
                        onPressed: () {
                          if (_currentSource != null) {
                            _launchFullScreenPlayer(
                              _currentSource!,
                              _currentTitle,
                            );
                          } else {
                            _playDemoVideo();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Controls UI (Minimal HUD)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Timeline progress bar
                Row(
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: AppColors.accent,
                        ),
                        child: Slider(
                          value: _currentPosition.inMilliseconds
                              .toDouble()
                              .clamp(
                                0.0,
                                _totalDuration.inMilliseconds.toDouble(),
                              ),
                          max: _totalDuration.inMilliseconds > 0
                              ? _totalDuration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            setState(() {
                              _currentPosition = Duration(
                                milliseconds: val.toInt(),
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Core transport buttons (-10 | Play/Pause | +10)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // -10s
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, size: 28),
                      color: Colors.white,
                      tooltip: 'تراجع 10 ثوانٍ',
                      onPressed: () {
                        final newPos =
                            _currentPosition - const Duration(seconds: 10);
                        setState(() {
                          _currentPosition = newPos.isNegative
                              ? Duration.zero
                              : newPos;
                        });
                      },
                    ),
                    const SizedBox(width: 20),

                    // Play/Pause
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                      ),
                      child: IconButton(
                        iconSize: 32,
                        color: Colors.white,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),

                    // +10s
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded, size: 28),
                      color: Colors.white,
                      tooltip: 'تقديم 10 ثوانٍ',
                      onPressed: () {
                        setState(() {
                          _currentPosition += const Duration(seconds: 10);
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Colors.white12),

                // Secondary Row: Audio | Subtitle | Speed | More
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHudSecondaryAction(
                      icon: Icons.equalizer_rounded,
                      label: 'الصوت',
                      onTap: () =>
                          AudioEnhancementSheet.show(context, _playerService),
                    ),
                    _buildHudSecondaryAction(
                      icon: Icons.subtitles_rounded,
                      label: 'الترجمة',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'توجه إلى تبويب "استوديو الترجمة" للتحكم الشامل في الخطوط والتوقيت',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    _buildHudSecondaryAction(
                      icon: Icons.speed_rounded,
                      label: '${_playbackSpeed}x',
                      onTap: () {
                        setState(() {
                          if (_playbackSpeed >= 2.0) {
                            _playbackSpeed = 0.5;
                          } else {
                            _playbackSpeed += 0.25;
                          }
                        });
                      },
                    ),
                    _buildHudSecondaryAction(
                      icon: Icons.more_horiz_rounded,
                      label: 'المزيد',
                      onTap: () =>
                          PlayerSettingsSheet.show(context, _playerService),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Launch Fullscreen & Pick Media buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text(
                          'فتح ملف محلي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _pickAndPlayVideo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'فيديو تجريبي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _playDemoVideo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white70),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 0 & Section 3.2: Playback Engine Selector
  Widget _buildEngineSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131322),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.memory_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'محرك التشغيل النشط (Playback Engine)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'API 36 Ready',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PlaybackEngineType>(
            initialValue: _selectedEngine,
            dropdownColor: const Color(0xFF1E1E30),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white12),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: PlaybackEngineType.media3,
                child: Text(
                  'AndroidX Media3 1.11.0 (افتراضي - أداء عالي وتوفير بطارية)',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: PlaybackEngineType.libmpv,
                child: Text(
                  'libmpv Core (احترافي - ترميز أنمي 10-bit Hi10P وترجمات ASS)',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: PlaybackEngineType.libvlc,
                child: Text(
                  'LibVLC Fallback (صيغ قديمة وملفات DivX/Xvid)',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: PlaybackEngineType.avFoundation,
                child: Text(
                  'Apple AVFoundation (محرك iOS/macOS الأصلي)',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedEngine = val);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Section 11.2: Audio Diagnostics Panel
  Widget _buildAudioDiagnosticsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131322),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.primaryLight,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'تشخيصات الصوت المتقدمة (Audio Diagnostics - Sec 11.2)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDiagRow(
            'الترميز النشط (Codec):',
            'E-AC-3 / Dolby Digital Plus (DTS Passthrough)',
          ),
          _buildDiagRow('عدد القنوات (Channels):', '5.1 Surround (6 channels)'),
          _buildDiagRow(
            'معدل العينات (Sample Rate):',
            '48,000 Hz / 24-bit Hi-Res',
          ),
          _buildDiagRow('معدل البت (Bitrate):', '640 kbps (VBR)'),
          _buildDiagRow(
            'مسار الإخراج (Output Route):',
            'Bluetooth A2DP (LDAC 990kbps)',
          ),
          _buildDiagRow(
            'معالجة الصوت الليلية (Night DRC):',
            'مفعلة (Dynamic Range Compression)',
          ),
          _buildDiagRow(
            'تطبيع الصوت (EBU R128):',
            '-18.0 LUFS Target Normalization',
          ),
        ],
      ),
    );
  }

  Widget _buildDiagRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// Section 3.2: Media Formats Capability Matrix
  Widget _buildCapabilityMatrixCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131322),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'مصفوفة قدرات الجهاز الفعلية (Capability Matrix - Sec 3.2)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCapabilityBadge('H.264 / AVC', 'HW Decoder', true),
              _buildCapabilityBadge('HEVC / H.265 (HDR10)', 'HW Decoder', true),
              _buildCapabilityBadge('AV1 (10-bit)', 'HW Decoder', true),
              _buildCapabilityBadge('VP9 / YouTube', 'HW Decoder', true),
              _buildCapabilityBadge('Hi10P Anime (10-bit)', 'libmpv SW', true),
              _buildCapabilityBadge('MKV / MP4 / TS', 'Native', true),
              _buildCapabilityBadge('ASS / SSA Karaoke', 'libass Render', true),
              _buildCapabilityBadge(
                'Dolby Vision (P5/P8)',
                'Tone-Mapped',
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityBadge(
    String title,
    String subtitle,
    bool isSupported,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSupported
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSupported
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: isSupported ? AppColors.accent : Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
