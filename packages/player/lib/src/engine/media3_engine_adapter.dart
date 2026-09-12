import 'dart:async';
import 'package:flutter/services.dart';
import '../../models/decoder_mode.dart';
import '../../models/video_aspect_mode.dart';
import 'engine_diagnostics.dart';
import 'playback_engine_type.dart';
import 'vela_playback_engine.dart';

/// Adapter for AndroidX Media3 1.11.0 native ExoPlayer path.
/// Communicates with native Kotlin VelaMediaSessionService via typed platform channels.
class Media3EngineAdapter implements VelaPlaybackEngine {
  static const MethodChannel _channel =
      MethodChannel('com.velaplayer.app/media3_playback');
  static const EventChannel _eventChannel =
      EventChannel('com.velaplayer.app/media3_events');

  final StreamController<Duration> _positionCtrl =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationCtrl =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _isPlayingCtrl =
      StreamController<bool>.broadcast();
  final StreamController<bool> _isBufferingCtrl =
      StreamController<bool>.broadcast();
  final StreamController<double> _volumeCtrl =
      StreamController<double>.broadcast();
  final StreamController<double> _rateCtrl =
      StreamController<double>.broadcast();
  final StreamController<EngineDiagnostics> _diagnosticsCtrl =
      StreamController<EngineDiagnostics>.broadcast();

  StreamSubscription? _eventSub;
  bool _isInitialized = false;

  @override
  PlaybackEngineType get engineType => PlaybackEngineType.media3;

  @override
  Stream<Duration> get positionStream => _positionCtrl.stream;
  @override
  Stream<Duration> get durationStream => _durationCtrl.stream;
  @override
  Stream<bool> get isPlayingStream => _isPlayingCtrl.stream;
  @override
  Stream<bool> get isBufferingStream => _isBufferingCtrl.stream;
  @override
  Stream<double> get volumeStream => _volumeCtrl.stream;
  @override
  Stream<double> get rateStream => _rateCtrl.stream;
  @override
  Stream<EngineDiagnostics> get diagnosticsStream => _diagnosticsCtrl.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _eventSub = _eventChannel.receiveBroadcastStream().listen(
        _onNativeEvent,
        onError: (err) {
          // Fallback or diagnostic logging
        },
      );
      _isInitialized = true;
    } catch (_) {
      // Running on non-Android platform or mock mode
    }
  }

  void _onNativeEvent(dynamic event) {
    if (event is Map) {
      final type = event['type'] as String?;
      switch (type) {
        case 'position':
          final posMs = event['value'] as int? ?? 0;
          _positionCtrl.add(Duration(milliseconds: posMs));
          break;
        case 'duration':
          final durMs = event['value'] as int? ?? 0;
          _durationCtrl.add(Duration(milliseconds: durMs));
          break;
        case 'playbackState':
          final isPlaying = event['isPlaying'] as bool? ?? false;
          final isBuffering = event['isBuffering'] as bool? ?? false;
          _isPlayingCtrl.add(isPlaying);
          _isBufferingCtrl.add(isBuffering);
          break;
      }
    }
  }

  @override
  Future<void> open(String urlOrPath, {bool autoPlay = true}) async {
    try {
      await _channel.invokeMethod('open', {
        'uri': urlOrPath,
        'autoPlay': autoPlay,
      });
    } on MissingPluginException {
      // Fallback
    }
  }

  @override
  Future<void> play() async {
    try {
      await _channel.invokeMethod('play');
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _channel.invokeMethod('pause');
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _channel
          .invokeMethod('seekTo', {'positionMs': position.inMilliseconds});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _volumeCtrl.add(volume);
    try {
      await _channel.invokeMethod('setVolume', {'volume': volume});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> setPlaybackRate(double rate) async {
    _rateCtrl.add(rate);
    try {
      await _channel.invokeMethod('setPlaybackSpeed', {'speed': rate});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> setAudioDelay(int delayMs) async {
    try {
      await _channel.invokeMethod('setAudioDelay', {'delayMs': delayMs});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> setSubtitleDelay(int delayMs) async {
    try {
      await _channel.invokeMethod('setSubtitleDelay', {'delayMs': delayMs});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> setDecoderMode(DecoderMode mode) async {
    try {
      await _channel.invokeMethod('setDecoderMode', {'mode': mode.name});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> setAspectMode(VideoAspectMode mode) async {
    try {
      await _channel.invokeMethod('setAspectMode', {'mode': mode.name});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<bool> enterPictureInPicture() async {
    try {
      final res = await _channel.invokeMethod<bool>('enterPiP');
      return res ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> setAudioPassthrough(bool enabled) async {
    try {
      await _channel.invokeMethod('setAudioPassthrough', {'enabled': enabled});
    } on MissingPluginException {
      // Running on mock or non-Android platform
    }
  }

  @override
  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _positionCtrl.close();
    await _durationCtrl.close();
    await _isPlayingCtrl.close();
    await _isBufferingCtrl.close();
    await _volumeCtrl.close();
    await _rateCtrl.close();
    await _diagnosticsCtrl.close();
  }
}
