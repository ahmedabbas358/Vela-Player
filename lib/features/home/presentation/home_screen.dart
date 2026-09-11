import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/subtitles/subtitle_manager.dart';
import '../../player/presentation/video_player_screen.dart';
import '../../subtitles/presentation/subtitle_studio_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Public sample test video URL
  static const String demoVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  static const String sampleSrtContent = '''1
00:00:01,000 --> 00:00:04,500
[راوي]: مرحباً بكم في تطبيق LumaSub لمشاهدة الفيديو والترجمة الذكية.

2
00:00:05,000 --> 00:00:09,000
تتم مزامنة هذه الترجمة تلقائياً وبدقة فائقة تصل إلى جزء من الثانية.

3
00:00:09,500 --> 00:00:14,000
[أليس]: يمكنك سحب الترجمة بيدك إلى أي موضع تفضله على الشاشة!

4
00:00:14,500 --> 00:00:19,500
[بوب]: ويمكنك تغيير نوع الخط ولونه والحد الخارجي عبر "استوديو التنسيق".

5
00:00:20,000 --> 00:00:25,000
في المراحل القادمة، سيتغير لون الترجمة تلقائياً حسب لون شعر المتحدث!
''';

  Future<void> _openLocalVideo(BuildContext context, WidgetRef ref) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'ts'],
    );

    if (files.isNotEmpty && files.first.path != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: files.first.path!,
            videoTitle: files.first.name,
          ),
        ),
      );
    }
  }

  void _playDemoVideo(BuildContext context, WidgetRef ref) {
    // Pre-load demo subtitle
    ref
        .read(subtitleProvider.notifier)
        .loadContent(sampleSrtContent, fileName: 'demo_subtitles_ar.srt');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VideoPlayerScreen(
          videoPath: demoVideoUrl,
          videoTitle: 'Big Buck Bunny (Demo + Smart Subtitles)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LumaSub',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF1E1B4B), AppColors.background],
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Description Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'مشغل وسائط وترجمة ذكي فائق الدقة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'مزامنة دقيقة، استوديو تنسيق حي، وتلوين تكيفي للشخصيات',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'إجراءات سريعة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Cards
                  Row(
                    children: [
                      // Open local video
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.video_library_rounded,
                          title: 'فتح فيديو',
                          subtitle: 'من ذاكرة الجهاز',
                          color: AppColors.primary,
                          onTap: () => _openLocalVideo(context, ref),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Subtitle Studio
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.palette_outlined,
                          title: 'استوديو التنسيق',
                          subtitle: 'تخصيص الخطوط والألوان',
                          color: AppColors.accent,
                          onTap: () => SubtitleStudioSheet.show(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Demo player card
                  GestureDetector(
                    onTap: () => _playDemoVideo(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.smart_display_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'تجربة فورية مع مقطع وترجمة تجريبية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'اختبر الترجمة التفاعلية والإيماءات الآن',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'ميزات LumaSub الحصرية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  _buildFeatureTile(
                    icon: Icons.sync,
                    iconColor: Colors.amber,
                    title: 'محرك المزامنة التلقائية (Auto-Sync)',
                    description: 'تصحيح تأخير وتقديم الترجمة تلقائياً عبر كشف النشاط الصوتي VAD.',
                  ),
                  _buildFeatureTile(
                    icon: Icons.color_lens,
                    iconColor: const Color(0xFFFFD54F),
                    title: 'التلوين الذكي حسب الشخصية (AI Coloring)',
                    description: 'تلوين سطر الترجمة بلون شعر وعين الشخصية المتحدثة في المشهد.',
                  ),
                  _buildFeatureTile(
                    icon: Icons.translate,
                    iconColor: AppColors.accent,
                    title: 'ترجمة فورية بين اللغات',
                    description: 'ترجمة ملفات الترجمة بالكامل بنقرة واحدة مع الحفاظ التام على التوقيتات.',
                  ),
                  _buildFeatureTile(
                    icon: Icons.mic_none_outlined,
                    iconColor: AppColors.accentNeon,
                    title: 'توليد ترجمة من الصوت (Speech-to-Text)',
                    description: 'تحويل صوت الفيديو إلى ترجمة نصية متزامنة عبر نموذج Whisper.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
