import '../models/unified_subtitle_cue.dart';

class SubtitleCleanupResult {
  final List<UnifiedSubtitleCue> cleanedCues;
  final int removedMusicCuesCount;
  final int cleanedSdhTagsCount;
  final int trimmedWhitespaceCount;

  const SubtitleCleanupResult({
    required this.cleanedCues,
    required this.removedMusicCuesCount,
    required this.cleanedSdhTagsCount,
    required this.trimmedWhitespaceCount,
  });
}

/// Subtitle Cleanup Engine: Detects and filters out non-speech sound effects (SDH),
/// musical notes (♪, ♫), and extraneous metadata to give viewers a clean, distraction-free experience.
class SubtitleCleanupEngine {
  // Regex to match purely musical notes or lyrics markers
  static final RegExp _musicSymbolsRegex = RegExp(r'[♪♫#]+');

  // Regex to match sound effect brackets like [Music], [Applause], (Door opens), [Gunshot]
  // Note: Avoids speaker names like [Alice] by checking for common SFX keywords
  static final RegExp _soundEffectBracketRegex = RegExp(
    r'(\[[^\]]*(music|applause|cheering|laughter|sighs|groans|screams|cough|footsteps|whisper|door|thunder|bell|gasp|upbeat|singing|موسيقى|ضحك|تصفيق|بكاء|صراخ)[^\]]*\]|\([^\)]*(music|applause|cheering|laughter|sighs|groans|screams|cough|footsteps|whisper|door|thunder|bell|gasp|upbeat|singing|موسيقى|ضحك|تصفيق|بكاء|صراخ)[^\)]*\))',
    caseSensitive: false,
  );

  /// Cleans and optimizes a list of subtitle cues.
  static SubtitleCleanupResult cleanCues(
    List<UnifiedSubtitleCue> cues, {
    bool removeMusicSymbols = true,
    bool removeSoundEffects = true,
    bool removeEmptyCuesAfterClean = true,
  }) {
    final List<UnifiedSubtitleCue> cleanedList = [];
    int removedMusicCount = 0;
    int cleanedSdhCount = 0;
    int trimmedWhitespace = 0;

    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      var text = cue.text;

      // 1. Clean music symbols
      if (removeMusicSymbols && (text.contains('♪') || text.contains('♫'))) {
        text = text.replaceAll(_musicSymbolsRegex, '').trim();
        removedMusicCount++;
      }

      // 2. Clean sound effects
      if (removeSoundEffects && _soundEffectBracketRegex.hasMatch(text)) {
        text = text.replaceAll(_soundEffectBracketRegex, '').trim();
        cleanedSdhCount++;
      }

      // 3. Clean consecutive spaces or stray hyphens
      final originalLength = text.length;
      text = text
          .replaceAll(RegExp(r'\n{2,}'), '\n')
          .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
          .trim();
      if (text.length != originalLength) {
        trimmedWhitespace++;
      }

      // 4. Check if cue became completely empty
      if (removeEmptyCuesAfterClean && text.isEmpty) {
        continue; // Skip empty cue
      }

      cleanedList.add(cue.copyWith(
        index: cleanedList.length + 1,
        text: text,
      ));
    }

    return SubtitleCleanupResult(
      cleanedCues: cleanedList,
      removedMusicCuesCount: removedMusicCount,
      cleanedSdhTagsCount: cleanedSdhCount,
      trimmedWhitespaceCount: trimmedWhitespace,
    );
  }
}
