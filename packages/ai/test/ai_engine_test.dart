import 'package:ai/ai.dart';
import 'package:subtitle_core/subtitle_core.dart';
import 'package:test/test.dart';

void main() {
  group('ReadabilityGuard Tests', () {
    test('enforces WCAG AAA compliant contrast on bright yellow anime hair color', () {
      const brightYellowArgb = 0xFFFFEB3B; // Naruto hair color
      final style = ReadabilityGuard.enforceReadability(
        candidateColorArgb: brightYellowArgb,
      );

      expect(style.isWcagAaaCompliant, isTrue);
      expect(style.outlineWidth, greaterThanOrEqualTo(2.0));
      expect(style.outlineColorHex, equals('#000000'));
    });

    test('enforces outline on dark black hair color', () {
      const darkBlackArgb = 0xFF101010; // Luffy hair color
      final style = ReadabilityGuard.enforceReadability(
        candidateColorArgb: darkBlackArgb,
      );

      expect(style.contrastRatio, greaterThanOrEqualTo(4.5));
      expect(style.outlineColorHex, isNotEmpty);
    });
  });

  group('CharacterColorExtractor Tests', () {
    test('extracts dominant color from pixel sample in CIE-L*a*b* space', () {
      // Simulate pixels of green hair (Zoro) with lighting noise
      final pixels = [
        0xFF2E7D32,
        0xFF2E7D32,
        0xFF388E3C,
        0xFF1B5E20,
        0xFFFFFFFF, // Specular shine (should be ignored)
        0xFF050505, // Deep shadow (should be ignored)
      ];

      final profile = CharacterColorExtractor.createCharacterProfile(
        characterId: 'char_zoro',
        characterName: 'Zoro',
        hairPixels: pixels,
        eyePixels: [0xFF1B5E20],
      );

      expect(profile.name, equals('Zoro'));
      expect(profile.hairColorHex, startsWith('#'));
      expect(profile.assignedSubtitleColorHex, startsWith('#'));
    });
  });

  group('ContextAwareTranslationEngine Tests', () {
    test('preserves timestamps, HTML/ASS tags, and protected glossary terms', () async {
      const engine = ContextAwareTranslationEngine(batchSize: 2);

      final originalCues = [
        const UnifiedSubtitleCue(
          id: 'cue_1',
          index: 1,
          startMs: 1000,
          endMs: 4000,
          text: 'Hello <i>Rasengan</i> technique!',
        ),
        const UnifiedSubtitleCue(
          id: 'cue_2',
          index: 2,
          startMs: 4500,
          endMs: 8000,
          text: 'Look at that ninja, Naruto is amazing.',
        ),
      ];

      const glossary = TranslationGlossary({
        'Rasengan': 'راسينغان',
        'Naruto': 'ناروتو',
      });

      final translated = await engine.translateCues(
        sourceCues: originalCues,
        sourceLanguage: 'en',
        targetLanguage: 'ar',
        glossary: glossary,
      );

      expect(translated.length, equals(2));

      // Timestamps must remain identical
      expect(translated[0].startMs, equals(1000));
      expect(translated[0].endMs, equals(4000));
      expect(translated[1].startMs, equals(4500));
      expect(translated[1].endMs, equals(8000));

      // HTML tag <i> must be preserved
      expect(translated[0].text, contains('<i>'));
      expect(translated[0].text, contains('</i>'));

      // Glossary term must be translated according to glossary
      expect(translated[0].text, contains('راسينغان'));
      expect(translated[1].text, contains('ناروتو'));

      // Original text is preserved in originalText field
      expect(translated[0].originalText, equals('Hello <i>Rasengan</i> technique!'));
    });
  });
}
