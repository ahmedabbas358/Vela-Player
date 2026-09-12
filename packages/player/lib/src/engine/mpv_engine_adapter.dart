import 'dart:async';
import '../../models/decoder_mode.dart';
import '../../models/video_aspect_mode.dart';
import 'engine_diagnostics.dart';
import 'playback_engine_type.dart';
import 'vela_playback_engine.dart';

/// Abstract bridge for libmpv engine delegates.
abstract class MpvPlayerDelegate {
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get isPlayingStream;
  Stream<bool> get isBufferingStream;

  Future<void> open(String url, {bool autoPlay = true});
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setRate(double rate);
  Future<void> dispose();
}

/// Fallback / Mock delegate when libmpv is running without native binary hooks.
class DefaultMpvPlayerDelegate implements MpvPlayerDelegate {
  final StreamController<Duration> _posCtrl =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durCtrl =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playCtrl = StreamController<bool>.broadcast();
  final StreamController<bool> _buffCtrl = StreamController<bool>.broadcast();

  @override
  Stream<Duration> get positionStream => _posCtrl.stream;
  @override
  Stream<Duration> get durationStream => _durCtrl.stream;
  @override
  Stream<bool> get isPlayingStream => _playCtrl.stream;
  @override
  Stream<bool> get isBufferingStream => _buffCtrl.stream;

  @override
  Future<void> open(String url, {bool autoPlay = true}) async {
    _playCtrl.add(autoPlay);
  }

  @override
  Future<void> play() async => _playCtrl.add(true);
  @override
  Future<void> pause() async => _playCtrl.add(false);
  @override
  Future<void> stop() async => _playCtrl.add(false);
  @override
  Future<void> seek(Duration position) async => _posCtrl.add(position);
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> setRate(double rate) async {}

  @override
  Future<void> dispose() async {
    await _posCtrl.close();
    await _durCtrl.close();
    await _playCtrl.close();
    await _buffCtrl.close();
  }
}

/// libmpv fallback engine adapter for 10-bit Hi10P anime and complex ASS subtitles.
class MpvEngineAdapter implements VelaPlaybackEngine {
  final MpvPlayerDelegate _delegate;
  final StreamController<double> _volumeCtrl =
      StreamController<double>.broadcast();
  final StreamController<double> _rateCtrl =
      StreamController<double>.broadcast();
  final StreamController<EngineDiagnostics> _diagnosticsCtrl =
      StreamController<EngineDiagnostics>.broadcast();

  MpvEngineAdapter([MpvPlayerDelegate? delegate])
      : _delegate = delegate ?? DefaultMpvPlayerDelegate();

  @override
  PlaybackEngineType get engineType => PlaybackEngineType.libmpv;

  @override
  Stream<Duration> get positionStream => _delegate.positionStream;
  @override
  Stream<Duration> get durationStream => _delegate.durationStream;
  @override
  Stream<bool> get isPlayingStream => _delegate.isPlayingStream;
  @override
  Stream<bool> get isBufferingStream => _delegate.isBufferingStream;
  @override
  Stream<double> get volumeStream => _volumeCtrl.stream;
  @override
  Stream<double> get rateStream => _rateCtrl.stream;
  @override
  Stream<EngineDiagnostics> get diagnosticsStream => _diagnosticsCtrl.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> open(String urlOrPath, {bool autoPlay = true}) async {
    await _delegate.open(urlOrPath, autoPlay: autoPlay);
  }

  @override
  Future<void> play() async => await _delegate.play();

  @override
  Future<void> pause() async => await _delegate.pause();

  @override
  Future<void> stop() async => await _delegate.stop();

  @override
  Future<void> seek(Duration position) async => await _delegate.seek(position);

  @override
  Future<void> setVolume(double volume) async {
    _volumeCtrl.add(volume);
    await _delegate.setVolume(volume.clamp(0.0, 100.0));
  }

  @override
  Future<void> setPlaybackRate(double rate) async {
    _rateCtrl.add(rate);
    await _delegate.setRate(rate);
  }

  @override
  Future<void> setAudioDelay(int delayMs) async {}

  @override
  Future<void> setSubtitleDelay(int delayMs) async {}

  @override
  Future<void> setDecoderMode(DecoderMode mode) async {}

  @override
  Future<void> setAspectMode(VideoAspectMode mode) async {}

  @override
  Future<bool> enterPictureInPicture() async => false;

  @override
  Future<void> setAudioPassthrough(bool enabled) async {}

  @override
  Future<void> dispose() async {
    await _delegate.dispose();
    await _volumeCtrl.close();
    await _rateCtrl.close();
    await _diagnosticsCtrl.close();
  }
}
