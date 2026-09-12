import 'package:ai/ai.dart';
import 'package:subtitle_core/subtitle_core.dart';
import 'package:test/test.dart';

void main() {
  group('ReadabilityGuard Tests', () {
    test(
        'enforces WCAG AAA compliant contrast on bright yellow anime hair color',
        () {
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
    test('preserves timestamps, HTML/ASS tags, and protected glossary terms',
        () async {
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
      expect(translated[0].originalText,
          equals('Hello <i>Rasengan</i> technique!'));
    });
  });

  group('CharacterStylingStudio Tests', () {
    test('stabilizes frame colors and respects manual user locking', () {
      final studio = CharacterStylingStudio();

      const characterId = 'luffy';
      const characterName = 'Luffy';

      // Simulate frame with red shirt and black hair
      final framePixels = [
        0xFF101010, // Hair
        0xFF101010,
        0xFFD32F2F, // Red
      ];

      final palette1 = studio.processCharacterFrame(
        characterId: characterId,
        characterName: characterName,
        characterRegionArgbPixels: framePixels,
        videoBackgroundArgbPixels: [0xFF000000],
      );

      expect(palette1.name, equals('Luffy'));
      expect(studio.isLocked(characterId), isFalse);

      // User manually locks custom gold color
      const customLockedProfile = CharacterProfile(
        characterId: characterId,
        name: characterName,
        hairColorHex: '#FFD700',
        eyeColorHex: '#000000',
        assignedSubtitleColorHex: '#FFD700',
        confidence: 1.0,
      );

      studio.lockProfile(customLockedProfile);
      expect(studio.isLocked(characterId), isTrue);

      // New frame should now return the locked palette
      final palette2 = studio.processCharacterFrame(
        characterId: characterId,
        characterName: characterName,
        characterRegionArgbPixels: framePixels,
        videoBackgroundArgbPixels: [0xFF000000],
      );

      expect(palette2.hairColorHex, equals('#FFD700'));
    });
  });

  group('BurnedInSubtitleOcrEngine Tests', () {
    test('clusters sequential matching OCR detections into single subtitle cue',
        () {
      final detections = [
        const OcrFrameDetection(
          timestampMs: 1000,
          detectedText: 'Welcome to the championship',
          confidence: 0.95,
        ),
        const OcrFrameDetection(
          timestampMs: 1500,
          detectedText: 'Welcome to the championship',
          confidence: 0.98,
        ),
        const OcrFrameDetection(
          timestampMs: 2000,
          detectedText: 'Welcome to the championship',
          confidence: 0.92,
        ),
        const OcrFrameDetection(
          timestampMs: 4000,
          detectedText: 'The match has begun!',
          confidence: 0.90,
        ),
      ];

      final cues = BurnedInSubtitleOcrEngine.clusterDetections(detections);
      expect(cues.length, equals(2));
      expect(cues[0].text, equals('Welcome to the championship'));
      expect(cues[0].startMs, equals(1000));
      expect(cues[0].endMs, equals(2500)); // 2000 + 500
      expect(cues[1].text, equals('The match has begun!'));
      expect(cues[1].startMs, equals(4000));
    });
  });
}
