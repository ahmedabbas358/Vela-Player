import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../subtitles/models/subtitle_style.dart';

/// Manages persistent user preferences using SharedPreferences
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  // ─── Subtitle Style Preferences ───
  static const _keySubFontFamily = 'sub_font_family';
  static const _keySubFontSize = 'sub_font_size';
  static const _keySubTextColor = 'sub_text_color';
  static const _keySubOutlineColor = 'sub_outline_color';
  static const _keySubOutlineWidth = 'sub_outline_width';
  static const _keySubGlowRadius = 'sub_glow_radius';
  static const _keySubShowBgBox = 'sub_show_bg_box';
  static const _keySubVerticalPos = 'sub_vertical_pos';

  // ─── Player Preferences ───
  static const _keyLastPlaybackRate = 'last_playback_rate';
  static const _keyLastVolume = 'last_volume';

  // ─── App Preferences ───
  static const _keyLocaleCode = 'locale_code';

  // ─── Subtitle Style ───

  SubtitleStyle loadSubtitleStyle() {
    return SubtitleStyle(
      fontFamily: _prefs.getString(_keySubFontFamily) ?? 'Cairo',
      fontSize: _prefs.getDouble(_keySubFontSize) ?? 22.0,
      textColor: Color(_prefs.getInt(_keySubTextColor) ?? 0xFFFFFFFF),
      outlineColor: Color(_prefs.getInt(_keySubOutlineColor) ?? 0xFF000000),
      outlineWidth: _prefs.getDouble(_keySubOutlineWidth) ?? 2.5,
      glowRadius: _prefs.getDouble(_keySubGlowRadius) ?? 4.0,
      showBackgroundBox: _prefs.getBool(_keySubShowBgBox) ?? false,
      verticalPositionPercentage: _prefs.getDouble(_keySubVerticalPos) ?? 0.88,
    );
  }

  Future<void> saveSubtitleStyle(SubtitleStyle style) async {
    await _prefs.setString(_keySubFontFamily, style.fontFamily);
    await _prefs.setDouble(_keySubFontSize, style.fontSize);
    await _prefs.setInt(_keySubTextColor, style.textColor.toARGB32());
    await _prefs.setInt(_keySubOutlineColor, style.outlineColor.toARGB32());
    await _prefs.setDouble(_keySubOutlineWidth, style.outlineWidth);
    await _prefs.setDouble(_keySubGlowRadius, style.glowRadius);
    await _prefs.setBool(_keySubShowBgBox, style.showBackgroundBox);
    await _prefs.setDouble(
      _keySubVerticalPos,
      style.verticalPositionPercentage,
    );
  }

  // ─── Player ───

  double get lastPlaybackRate => _prefs.getDouble(_keyLastPlaybackRate) ?? 1.0;
  Future<void> setLastPlaybackRate(double rate) =>
      _prefs.setDouble(_keyLastPlaybackRate, rate);

  double get lastVolume => _prefs.getDouble(_keyLastVolume) ?? 100.0;
  Future<void> setLastVolume(double volume) =>
      _prefs.setDouble(_keyLastVolume, volume);

  // ─── Resume Position (per-file) ───

  Duration? getResumePosition(String fileHash) {
    final ms = _prefs.getInt('resume_$fileHash');
    return ms != null ? Duration(milliseconds: ms) : null;
  }

  Future<void> setResumePosition(String fileHash, Duration position) =>
      _prefs.setInt('resume_$fileHash', position.inMilliseconds);

  // ─── Subtitle Offset Cache (per file pair) ───

  int? getCachedSubOffset(String videoHash, String subHash) {
    return _prefs.getInt('sync_${videoHash}_$subHash');
  }

  Future<void> setCachedSubOffset(
    String videoHash,
    String subHash,
    int offsetMs,
  ) => _prefs.setInt('sync_${videoHash}_$subHash', offsetMs);

  // ─── App Settings ───

  String get localeCode => _prefs.getString(_keyLocaleCode) ?? 'ar';
  Future<void> setLocaleCode(String code) =>
      _prefs.setString(_keyLocaleCode, code);
}

/// Riverpod provider for AppPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences(ref.watch(sharedPreferencesProvider));
});
