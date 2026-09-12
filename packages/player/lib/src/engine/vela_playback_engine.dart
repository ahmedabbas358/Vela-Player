import 'dart:async';
import '../../models/decoder_mode.dart';
import '../../models/video_aspect_mode.dart';
import 'engine_diagnostics.dart';
import 'playback_engine_type.dart';

/// Platform-agnostic unified contract that any playback engine adapter
/// (Media3, AVFoundation, libmpv, libVLC) must satisfy.
abstract class VelaPlaybackEngine {
  PlaybackEngineType get engineType;

  // Streams
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get isPlayingStream;
  Stream<bool> get isBufferingStream;
  Stream<double> get volumeStream;
  Stream<double> get rateStream;
  Stream<EngineDiagnostics> get diagnosticsStream;

  // Lifecycle
  Future<void> initialize();
  Future<void> open(String urlOrPath, {bool autoPlay = true});
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();

  // Playback parameters
  Future<void> setVolume(
      double volume); // 0.0 to 200.0 (Preamp Boost above 100)
  Future<void> setPlaybackRate(double rate);
  Future<void> setAudioDelay(int delayMs);
  Future<void> setSubtitleDelay(int delayMs);
  Future<void> setDecoderMode(DecoderMode mode);
  Future<void> setAspectMode(VideoAspectMode mode);

  // Picture-in-Picture & Background
  Future<bool> enterPictureInPicture();
  Future<void> setAudioPassthrough(bool enabled);
}
