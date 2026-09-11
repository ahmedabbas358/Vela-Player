import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerStateData {
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;
  final double playbackRate;
  final String? currentMediaTitle;
  final List<AudioTrack> audioTracks;
  final AudioTrack? selectedAudioTrack;
  final List<SubtitleTrack> internalSubtitleTracks;
  final SubtitleTrack? selectedSubtitleTrack;

  const PlayerStateData({
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
    this.playbackRate = 1.0,
    this.currentMediaTitle,
    this.audioTracks = const [],
    this.selectedAudioTrack,
    this.internalSubtitleTracks = const [],
    this.selectedSubtitleTrack,
  });

  PlayerStateData copyWith({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    double? playbackRate,
    String? currentMediaTitle,
    List<AudioTrack>? audioTracks,
    AudioTrack? selectedAudioTrack,
    List<SubtitleTrack>? internalSubtitleTracks,
    SubtitleTrack? selectedSubtitleTrack,
  }) {
    return PlayerStateData(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playbackRate: playbackRate ?? this.playbackRate,
      currentMediaTitle: currentMediaTitle ?? this.currentMediaTitle,
      audioTracks: audioTracks ?? this.audioTracks,
      selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
      internalSubtitleTracks:
          internalSubtitleTracks ?? this.internalSubtitleTracks,
      selectedSubtitleTrack:
          selectedSubtitleTrack ?? this.selectedSubtitleTrack,
    );
  }
}

class PlayerService extends ChangeNotifier {
  late final Player player;
  late final VideoController controller;

  PlayerStateData _state = const PlayerStateData();
  PlayerStateData get state => _state;

  final List<StreamSubscription> _subscriptions = [];

  PlayerService() {
    player = Player();
    controller = VideoController(player);
    _initListeners();
  }

  void _initListeners() {
    _subscriptions.add(player.stream.playing.listen((playing) {
      _state = _state.copyWith(isPlaying: playing);
      notifyListeners();
    }));

    _subscriptions.add(player.stream.buffering.listen((buffering) {
      _state = _state.copyWith(isBuffering: buffering);
      notifyListeners();
    }));

    _subscriptions.add(player.stream.position.listen((pos) {
      _state = _state.copyWith(position: pos);
      notifyListeners();
    }));

    _subscriptions.add(player.stream.duration.listen((dur) {
      _state = _state.copyWith(duration: dur);
      notifyListeners();
    }));

    _subscriptions.add(player.stream.volume.listen((vol) {
      _state = _state.copyWith(volume: vol);
      notifyListeners();
    }));

    _subscriptions.add(player.stream.rate.listen((rate) {
      _state = _state.copyWith(playbackRate: rate);
      notifyListeners();
    }));

    _subscriptions.add(player.stream.tracks.listen((tracks) {
      _state = _state.copyWith(
        audioTracks: tracks.audio,
        internalSubtitleTracks: tracks.subtitle,
      );
      notifyListeners();
    }));

    _subscriptions.add(player.stream.track.listen((track) {
      _state = _state.copyWith(
        selectedAudioTrack: track.audio,
        selectedSubtitleTrack: track.subtitle,
      );
      notifyListeners();
    }));
  }

  Future<void> openFile(String path, {String? title}) async {
    _state = _state.copyWith(
      currentMediaTitle: title ?? path.split(RegExp(r'[/\\]')).last,
    );
    notifyListeners();
    await player.open(Media(path));
  }

  Future<void> play() async => await player.play();
  Future<void> pause() async => await player.pause();
  Future<void> playOrPause() async => await player.playOrPause();
  Future<void> seek(Duration position) async => await player.seek(position);

  Future<void> setPlaybackRate(double rate) async {
    await player.setRate(rate);
  }

  Future<void> setVolume(double volume) async {
    // Clamped between 0.0 and 100.0
    await player.setVolume(volume.clamp(0.0, 100.0));
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
