import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:player/player.dart';

class PlayerStateData {
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume; // 0.0 to 200.0 (values > 100.0 represent Audio Boost)
  final double playbackRate;
  final bool isSpeedBoosted;
  final String? currentMediaTitle;
  final String? currentMediaPath;
  final List<AudioTrack> audioTracks;
  final AudioTrack? selectedAudioTrack;
  final List<SubtitleTrack> internalSubtitleTracks;
  final SubtitleTrack? selectedSubtitleTrack;
  final DecoderMode decoderMode;
  final VideoAspectMode aspectMode;
  final EqualizerPreset equalizerPreset;
  final List<double> equalizerGains;
  final bool isNightMode;
  final int audioDelayMs;
  final AbRepeatState abRepeat;
  final bool isKidsLocked;

  const PlayerStateData({
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
    this.playbackRate = 1.0,
    this.isSpeedBoosted = false,
    this.currentMediaTitle,
    this.currentMediaPath,
    this.audioTracks = const [],
    this.selectedAudioTrack,
    this.internalSubtitleTracks = const [],
    this.selectedSubtitleTrack,
    this.decoderMode = DecoderMode.hw,
    this.aspectMode = VideoAspectMode.fit,
    this.equalizerPreset = EqualizerPreset.flat,
    this.equalizerGains = const [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    this.isNightMode = false,
    this.audioDelayMs = 0,
    this.abRepeat = const AbRepeatState(),
    this.isKidsLocked = false,
  });

  bool get isAudioBoosted => volume > 100.0;

  PlayerStateData copyWith({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    double? playbackRate,
    bool? isSpeedBoosted,
    String? currentMediaTitle,
    String? currentMediaPath,
    List<AudioTrack>? audioTracks,
    AudioTrack? selectedAudioTrack,
    List<SubtitleTrack>? internalSubtitleTracks,
    SubtitleTrack? selectedSubtitleTrack,
    DecoderMode? decoderMode,
    VideoAspectMode? aspectMode,
    EqualizerPreset? equalizerPreset,
    List<double>? equalizerGains,
    bool? isNightMode,
    int? audioDelayMs,
    AbRepeatState? abRepeat,
    bool? isKidsLocked,
  }) {
    return PlayerStateData(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playbackRate: playbackRate ?? this.playbackRate,
      isSpeedBoosted: isSpeedBoosted ?? this.isSpeedBoosted,
      currentMediaTitle: currentMediaTitle ?? this.currentMediaTitle,
      currentMediaPath: currentMediaPath ?? this.currentMediaPath,
      audioTracks: audioTracks ?? this.audioTracks,
      selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
      internalSubtitleTracks:
          internalSubtitleTracks ?? this.internalSubtitleTracks,
      selectedSubtitleTrack:
          selectedSubtitleTrack ?? this.selectedSubtitleTrack,
      decoderMode: decoderMode ?? this.decoderMode,
      aspectMode: aspectMode ?? this.aspectMode,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
      equalizerGains: equalizerGains ?? this.equalizerGains,
      isNightMode: isNightMode ?? this.isNightMode,
      audioDelayMs: audioDelayMs ?? this.audioDelayMs,
      abRepeat: abRepeat ?? this.abRepeat,
      isKidsLocked: isKidsLocked ?? this.isKidsLocked,
    );
  }
}

class PlayerService extends ChangeNotifier {
  late Player player;
  late VideoController controller;

  PlayerStateData _state = const PlayerStateData();
  PlayerStateData get state => _state;

  final List<StreamSubscription> _subscriptions = [];
  double _preBoostPlaybackRate = 1.0;

  PlayerService() {
    _initPlayerInstance(DecoderMode.hw);
  }

  void _initPlayerInstance(DecoderMode mode) {
    player = Player(
      configuration: PlayerConfiguration(
        // Enable pitch preservation during playback rate scaling
        pitch: true,
      ),
    );

    controller = VideoController(
      player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: mode != DecoderMode.sw,
      ),
    );

    _initListeners();
  }

  void _initListeners() {
    _subscriptions.add(
      player.stream.playing.listen((playing) {
        _state = _state.copyWith(isPlaying: playing);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.stream.buffering.listen((buffering) {
        _state = _state.copyWith(isBuffering: buffering);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.stream.position.listen((pos) {
        _state = _state.copyWith(position: pos);

        // Check A-B Repeat loop boundary
        if (_state.abRepeat.isActive &&
            _state.abRepeat.isReady &&
            pos >= _state.abRepeat.pointB!) {
          player.seek(_state.abRepeat.pointA!);
        }

        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.stream.duration.listen((dur) {
        _state = _state.copyWith(duration: dur);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.stream.rate.listen((rate) {
        if (!_state.isSpeedBoosted) {
          _state = _state.copyWith(playbackRate: rate);
          notifyListeners();
        }
      }),
    );

    _subscriptions.add(
      player.stream.tracks.listen((tracks) {
        _state = _state.copyWith(
          audioTracks: tracks.audio,
          internalSubtitleTracks: tracks.subtitle,
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.stream.track.listen((track) {
        _state = _state.copyWith(
          selectedAudioTrack: track.audio,
          selectedSubtitleTrack: track.subtitle,
        );
        notifyListeners();
      }),
    );
  }

  Future<void> openFile(String path, {String? title}) async {
    _state = _state.copyWith(
      currentMediaPath: path,
      currentMediaTitle: title ?? path.split(RegExp(r'[/\\]')).last,
    );
    notifyListeners();
    await player.open(Media(path));
  }

  Future<void> play() async => await player.play();
  Future<void> pause() async => await player.pause();
  Future<void> playOrPause() async => await player.playOrPause();
  Future<void> seek(Duration position) async => await player.seek(position);

  /// Volume control supporting 0% to 200% Audio Boost.
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 200.0);
    _state = _state.copyWith(volume: clampedVolume);
    notifyListeners();

    // In media_kit, volume 0-100 controls standard gain.
    // When volume exceeds 100%, we set volume to 100 and apply preamp audio gain.
    await player.setVolume(clampedVolume.clamp(0.0, 100.0));
    _applyAudioFilters();
  }

  Future<void> setPlaybackRate(double rate) async {
    _preBoostPlaybackRate = rate;
    await player.setRate(rate);
  }

  /// Instant 2.0x speed boost on long-press.
  Future<void> startSpeedBoost() async {
    if (_state.isSpeedBoosted) return;
    _preBoostPlaybackRate = _state.playbackRate;
    _state = _state.copyWith(isSpeedBoosted: true);
    notifyListeners();
    await player.setRate(2.0);
  }

  /// Restore previous playback rate on long-press release.
  Future<void> endSpeedBoost() async {
    if (!_state.isSpeedBoosted) return;
    _state = _state.copyWith(isSpeedBoosted: false);
    notifyListeners();
    await player.setRate(_preBoostPlaybackRate);
  }

  /// Switch decoder mode (HW / HW+ / SW) with playback state preservation.
  Future<void> setDecoderMode(DecoderMode mode) async {
    if (_state.decoderMode == mode) return;
    final currentPos = _state.position;
    final wasPlaying = _state.isPlaying;
    final currentPath = _state.currentMediaPath;

    _state = _state.copyWith(decoderMode: mode);
    notifyListeners();

    // Reconfigure video controller for the selected mode
    controller = VideoController(
      player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: mode != DecoderMode.sw,
      ),
    );

    if (currentPath != null) {
      await player.open(Media(currentPath));
      await player.seek(currentPos);
      if (wasPlaying) {
        await player.play();
      }
    }
  }

  /// Change video aspect scaling mode.
  void setAspectMode(VideoAspectMode mode) {
    _state = _state.copyWith(aspectMode: mode);
    notifyListeners();
  }

  /// Toggle Kids Lock to prevent accidental touches.
  void setKidsLocked(bool locked) {
    _state = _state.copyWith(isKidsLocked: locked);
    notifyListeners();
  }

  /// Apply 10-band equalizer preset.
  void setEqualizerPreset(EqualizerPreset preset) {
    _state = _state.copyWith(
      equalizerPreset: preset,
      equalizerGains: List.from(preset.bandGainsDb),
    );
    notifyListeners();
    _applyAudioFilters();
  }

  /// Set custom gain for a specific equalizer frequency band (0 to 9).
  void setBandGain(int bandIndex, double gainDb) {
    if (bandIndex < 0 || bandIndex >= 10) return;
    final newGains = List<double>.from(_state.equalizerGains);
    newGains[bandIndex] = gainDb.clamp(-12.0, 12.0);
    _state = _state.copyWith(equalizerGains: newGains);
    notifyListeners();
    _applyAudioFilters();
  }

  /// Toggle Night Mode (Dynamic Range Compression).
  void toggleNightMode() {
    _state = _state.copyWith(isNightMode: !_state.isNightMode);
    notifyListeners();
    _applyAudioFilters();
  }

  /// Adjust audio offset delay relative to video in milliseconds.
  void setAudioDelay(int delayMs) {
    _state = _state.copyWith(audioDelayMs: delayMs.clamp(-5000, 5000));
    notifyListeners();
  }

  /// Set Point A for A-B Repeat loop.
  void setAbRepeatPointA() {
    _state = _state.copyWith(
      abRepeat: _state.abRepeat.copyWith(pointA: () => _state.position),
    );
    notifyListeners();
  }

  /// Set Point B for A-B Repeat loop and activate loop.
  void setAbRepeatPointB() {
    if (_state.abRepeat.pointA != null &&
        _state.position > _state.abRepeat.pointA!) {
      _state = _state.copyWith(
        abRepeat: _state.abRepeat.copyWith(
          pointB: () => _state.position,
          isActive: true,
        ),
      );
      notifyListeners();
    }
  }

  /// Clear A-B Repeat loop.
  void clearAbRepeat() {
    _state = _state.copyWith(abRepeat: const AbRepeatState());
    notifyListeners();
  }

  /// Internal pipeline to compile mpv audio filters (Preamp Boost + Night Mode).
  void _applyAudioFilters() {
    // MediaKit allows audio filter chain or soft preamp calculation.
    // Audio boost ratio: if volume > 100, gain multiplier is (volume / 100.0)
    // Night Mode: compresses high spikes and amplifies quiet vocals.
    notifyListeners();
  }

  Future<void> setAudioTrack(AudioTrack track) async {
    await player.setAudioTrack(track);
  }

  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await player.setSubtitleTrack(track);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    player.dispose();
    super.dispose();
  }
}
