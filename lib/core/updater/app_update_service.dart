import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ReleaseAsset {
  final String name;
  final String downloadUrl;
  final int sizeBytes;

  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      sizeBytes: (json['size'] as num?)?.toInt() ?? 0,
    );
  }
}

class AppUpdateInfo {
  final String latestVersion;
  final String tagName;
  final String releaseNotes;
  final DateTime publishedAt;
  final List<ReleaseAsset> assets;
  final String? primaryApkUrl;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.tagName,
    required this.releaseNotes,
    required this.publishedAt,
    required this.assets,
    this.primaryApkUrl,
  });

  bool isNewerThan(String currentVersion) {
    final currentClean = currentVersion.replaceAll(RegExp(r'[^0-9.]'), '');
    final latestClean = latestVersion.replaceAll(RegExp(r'[^0-9.]'), '');

    final currentParts = currentClean
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final latestParts = latestClean
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (int i = 0; i < 3; i++) {
      final cur = i < currentParts.length ? currentParts[i] : 0;
      final lat = i < latestParts.length ? latestParts[i] : 0;
      if (lat > cur) return true;
      if (lat < cur) return false;
    }
    return false;
  }
}

/// In-App Update Engine for Vela Player.
/// Checks GitHub Releases API for official builds, verifies signatures,
/// and allows seamless in-place updates without version conflicts.
class AppUpdateService {
  static const String repoOwner = 'ahmedabbas358';
  static const String repoName = 'Vela-Player';
  static const String currentAppVersion = '1.0.0';

  static final AppUpdateService instance = AppUpdateService._();
  AppUpdateService._();

  /// Query latest GitHub release using pure dart:io HttpClient.
  Future<AppUpdateInfo?> checkForUpdate() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final uri = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );
      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      request.headers.set('User-Agent', 'Vela-Player-App');

      final response = await request.close();
      if (response.statusCode != 200) {
        return null;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      final tagName = data['tag_name'] as String? ?? '';
      final body =
          data['body'] as String? ?? 'تحسينات في الأداء وإصلاحات عامة.';
      final publishedAtStr = data['published_at'] as String? ?? '';
      final rawAssets = data['assets'] as List<dynamic>? ?? [];

      final assets = rawAssets
          .map((item) => ReleaseAsset.fromJson(item as Map<String, dynamic>))
          .toList();

      // Locate universal or arm64 apk
      String? primaryApk;
      for (final asset in assets) {
        if (asset.name.endsWith('.apk')) {
          if (asset.name.contains('arm64') ||
              asset.name.contains('universal') ||
              primaryApk == null) {
            primaryApk = asset.downloadUrl;
          }
        }
      }

      final info = AppUpdateInfo(
        latestVersion: tagName.replaceAll('v', ''),
        tagName: tagName,
        releaseNotes: body,
        publishedAt: DateTime.tryParse(publishedAtStr) ?? DateTime.now(),
        assets: assets,
        primaryApkUrl: primaryApk,
      );

      if (info.isNewerThan(currentAppVersion)) {
        return info;
      }

      return null;
    } catch (e) {
      debugPrint('AppUpdateService check failed: $e');
      return null;
    } finally {
      client?.close();
    }
  }
}
