import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/player/player_service.dart';
import '../../../core/subtitles/subtitle_manager.dart';
import '../../subtitles/presentation/subtitle_overlay.dart';
import '../../subtitles/presentation/subtitle_studio_sheet.dart';
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
  Timer? _controlsTimer;

  // Gesture indicators
  double? _volumeIndicator;
  double? _brightnessIndicator;
  Duration? _seekDragTarget;
  Timer? _indicatorDismissTimer;

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
        _showSnackBar('تم تحميل الترجمة: $fileName');
      }
    } catch (e) {
      _showSnackBar('خطأ في تحميل ملف الترجمة: $e');
    }
  }

  Future<String?> _readSubtitleContent(String path) async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickExternalSubtitle() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa'],
    );

    if (files.isNotEmpty && files.first.path != null) {
      final path = files.first.path!;
      final content = await _readSubtitleContent(path);
      if (content != null) {
        ref
            .read(subtitleProvider.notifier)
            .loadContent(content, fileName: files.first.name);
        _showSnackBar('تم تحميل الترجمة: ${files.first.name}');
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _indicatorDismissTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final pState = _playerService.state;
    final subState = ref.watch(subtitleProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Core Media Player View
          Center(
            child: Video(
              controller: _playerService.controller,
              controls: NoVideoControls,
            ),
          ),

          // 2. Interactive Subtitle Overlay Layer
          const SubtitleOverlay(),

          // 3. Gesture Detector Layer (Double tap seek, drags for volume/brightness/scrubbing)
          _buildGestureLayer(pState),

          // 4. Center Gesture HUD Indicators (Volume / Seek)
          _buildGestureIndicators(),

          // 5. Controls Overlay (Top Bar & Bottom Scrubber)
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: _buildControlsUI(pState, subState),
            ),
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
              // Right half: Volume
              final currentVol = pState.volume;
              final newVol = (currentVol + (delta * 100)).clamp(0.0, 100.0);
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

  Widget _buildGestureIndicators() {
    if (_volumeIndicator == null &&
        _brightnessIndicator == null &&
        _seekDragTarget == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_volumeIndicator != null) ...[
              Icon(
                _volumeIndicator! == 0 ? Icons.volume_off : Icons.volume_up,
                color: AppColors.primaryLight,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                'الصوت: ${_volumeIndicator!.toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
            if (_brightnessIndicator != null) ...[
              const Icon(Icons.brightness_6, color: Colors.amber, size: 36),
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
                size: 36,
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
                  pState.currentMediaTitle ?? 'LumaSub Player',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                  // Play/Pause button
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
                            [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((rate) {
                              return PopupMenuItem(
                                value: rate,
                                child: Text('${rate}x'),
                              );
                            }).toList(),
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
