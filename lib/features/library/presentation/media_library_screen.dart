import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../player/presentation/video_player_screen.dart';

/// Supported video extensions
const _videoExtensions = [
  'mp4',
  'mkv',
  'avi',
  'mov',
  'webm',
  'flv',
  'ts',
  '3gp',
];

/// A model for a recently opened video file
class MediaItem {
  final String path;
  final String name;
  final DateTime lastOpened;
  final Duration? lastPosition;
  final Duration? totalDuration;

  MediaItem({
    required this.path,
    required this.name,
    required this.lastOpened,
    this.lastPosition,
    this.totalDuration,
  });
}

/// In-memory recent media provider for MVP (will migrate to Drift/Hive later)
class RecentMediaNotifier extends StateNotifier<List<MediaItem>> {
  RecentMediaNotifier() : super([]);

  void addOrUpdate(MediaItem item) {
    state = [item, ...state.where((m) => m.path != item.path)];
    // Keep at most 50 recent items
    if (state.length > 50) {
      state = state.sublist(0, 50);
    }
  }

  void remove(String path) {
    state = state.where((m) => m.path != path).toList();
  }

  void clearAll() => state = [];
}

final recentMediaProvider =
    StateNotifierProvider<RecentMediaNotifier, List<MediaItem>>((ref) {
      return RecentMediaNotifier();
    });

class MediaLibraryScreen extends ConsumerWidget {
  const MediaLibraryScreen({super.key});

  Future<void> _pickAndPlayVideo(BuildContext context, WidgetRef ref) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _videoExtensions,
    );

    if (files.isNotEmpty && files.first.path != null && context.mounted) {
      final path = files.first.path!;
      final name = files.first.name;

      ref
          .read(recentMediaProvider.notifier)
          .addOrUpdate(
            MediaItem(path: path, name: name, lastOpened: DateTime.now()),
          );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoPath: path, videoTitle: name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentMedia = ref.watch(recentMediaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'مكتبة الوسائط',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (recentMedia.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.white54,
              ),
              tooltip: 'مسح السجل',
              onPressed: () {
                ref.read(recentMediaProvider.notifier).clearAll();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Open file button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.folder_open, size: 20),
                label: const Text(
                  'فتح ملف فيديو',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () => _pickAndPlayVideo(context, ref),
              ),
            ),
          ),

          // Recent media section
          if (recentMedia.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'شوهدت مؤخراً',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recentMedia.length,
                itemBuilder: (context, index) {
                  final item = recentMedia[index];
                  return _buildMediaTile(context, ref, item);
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد مقاطع مشاهَدة حتى الآن',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اضغط "فتح ملف فيديو" للبدء',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaTile(BuildContext context, WidgetRef ref, MediaItem item) {
    final ext = item.name.split('.').last.toUpperCase();

    return Card(
      color: AppColors.surfaceVariant,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              ext,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          _formatTimeAgo(item.lastOpened),
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.play_circle_filled,
                color: AppColors.primaryLight,
              ),
              tooltip: 'تشغيل',
              onPressed: () {
                ref
                    .read(recentMediaProvider.notifier)
                    .addOrUpdate(
                      MediaItem(
                        path: item.path,
                        name: item.name,
                        lastOpened: DateTime.now(),
                      ),
                    );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                      videoPath: item.path,
                      videoTitle: item.name,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white24, size: 18),
              tooltip: 'حذف من السجل',
              onPressed: () {
                ref.read(recentMediaProvider.notifier).remove(item.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
