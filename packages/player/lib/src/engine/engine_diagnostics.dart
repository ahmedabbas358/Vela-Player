import 'playback_engine_type.dart';
import '../../models/decoder_mode.dart';

/// Real-time diagnostic telemetry and statistics ("Stats for Nerds") in Vela Player.
class EngineDiagnostics {
  final PlaybackEngineType engine;
  final DecoderMode decoderMode;
  final String videoCodec;
  final String audioCodec;
  final String containerFormat;
  final int videoWidth;
  final int videoHeight;
  final double fps;
  final int droppedFrames;
  final double videoBitrateMbps;
  final int bufferDurationMs;
  final String audioRoute;
  final int subtitleLatencyMs;
  final String hdrFormat;
  final String thermalState;
  final bool isHardwareAccelerated;
  final double cpuUsagePercent;
  final double memoryUsageMb;

  const EngineDiagnostics({
    this.engine = PlaybackEngineType.media3,
    this.decoderMode = DecoderMode.hw,
    this.videoCodec = 'HEVC / H.265 (Main10)',
    this.audioCodec = 'DTS-HD MA 5.1',
    this.containerFormat = 'Matroska (MKV)',
    this.videoWidth = 3840,
    this.videoHeight = 2160,
    this.fps = 60.0,
    this.droppedFrames = 0,
    this.videoBitrateMbps = 18.5,
    this.bufferDurationMs = 8500,
    this.audioRoute = 'Direct Passthrough (HDMI / USB-C)',
    this.subtitleLatencyMs = 2,
    this.hdrFormat = 'HDR10 (SMPTE ST 2086)',
    this.thermalState = 'Nominal / Cool',
    this.isHardwareAccelerated = true,
    this.cpuUsagePercent = 4.2,
    this.memoryUsageMb = 142.0,
  });

  String get resolutionString => '${videoWidth}x$videoHeight';

  String get playbackCompatibilityScore {
    if (isHardwareAccelerated && droppedFrames == 0) {
      return 'ممتاز (Hardware 4K HDR)';
    } else if (droppedFrames < 10) {
      return 'جيد جداً (Smooth)';
    } else {
      return 'يحتاج تحسين فك التشفير (Software Fallback)';
    }
  }

  EngineDiagnostics copyWith({
    PlaybackEngineType? engine,
    DecoderMode? decoderMode,
    String? videoCodec,
    String? audioCodec,
    String? containerFormat,
    int? videoWidth,
    int? videoHeight,
    double? fps,
    int? droppedFrames,
    double? videoBitrateMbps,
    int? bufferDurationMs,
    String? audioRoute,
    int? subtitleLatencyMs,
    String? hdrFormat,
    String? thermalState,
    bool? isHardwareAccelerated,
    double? cpuUsagePercent,
    double? memoryUsageMb,
  }) {
    return EngineDiagnostics(
      engine: engine ?? this.engine,
      decoderMode: decoderMode ?? this.decoderMode,
      videoCodec: videoCodec ?? this.videoCodec,
      audioCodec: audioCodec ?? this.audioCodec,
      containerFormat: containerFormat ?? this.containerFormat,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
      fps: fps ?? this.fps,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      videoBitrateMbps: videoBitrateMbps ?? this.videoBitrateMbps,
      bufferDurationMs: bufferDurationMs ?? this.bufferDurationMs,
      audioRoute: audioRoute ?? this.audioRoute,
      subtitleLatencyMs: subtitleLatencyMs ?? this.subtitleLatencyMs,
      hdrFormat: hdrFormat ?? this.hdrFormat,
      thermalState: thermalState ?? this.thermalState,
      isHardwareAccelerated:
          isHardwareAccelerated ?? this.isHardwareAccelerated,
      cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
      memoryUsageMb: memoryUsageMb ?? this.memoryUsageMb,
    );
  }
}
