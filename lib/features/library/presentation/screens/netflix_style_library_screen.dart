import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../player/presentation/video_player_screen.dart';
import '../../domain/models/media_category.dart';
import '../../domain/models/media_item.dart';

/// Modern Netflix-grade Media Library Screen:
/// Features hero backdrop banner, continue watching progress, category carousels,
/// and local-first privacy architecture.
class NetflixStyleLibraryScreen extends ConsumerStatefulWidget {
  const NetflixStyleLibraryScreen({super.key});

  @override
  ConsumerState<NetflixStyleLibraryScreen> createState() =>
      _NetflixStyleLibraryScreenState();
}

class _NetflixStyleLibraryScreenState
    extends ConsumerState<NetflixStyleLibraryScreen> {
  MediaCategory _selectedCategory = MediaCategory.home;
  late List<MediaItem> _libraryItems;

  @override
  void initState() {
    super.initState();
    _libraryItems = List.from(SampleMediaLibrary.items);
  }

  Future<void> _pickAndAddLocalVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'ts'],
    );

    if (result.isNotEmpty && result.first.path != null) {
      final file = result.first;
      final newItem = MediaItem(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        title: file.name,
        filePathOrUrl: file.path!,
        type: file.name.toLowerCase().contains('anime')
            ? MediaType.anime
            : MediaType.movie,
        durationMs: 7200000, // Estimated 2 hours
        addedAt: DateTime.now(),
      );

      setState(() {
        _libraryItems.insert(0, newItem);
      });

      if (mounted) {
        _playMediaItem(newItem);
      }
    }
  }

  void _playMediaItem(MediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoPath: item.filePathOrUrl,
          videoTitle: item.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroItem = _libraryItems.firstWhere(
      (item) => item.backdropPath != null,
      orElse: () => _libraryItems.first,
    );

    final continueWatching = _libraryItems
        .where((item) => item.hasStartedWatching)
        .toList();
    final animeList = _libraryItems
        .where((item) => item.type == MediaType.anime)
        .toList();
    final moviesList = _libraryItems
        .where((item) => item.type == MediaType.movie)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      body: CustomScrollView(
        slivers: [
          // 1. Netflix-style App Bar & Category Filter Chips
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xE60A0A10),
            elevation: 0,
            expandedHeight: 60,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VELA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'المكتبة الذكية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.folder_open_rounded,
                  color: Colors.white,
                ),
                tooltip: 'إضافة مجلد وسائط محلي',
                onPressed: _pickAndAddLocalVideo,
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                tooltip: 'بحث في المكتبة',
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 2. Category Filter Pills
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryPill(MediaCategory.home),
                  _buildCategoryPill(MediaCategory.continueWatching),
                  _buildCategoryPill(MediaCategory.anime),
                  _buildCategoryPill(MediaCategory.movies),
                  _buildCategoryPill(MediaCategory.favorites),
                ],
              ),
            ),
          ),

          // 3. Hero Featured Backdrop Banner
          SliverToBoxAdapter(child: _buildHeroBanner(heroItem)),

          // 4. Continue Watching Carousel
          if (continueWatching.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'متابعة المشاهدة (Continue Watching)',
                Icons.play_circle_outline_rounded,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: continueWatching.length,
                  itemBuilder: (context, i) =>
                      _buildContinueWatchingCard(continueWatching[i]),
                ),
              ),
            ),
          ],

          // 5. Anime & High-Bitrate Series Carousel
          if (animeList.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'أنمي ومسلسلات (10-bit Hi10P & HDR)',
                Icons.animation_rounded,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: animeList.length,
                  itemBuilder: (context, i) => _buildPosterCard(animeList[i]),
                ),
              ),
            ),
          ],

          // 6. Movies Carousel
          if (moviesList.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'أفلام سينمائية (Movies & Surround Sound)',
                Icons.movie_filter_rounded,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: moviesList.length,
                  itemBuilder: (context, i) => _buildPosterCard(moviesList[i]),
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(MediaCategory cat) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.white12,
          ),
        ),
        child: Text(
          cat.label.split('(').first.trim(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(MediaItem item) {
    return Container(
      height: 320,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: item.backdropPath != null
            ? DecorationImage(
                image: NetworkImage(item.backdropPath!),
                fit: BoxFit.cover,
              )
            : null,
        color: const Color(0xFF1E1E2C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Vignette
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54, Color(0xF00A0A10)],
              ),
            ),
          ),

          // Content Box at Bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tags
                Row(
                  children: [
                    _buildBadge('4K UHD', Colors.greenAccent),
                    const SizedBox(width: 6),
                    _buildBadge('HDR10', Colors.amberAccent),
                    const SizedBox(width: 6),
                    _buildBadge('10-BIT', Colors.cyanAccent),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text(
                        'تابع المشاهدة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _playMediaItem(item),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('معلومات'),
                      onPressed: () => _showMediaInfoSheet(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(MediaItem item) {
    return GestureDetector(
      onTap: () => _playMediaItem(item),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF181824),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.backdropPath != null
                      ? Image.network(item.backdropPath!, fit: BoxFit.cover)
                      : Container(color: Colors.white10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            LinearProgressIndicator(
              value: item.watchProgressFraction,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 3,
            ),

            // Title and Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.resolution} • ${item.videoCodec}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterCard(MediaItem item) {
    return GestureDetector(
      onTap: () => _playMediaItem(item),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF181824),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            item.backdropPath != null
                ? Image.network(item.backdropPath!, fit: BoxFit.cover)
                : Container(color: Colors.white10),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showMediaInfoSheet(MediaItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14141E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('المسار:', item.filePathOrUrl),
              _buildInfoRow('الدقة:', item.resolution),
              _buildInfoRow('الترميز:', item.videoCodec),
              _buildInfoRow('معدل الإطارات:', '${item.fps} fps'),
              _buildInfoRow(
                'دعم HDR:',
                item.isHdr ? 'نعم (HDR10)' : 'لا (SDR)',
              ),
              _buildInfoRow(
                'عمق الألوان:',
                item.is10Bit ? '10-bit (Hi10P)' : '8-bit',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'تشغيل في Vela Player',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _playMediaItem(item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
