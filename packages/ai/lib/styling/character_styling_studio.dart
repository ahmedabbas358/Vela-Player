import '../models/character_palette.dart';
import 'character_color_extractor.dart';
import 'readability_guard.dart';

/// Temporal history buffer to stabilize detected character colors across consecutive frames.
class CharacterTemporalFilter {
  final Map<String, List<int>> _colorHistory = {};
  static const int maxWindowSize = 5;

  /// Smooth and stabilize color across a window of frames to prevent visual flicker.
  int filterColor(String characterId, int detectedArgb) {
    final history = _colorHistory.putIfAbsent(characterId, () => []);
    history.add(detectedArgb);
    if (history.length > maxWindowSize) {
      history.removeAt(0);
    }

    // Weighted average giving more weight to recent consistent frames
    double rSum = 0, gSum = 0, bSum = 0, totalWeight = 0;
    for (int i = 0; i < history.length; i++) {
      final weight = (i + 1).toDouble();
      final argb = history[i];
      rSum += ((argb >> 16) & 0xFF) * weight;
      gSum += ((argb >> 8) & 0xFF) * weight;
      bSum += (argb & 0xFF) * weight;
      totalWeight += weight;
    }

    final r = (rSum / totalWeight).round().clamp(0, 255);
    final g = (gSum / totalWeight).round().clamp(0, 255);
    final b = (bSum / totalWeight).round().clamp(0, 255);

    return (0xFF << 24) | (r << 16) | (g << 8) | b;
  }

  void clear() => _colorHistory.clear();
}

/// Character Styling Studio: AI-powered character palette extraction
/// with temporal stabilization, user lock capability, and strict Readability Guard.
class CharacterStylingStudio {
  final CharacterTemporalFilter _temporalFilter = CharacterTemporalFilter();
  final Map<String, CharacterProfile> _lockedProfiles = {};

  /// Lock a character's profile manually by user so AI never overrides it.
  void lockProfile(CharacterProfile profile) {
    _lockedProfiles[profile.characterId] = profile;
  }

  void unlockProfile(String characterId) {
    _lockedProfiles.remove(characterId);
  }

  bool isLocked(String characterId) => _lockedProfiles.containsKey(characterId);

  /// Process candidate frame pixels for a character and produce a guaranteed readable style.
  CharacterProfile processCharacterFrame({
    required String characterId,
    required String characterName,
    required List<int> characterRegionArgbPixels,
    required List<int> videoBackgroundArgbPixels,
  }) {
    // 1. If user locked this profile, return the locked version immediately
    if (_lockedProfiles.containsKey(characterId)) {
      return _lockedProfiles[characterId]!;
    }

    // 2. Extract profile via CharacterColorExtractor
    final rawProfile = CharacterColorExtractor.createCharacterProfile(
      characterId: characterId,
      characterName: characterName,
      hairPixels: characterRegionArgbPixels,
      eyePixels: characterRegionArgbPixels.isNotEmpty
          ? [characterRegionArgbPixels.first]
          : const [0xFF00E5FF],
    );

    // 3. Apply temporal stabilization to hair color
    final hairArgb = _hexToArgb(rawProfile.hairColorHex ?? '#FFFFFF');
    final stableHairArgb = _temporalFilter.filterColor(characterId, hairArgb);

    // 4. Sample background luminance to calculate outline and contrast
    int estimatedBackgroundArgb = 0xFF000000;
    if (videoBackgroundArgbPixels.isNotEmpty) {
      int rAcc = 0, gAcc = 0, bAcc = 0;
      final step =
          (videoBackgroundArgbPixels.length / 50).ceil().clamp(1, 1000);
      int count = 0;
      for (int i = 0; i < videoBackgroundArgbPixels.length; i += step) {
        final argb = videoBackgroundArgbPixels[i];
        rAcc += (argb >> 16) & 0xFF;
        gAcc += (argb >> 8) & 0xFF;
        bAcc += argb & 0xFF;
        count++;
      }
      if (count > 0) {
        final r = (rAcc / count).round().clamp(0, 255);
        final g = (gAcc / count).round().clamp(0, 255);
        final b = (bAcc / count).round().clamp(0, 255);
        estimatedBackgroundArgb = (0xFF << 24) | (r << 16) | (g << 8) | b;
      }
    }

    // 5. Enforce Readability Guard (WCAG AAA 7:1)
    final styleSpec = ReadabilityGuard.enforceReadability(
      candidateColorArgb: stableHairArgb,
      estimatedBackgroundArgb: estimatedBackgroundArgb,
    );

    return CharacterProfile(
      characterId: characterId,
      name: characterName,
      hairColorHex: _argbToHex(stableHairArgb),
      eyeColorHex: rawProfile.eyeColorHex,
      clothingColorHex: rawProfile.clothingColorHex,
      assignedSubtitleColorHex: styleSpec.primaryColorHex,
      confidence: 0.95,
    );
  }

  static int _hexToArgb(String hex) {
    var clean = hex.replaceAll('#', '').toUpperCase();
    if (clean.length == 6) clean = 'FF$clean';
    return int.tryParse(clean, radix: 16) ?? 0xFFFFFFFF;
  }

  static String _argbToHex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}
