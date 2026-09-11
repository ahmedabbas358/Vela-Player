import 'package:flutter_test/flutter_test.dart';
import 'package:luma_sub/core/updater/app_update_service.dart';

void main() {
  group('AppUpdateInfo Version Comparison', () {
    test('detects newer minor and patch versions', () {
      final update = AppUpdateInfo(
        latestVersion: '1.1.0',
        tagName: 'v1.1.0',
        releaseNotes: 'New feature release',
        publishedAt: DateTime.now(),
        assets: const [],
      );

      expect(update.isNewerThan('1.0.0'), isTrue);
      expect(update.isNewerThan('1.0.9'), isTrue);
      expect(update.isNewerThan('1.1.0'), isFalse);
      expect(update.isNewerThan('1.2.0'), isFalse);
      expect(update.isNewerThan('2.0.0'), isFalse);
    });

    test('detects newer patch versions correctly', () {
      final update = AppUpdateInfo(
        latestVersion: '1.0.1',
        tagName: 'v1.0.1',
        releaseNotes: 'Bug fix release',
        publishedAt: DateTime.now(),
        assets: const [],
      );

      expect(update.isNewerThan('1.0.0'), isTrue);
      expect(update.isNewerThan('1.0.1'), isFalse);
      expect(update.isNewerThan('1.0.2'), isFalse);
    });

    test('handles tag prefixes gracefully', () {
      final update = AppUpdateInfo(
        latestVersion: 'v2.0.0',
        tagName: 'v2.0.0',
        releaseNotes: 'Major redesign',
        publishedAt: DateTime.now(),
        assets: const [],
      );

      expect(update.isNewerThan('v1.9.9'), isTrue);
      expect(update.isNewerThan('2.0.0'), isFalse);
    });
  });
}
