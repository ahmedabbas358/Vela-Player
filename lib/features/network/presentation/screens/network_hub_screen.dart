import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../player/presentation/video_player_screen.dart';
import '../../domain/models/download_task.dart';
import '../../domain/models/network_share.dart';

/// Network Hub Screen:
/// Unified gateway for SMB (NAS), WebDAV, SFTP, DLNA/UPnP, and HTTP/HLS streaming
/// with background Download Manager.
class NetworkHubScreen extends StatefulWidget {
  const NetworkHubScreen({super.key});

  @override
  State<NetworkHubScreen> createState() => _NetworkHubScreenState();
}

class _NetworkHubScreenState extends State<NetworkHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _urlController = TextEditingController();

  final List<NetworkShare> _shares = [
    const NetworkShare(
      id: 'nas_1',
      name: 'Home NAS (Synology SMB)',
      protocol: NetworkProtocol.smb,
      host: '192.168.1.100',
      port: 445,
      path: '/video/Anime',
      username: 'media_user',
      secureStorageKey: 'sec_nas_1',
      isConnected: true,
    ),
    const NetworkShare(
      id: 'cloud_1',
      name: 'Nextcloud Media (WebDAV)',
      protocol: NetworkProtocol.webdav,
      host: 'cloud.example.com',
      port: 443,
      path: '/remote.php/dav/files/user/Movies',
      username: 'ahmed',
      secureStorageKey: 'sec_cloud_1',
      isConnected: false,
    ),
  ];

  final List<DownloadTask> _downloads = [
    DownloadTask(
      id: 'dl_1',
      title: 'Tears of Steel (4K Sci-Fi Short).mp4',
      remoteUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      localDestinationPath: '/storage/emulated/0/Movies/TearsOfSteel.mp4',
      bytesDownloaded: 384000000,
      totalBytes: 540000000,
      speedKbps: 4200.0,
      status: DownloadStatus.downloading,
      wifiOnly: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _playStreamUrl(String url) {
    if (url.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoPath: url.trim(),
          videoTitle: 'بث شبكي مباشر',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14141E),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.hub_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'مركز الشبكات والتنزيل (Network Hub)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.dns_outlined), text: 'خوادم الشبكة'),
            Tab(icon: Icon(Icons.download_rounded), text: 'التنزيلات'),
            Tab(icon: Icon(Icons.link_rounded), text: 'بث مباشر'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSharesTab(),
          _buildDownloadsTab(),
          _buildDirectStreamTab(),
        ],
      ),
    );
  }

  Widget _buildSharesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add Server Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text(
            'إضافة خادم جديد (SMB / WebDAV / SFTP / DLNA)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: _showAddShareDialog,
        ),
        const SizedBox(height: 16),

        // Shares List
        ..._shares.map((share) => _buildShareCard(share)),
      ],
    );
  }

  Widget _buildShareCard(NetworkShare share) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181824),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: share.isConnected
              ? Colors.greenAccent.withValues(alpha: 0.4)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(share.protocol.icon, color: AppColors.primaryLight),
        ),
        title: Text(
          share.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${share.protocol.displayName} • ${share.host}',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: share.isConnected
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.white10,
            foregroundColor: share.isConnected
                ? Colors.greenAccent
                : Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(share.isConnected ? 'متصل' : 'اتصال'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('جارٍ فحص الاتصال بـ ${share.name}...')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDownloadsTab() {
    if (_downloads.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد تنزيلات جارية حالياً.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _downloads.length,
      itemBuilder: (context, i) {
        final task = _downloads[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF181824),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.downloading_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    task.progressPercentage,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: task.progressFraction,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
                minHeight: 4,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(task.speedKbps / 1024).toStringAsFixed(1)} MB/s • واي فاي فقط',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.pause_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectStreamTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'بث رابط فيديو أو صوتي مباشر',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'يدعم روابط MP4، MKV، HLS (.m3u8)، وDASH (.mpd) مع فك تشفير عتادي فوري.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://example.com/video/stream.m3u8',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF181824),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              prefixIcon: const Icon(Icons.link, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'بدء التشغيل المباشر الآن',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _playStreamUrl(_urlController.text),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        title: const Text(
          'إضافة خادم شبكة جديد',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'اختر البروتوكول وأدخل بيانات الاتصال. تُحفظ كلمات المرور مشفرة في Secure Storage بأمان تام.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('إضافة'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
