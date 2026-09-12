import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../billing/presentation/subscription_sheet.dart';

/// Grouped, searchable, and resettable Settings Screen according to Section 26 of Master Engineering Plan.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Playback Settings State
  String _enginePreference = 'Media3 (Recommended)';
  bool _hardwareDecoding = true;
  bool _audioFocusHandling = true;
  bool _autoResume = true;

  // Subtitles State
  String _defaultSubtitleLang = 'العربية (Arabic)';
  bool _autoHealthScan = true;
  bool _dualSubtitles = false;

  // AI & Privacy State
  bool _localOnlyAiMode = true;
  String _aiProvider = 'Local Quantized (On-Device)';

  // Audio Lab State
  bool _softKneeLimiter = true;
  bool _nightModeDrc = false;
  bool _replayGain = true;
  bool _audioPassthrough = false;

  // Network State
  bool _wifiOnlyDownloads = true;
  String _cacheSizeMb = '512 MB';

  // Advanced State
  bool _diagnosticHud = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetAllSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('إعادة ضبط الإعدادات؟'),
        content: const Text(
          'سيتم استعادة كافة الخيارات الافتراضية للمشغل، الترجمة، والصوت.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _enginePreference = 'Media3 (Recommended)';
                _hardwareDecoding = true;
                _audioFocusHandling = true;
                _autoResume = true;
                _defaultSubtitleLang = 'العربية (Arabic)';
                _autoHealthScan = true;
                _dualSubtitles = false;
                _localOnlyAiMode = true;
                _aiProvider = 'Local Quantized (On-Device)';
                _softKneeLimiter = true;
                _nightModeDrc = false;
                _replayGain = true;
                _audioPassthrough = false;
                _wifiOnlyDownloads = true;
                _cacheSizeMb = '512 MB';
                _diagnosticHud = false;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت استعادة الإعدادات الافتراضية بنجاح.'),
                ),
              );
            },
            child: const Text(
              'إعادة الضبط',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(String title, String subtitle) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return title.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إعدادات Vela Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'إعادة ضبط كافة الإعدادات',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _resetAllSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText:
                  'البحث في الإعدادات (تشغيل، ترجمة، ذكاء اصطناعي، صوت)...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryLight,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subscription Tier Banner
          _buildSubscriptionBanner(),
          const SizedBox(height: 20),

          // 1. Playback Section
          _buildSectionHeader(
            '1. خيارات التشغيل (Playback)',
            Icons.play_circle_outline,
          ),
          if (_matchesSearch('محرك التشغيل المفضل', 'Engine Preference'))
            _buildDropdownTile(
              title: 'محرك التشغيل المفضل',
              subtitle: 'اختر المحرك الأساسي لفك التشفير وعرض الفيديو',
              value: _enginePreference,
              items: const [
                'Media3 (Recommended)',
                'libmpv (Anime & Complex ASS)',
                'LibVLC (Legacy Formats)',
              ],
              onChanged: (v) => setState(() => _enginePreference = v!),
            ),
          if (_matchesSearch('تسريع العتاد', 'Hardware Decoding'))
            SwitchListTile(
              title: const Text('تسريع العتاد (Hardware Decoding)'),
              subtitle: const Text(
                'استخدام معالج الرسوميات لتوفير استهلاك الطاقة ورفع السلاسة',
              ),
              value: _hardwareDecoding,
              onChanged: (v) => setState(() => _hardwareDecoding = v),
            ),
          if (_matchesSearch('التركيز الصوتي', 'Audio Focus'))
            SwitchListTile(
              title: const Text('التركيز الصوتي التلقائي (Audio Focus)'),
              subtitle: const Text(
                'خفض الصوت مؤقتاً عند ورود مكالمات أو إشعارات',
              ),
              value: _audioFocusHandling,
              onChanged: (v) => setState(() => _audioFocusHandling = v),
            ),
          if (_matchesSearch('استئناف المشاهدة', 'Resume Playback'))
            SwitchListTile(
              title: const Text('استئناف موضع المشاهدة تلقائياً'),
              subtitle: const Text(
                'العودة التلقائية لآخر ثانية تمت مشاهدتها لكل فيديو',
              ),
              value: _autoResume,
              onChanged: (v) => setState(() => _autoResume = v),
            ),

          const Divider(color: Colors.white10, height: 32),

          // 2. Subtitles Section
          _buildSectionHeader(
            '2. منظومة الترجمة (Subtitles)',
            Icons.subtitles_outlined,
          ),
          if (_matchesSearch(
            'لغة الترجمة الافتراضية',
            'Default Subtitle Language',
          ))
            _buildDropdownTile(
              title: 'اللغة الافتراضية',
              subtitle: 'لغة الترجمة المفضلة عند فتح أي وسائط جديدة',
              value: _defaultSubtitleLang,
              items: const [
                'العربية (Arabic)',
                'English',
                '日本語 (Japanese)',
                'Français',
                'Español',
              ],
              onChanged: (v) => setState(() => _defaultSubtitleLang = v!),
            ),
          if (_matchesSearch('فحص صحة الترجمة', 'Health Scan'))
            SwitchListTile(
              title: const Text('فحص صحة الترجمة التلقائي (Health Scan)'),
              subtitle: const Text(
                'اكتشاف التداخلات الزمنية، الومضات القصيرة، والأوقات السالبة',
              ),
              value: _autoHealthScan,
              onChanged: (v) => setState(() => _autoHealthScan = v),
            ),
          if (_matchesSearch('ترجمة ثنائية', 'Dual Subtitles'))
            SwitchListTile(
              title: const Text('الترجمة الثنائية المتزامنة (Dual Subtitles)'),
              subtitle: const Text('عرض لغتين في وقت واحد للأغراض التعليمية'),
              value: _dualSubtitles,
              onChanged: (v) => setState(() => _dualSubtitles = v),
            ),

          const Divider(color: Colors.white10, height: 32),

          // 3. AI & Privacy Section
          _buildSectionHeader(
            '3. الذكاء الاصطناعي والخصوصية (AI & Privacy)',
            Icons.psychology_outlined,
          ),
          if (_matchesSearch('المعالجة المحلية فقط', 'Local-Only Mode'))
            SwitchListTile(
              title: const Text('وضع المعالجة المحلية فقط (Local-First)'),
              subtitle: const Text(
                'منع رفع أي بيانات أو ملفات إلى السحابة وتشغيل النماذج محلياً',
              ),
              value: _localOnlyAiMode,
              onChanged: (v) => setState(() => _localOnlyAiMode = v),
            ),
          if (_matchesSearch('مزود الذكاء الاصطناعي', 'AI Provider'))
            _buildDropdownTile(
              title: 'مزود الذكاء الاصطناعي',
              subtitle: 'النموذج المستخدم لضبط التوقيت والترجمة السياقية',
              value: _aiProvider,
              items: const [
                'Local Quantized (On-Device)',
                'Cloud Hybrid (Requires Consent)',
              ],
              onChanged: (v) => setState(() => _aiProvider = v!),
            ),

          const Divider(color: Colors.white10, height: 32),

          // 4. Audio Lab Section
          _buildSectionHeader(
            '4. معمل الصوتيات (Audio Lab)',
            Icons.graphic_eq_rounded,
          ),
          if (_matchesSearch('محدد الذروة', 'Soft Limiter'))
            SwitchListTile(
              title: const Text('محدد الذروة الرياضي (Soft-Knee Limiter)'),
              subtitle: const Text(
                'منع التشويه الصوتي الرقمي عند التضخيم بنسبة 200% (+12dB)',
              ),
              value: _softKneeLimiter,
              onChanged: (v) => setState(() => _softKneeLimiter = v),
            ),
          if (_matchesSearch('الوضع الليلي', 'Night Mode DRC'))
            SwitchListTile(
              title: const Text('الوضع الليلي (Night Mode DRC)'),
              subtitle: const Text(
                'توضيح أصوات الحوارات وخفض أصوات الانفجارات العالية',
              ),
              value: _nightModeDrc,
              onChanged: (v) => setState(() => _nightModeDrc = v),
            ),
          if (_matchesSearch('موازنة الصوت', 'ReplayGain'))
            SwitchListTile(
              title: const Text(
                'موازنة الصوت القياسية (ReplayGain / EBU R128)',
              ),
              subtitle: const Text(
                'توحيد مستوى الصوت تلقائياً بين الفيديوهات المختلفة',
              ),
              value: _replayGain,
              onChanged: (v) => setState(() => _replayGain = v),
            ),
          if (_matchesSearch('التمرير المباشر للصوت', 'Audio Passthrough'))
            SwitchListTile(
              title: const Text('التمرير المباشر للصوت (Audio Passthrough)'),
              subtitle: const Text(
                'تمرير إشارات Dolby/DTS مباشرة إلى مكبر الصوت الخارجي دون فك تشفير',
              ),
              value: _audioPassthrough,
              onChanged: (v) => setState(() => _audioPassthrough = v),
            ),

          const Divider(color: Colors.white10, height: 32),

          // 5. Network & Downloads Section
          _buildSectionHeader(
            '5. الشبكات والتنزيل (Network & Cache)',
            Icons.cloud_download_outlined,
          ),
          if (_matchesSearch('تنزيل عبر Wi-Fi فقط', 'Wi-Fi Only'))
            SwitchListTile(
              title: const Text('التنزيل عبر Wi-Fi فقط'),
              subtitle: const Text(
                'حماية باقة بيانات الهاتف من الاستهلاك غير المقصود',
              ),
              value: _wifiOnlyDownloads,
              onChanged: (v) => setState(() => _wifiOnlyDownloads = v),
            ),
          if (_matchesSearch('حجم ذاكرة البث المؤقتة', 'Streaming Cache'))
            _buildDropdownTile(
              title: 'حجم الذاكرة المؤقتة للبث',
              subtitle: 'سعة التخزين المؤقت المخصصة لمصادر SMB و WebDAV و SFTP',
              value: _cacheSizeMb,
              items: const ['256 MB', '512 MB', '1024 MB', '2048 MB'],
              onChanged: (v) => setState(() => _cacheSizeMb = v!),
            ),

          const Divider(color: Colors.white10, height: 32),

          // 6. Advanced Section
          _buildSectionHeader(
            '6. خيارات متقدمة وتشخيصية (Advanced)',
            Icons.terminal_rounded,
          ),
          if (_matchesSearch('شاشة التشخيص اللحظية', 'Diagnostic HUD'))
            SwitchListTile(
              title: const Text('شاشة التشخيص اللحظية (Diagnostic HUD)'),
              subtitle: const Text(
                'عرض معدل الإطارات (FPS)، الإطارات المفقودة، ومعدل البت المباشر',
              ),
              value: _diagnosticHud,
              onChanged: (v) => setState(() => _diagnosticHud = v),
            ),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: Colors.white70),
            title: const Text('سجل التراخيص ومكونات المصدر المفتوح'),
            subtitle: const Text('استعراض وثيقة LICENSES_AND_SBOM.md الرسمية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'جميع التراخيص موثقة في docs/LICENSES_AND_SBOM.md',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.accent.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطة الاشتراك الحالية: VELA FREE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'تشغيل محلي غير محدود، وتنسيق قياسي للترجمات.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => SubscriptionSheet.show(context),
            child: const Text(
              'ترقية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surface,
          items: items
              .map(
                (it) => DropdownMenuItem(
                  value: it,
                  child: Text(it, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
