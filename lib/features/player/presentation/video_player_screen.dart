import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:player/player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/player/player_service.dart';
import '../../../core/subtitles/subtitle_manager.dart';
import '../../subtitles/presentation/subtitle_overlay.dart';
import '../../subtitles/presentation/subtitle_studio_sheet.dart';
import 'widgets/audio_enhancement_sheet.dart';
import 'widgets/diagnostic_hud_overlay.dart';
import 'widgets/player_settings_sheet.dart';
import 'widgets/subtitle_quick_offset_dialog.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoPath;
  final String? videoTitle;
  final String? initialSubtitlePath;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    this.videoTitle,
    this.initialSubtitlePath,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late final PlayerService _playerService;
  bool _showControls = true;
  bool _showDiagnosticHud = false;
  Timer? _controlsTimer;

  // Gesture indicators
  double? _volumeIndicator;
  double? _brightnessIndicator;
  Duration? _seekDragTarget;
  Timer? _indicatorDismissTimer;

  // Kids lock tap unlock tracker
  int _kidsLockTapCount = 0;
  Timer? _kidsLockResetTimer;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _playerService.addListener(_onPlayerStateChanged);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _playerService.openFile(widget.videoPath, title: widget.videoTitle);
    await _playerService.play();

    if (widget.initialSubtitlePath != null) {
      _loadSubtitleFromFile(widget.initialSubtitlePath!);
    }

    _startControlsTimer();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      ref
          .read(subtitleProvider.notifier)
          .updatePosition(_playerService.state.position);
      setState(() {});
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _playerService.state.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    if (_playerService.state.isKidsLocked) return;

    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  Future<void> _loadSubtitleFromFile(String path) async {
    try {
      final fileName = path.split(RegExp(r'[/\\]')).last;
      final content = await _readSubtitleContent(path);
      if (content != null) {
        ref
            .read(subtitleProvider.notifier)
            .loadContent(content, fileName: fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تحميل ملف الترجمة: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<String?> _readSubtitleContent(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    try {
      return String.fromCharCodes(bytes);
    } catch (_) {
      return await file.readAsString();
    }
  }

  Future<void> _pickExternalSubtitle() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa', 'sub'],
    );

    if (files.isNotEmpty && files.first.path != null) {
      await _loadSubtitleFromFile(files.first.path!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحميل الترجمة: ${files.first.name}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _indicatorDismissTimer?.cancel();
    _kidsLockResetTimer?.cancel();
    _playerService.removeListener(_onPlayerStateChanged);
    _playerService.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  BoxFit _getAspectBoxFit(VideoAspectMode mode) {
    switch (mode) {
      case VideoAspectMode.fit:
        return BoxFit.contain;
      case VideoAspectMode.fill:
        return BoxFit.cover;
      case VideoAspectMode.original:
        return BoxFit.none;
      case VideoAspectMode.ratio16x9:
      case VideoAspectMode.ratio21x9:
        return BoxFit.fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pState = _playerService.state;
    final subState = ref.watch(subtitleProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Core Media Player View with Dynamic Aspect Ratio Scaling
          Center(
            child: FittedBox(
              fit: _getAspectBoxFit(pState.aspectMode),
              child: SizedBox(
                width: pState.aspectMode == VideoAspectMode.ratio16x9
                    ? 1920
                    : (pState.aspectMode == VideoAspectMode.ratio21x9
                        ? 2560
                        : MediaQuery.of(context).size.width),
                height: pState.aspectMode == VideoAspectMode.ratio16x9
                    ? 1080
                    : (pState.aspectMode == VideoAspectMode.ratio21x9
                        ? 1080
                        : MediaQuery.of(context).size.height),
                child: Video(
                  controller: _playerService.controller,
                  controls: NoVideoControls,
                ),
              ),
            ),
          ),

          // 2. Interactive Subtitle Overlay Layer
          const SubtitleOverlay(),

          // 3. Gesture Detector Layer (Double tap seek, volume/brightness/scrubbing, 2.0x long press)
          if (!pState.isKidsLocked) _buildGestureLayer(pState),

          // 4. Center Gesture HUD Indicators (Volume / Seek / 2.0x Speed Boost)
          _buildGestureIndicators(pState),

          // 5. Controls Overlay (Top Bar & Bottom Scrubber)
          if (!pState.isKidsLocked)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: _buildControlsUI(pState, subState),
              ),
            ),

          // 6. Kids Lock Floating Unlock Button
          if (pState.isKidsLocked) _buildKidsLockOverlay(),

          // 7. Developer Diagnostic HUD Mode ("Stats for Nerds")
          if (_showDiagnosticHud)
            DiagnosticHudOverlay(
              playerService: _playerService,
              onClose: () => setState(() => _showDiagnosticHud = false),
            ),
        ],
      ),
    );
  }


  Widget _buildGestureLayer(PlayerStateData pState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          // Long press 2.0x speed boost
          onLongPressStart: (_) => _playerService.startSpeedBoost(),
          onLongPressEnd: (_) => _playerService.endSpeedBoost(),
          onDoubleTapDown: (details) {
            final x = details.localPosition.dx;
            if (x < screenWidth * 0.35) {
              // Double tap left: Rewind 10s
              final newPos = pState.position - const Duration(seconds: 10);
              _playerService.seek(
                newPos < Duration.zero ? Duration.zero : newPos,
              );
              _showSeekHUD(-10);
            } else if (x > screenWidth * 0.65) {
              // Double tap right: Forward 10s
              final newPos = pState.position + const Duration(seconds: 10);
              _playerService.seek(
                newPos > pState.duration ? pState.duration : newPos,
              );
              _showSeekHUD(10);
            } else {
              // Double tap center: Play / Pause
              _playerService.playOrPause();
            }
          },
          onVerticalDragUpdate: (details) {
            final x = details.localPosition.dx;
            final delta = -details.primaryDelta! / screenHeight;

            if (x < screenWidth * 0.5) {
              // Left half: Brightness
              setState(() {
                _brightnessIndicator = ((_brightnessIndicator ?? 0.5) + delta)
                    .clamp(0.0, 1.0);
              });
              _resetIndicatorTimer();
            } else {
              // Right half: Volume (with 200% Audio Boost support!)
              final currentVol = pState.volume;
              final newVol = (currentVol + (delta * 150)).clamp(0.0, 200.0);
              _playerService.setVolume(newVol);
              setState(() {
                _volumeIndicator = newVol;
              });
              _resetIndicatorTimer();
            }
          },
          child: const SizedBox.expand(),
        );
      },
    );
  }

  void _showSeekHUD(int secondsDelta) {
    setState(() {
      _seekDragTarget = _playerService.state.position;
    });
    _resetIndicatorTimer();
  }

  void _resetIndicatorTimer() {
    _indicatorDismissTimer?.cancel();
    _indicatorDismissTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _volumeIndicator = null;
          _brightnessIndicator = null;
          _seekDragTarget = null;
        });
      }
    });
  }

  Widget _buildGestureIndicators(PlayerStateData pState) {
    return Stack(
      children: [
        // 2.0X Speed Boost Floating Badge at top
        if (pState.isSpeedBoosted)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    '2.0X تسريع فوري (Fast-Forward)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Center HUD for Volume / Brightness / Seek
        if (_volumeIndicator != null ||
            _brightnessIndicator != null ||
            _seekDragTarget != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (_volumeIndicator != null && _volumeIndicator! > 100.0)
                      ? AppColors.accent
                      : Colors.white24,
                  width: (_volumeIndicator != null && _volumeIndicator! > 100.0)
                      ? 2
                      : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_volumeIndicator != null) ...[
                    Icon(
                      _volumeIndicator! == 0
                          ? Icons.volume_off
                          : (_volumeIndicator! > 100
                              ? Icons.offline_bolt_rounded
                              : Icons.volume_up),
                      color: _volumeIndicator! > 100
                          ? AppColors.accent
                          : AppColors.primaryLight,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _volumeIndicator! > 100
                          ? 'مضخم الصوت: ${_volumeIndicator!.toInt()}%'
                          : 'الصوت: ${_volumeIndicator!.toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _volumeIndicator! > 100
                            ? AppColors.accent
                            : Colors.white,
                      ),
                    ),
                    if (_volumeIndicator! > 100)
                      const Text(
                        '⚡ +12dB Audio Boost',
                        style: TextStyle(color: AppColors.accent, fontSize: 11),
                      ),
                  ],
                  if (_brightnessIndicator != null) ...[
                    const Icon(Icons.brightness_6,
                        color: Colors.amber, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'السطوع: ${(_brightnessIndicator! * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  if (_seekDragTarget != null) ...[
                    const Icon(
                      Icons.fast_forward,
                      color: AppColors.primaryLight,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_seekDragTarget!),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKidsLockOverlay() {
    return Positioned(
      top: 48,
      right: 20,
      child: GestureDetector(
        onTap: () {
          _kidsLockTapCount++;
          _kidsLockResetTimer?.cancel();
          _kidsLockResetTimer = Timer(const Duration(seconds: 2), () {
            _kidsLockTapCount = 0;
          });

          if (_kidsLockTapCount >= 2) {
            _playerService.setKidsLocked(false);
            _kidsLockTapCount = 0;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إلغاء قفل الأطفال بنجاح'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اضغط مرة أخرى لإلغاء القفل'),
                backgroundColor: Colors.amber,
                duration: Duration(milliseconds: 900),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amberAccent),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, color: Colors.amberAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'قفل الأطفال مفعل (انقر مرتين)',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsUI(PlayerStateData pState, SubtitleState subState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Bar
        Container(
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  pState.currentMediaTitle ?? 'Vela Player',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Decoder badge (HW / HW+ / SW)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary, width: 0.5),
                ),
                child: Text(
                  pState.decoderMode.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),

              // Audio Enhancement Studio (Equalizer + 200% Boost + Night Mode)
              IconButton(
                tooltip: 'استوديو الصوتيات والمعادل',
                icon: Icon(
                  Icons.graphic_eq_rounded,
                  color: pState.isAudioBoosted
                      ? AppColors.accent
                      : AppColors.primaryLight,
                ),
                onPressed: () =>
                    AudioEnhancementSheet.show(context, _playerService),
              ),

              // Player Settings (Aspect, Decoder, A-B, Kids Lock)
              IconButton(
                tooltip: 'إعدادات المشغل وفك الترميز',
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                onPressed: () =>
                    PlayerSettingsSheet.show(context, _playerService),
              ),

              // Open Subtitle Studio button
              IconButton(
                tooltip: 'استوديو تنسيق الترجمة',
                icon: const Icon(
                  Icons.palette_outlined,
                  color: AppColors.primaryLight,
                ),
                onPressed: () => SubtitleStudioSheet.show(context),
              ),

              // Subtitle Sync Offset dialog
              IconButton(
                tooltip: 'مزامنة الترجمة',
                icon: const Icon(Icons.sync, color: Colors.amber),
                onPressed: () => SubtitleQuickOffsetDialog.show(context),
              ),

              // Pick external subtitle
              IconButton(
                tooltip: 'تحميل ملف ترجمة خارجي',
                icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
                onPressed: _pickExternalSubtitle,
              ),

              // Developer Diagnostic HUD Button ("Stats for Nerds")
              IconButton(
                tooltip: 'شاشة تشخيص المطورين (Stats for Nerds)',
                icon: Icon(
                  Icons.terminal_rounded,
                  color: _showDiagnosticHud ? Colors.greenAccent : Colors.white70,
                ),
                onPressed: () =>
                    setState(() => _showDiagnosticHud = !_showDiagnosticHud),
              ),
            ],
          ),
        ),

        // Bottom Controls Bar
        Container(
          padding: const EdgeInsets.only(
            bottom: 24,
            left: 16,
            right: 16,
            top: 12,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrubber Slider
              Row(
                children: [
                  Text(
                    _formatDuration(pState.position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7.0,
                        ),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppColors.primaryLight,
                      ),
                      child: Slider(
                        value: pState.duration.inMilliseconds > 0
                            ? pState.position.inMilliseconds
                                  .clamp(0, pState.duration.inMilliseconds)
                                  .toDouble()
                            : 0.0,
                        max: pState.duration.inMilliseconds.toDouble() > 0
                            ? pState.duration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          _playerService.seek(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(pState.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),

              // Playback controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Play/Pause button and Speed selector
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          pState.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 38,
                          color: AppColors.primaryLight,
                        ),
                        onPressed: () => _playerService.playOrPause(),
                      ),
                      const SizedBox(width: 8),
                      // Playback Speed chip
                      PopupMenuButton<double>(
                        initialValue: pState.playbackRate,
                        tooltip: 'سرعة التشغيل',
                        onSelected: (rate) =>
                            _playerService.setPlaybackRate(rate),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${pState.playbackRate}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        itemBuilder: (context) =>
                            [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0]
                                .map((rate) {
                          return PopupMenuItem(
                            value: rate,
                            child: Text('${rate}x'),
                          );
                        }).toList(),
                      ),

                      if (pState.abRepeat.isActive)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accent),
                          ),
                          child: const Text(
                            'A-B تكرار',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Subtitle visibility toggle & active file name
                  Row(
                    children: [
                      if (subState.fileName != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subState.fileName!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      IconButton(
                        tooltip: subState.isVisible
                            ? 'إخفاء الترجمة'
                            : 'إظهار الترجمة',
                        icon: Icon(
                          subState.isVisible
                              ? Icons.closed_caption
                              : Icons.closed_caption_disabled,
                          color: subState.isVisible
                              ? AppColors.primaryLight
                              : Colors.white38,
                        ),
                        onPressed: () {
                          ref
                              .read(subtitleProvider.notifier)
                              .toggleVisibility();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
