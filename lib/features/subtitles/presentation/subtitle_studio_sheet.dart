import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/subtitles/models/subtitle_style.dart';
import '../../../core/subtitles/subtitle_manager.dart';

class SubtitleStudioSheet extends ConsumerStatefulWidget {
  const SubtitleStudioSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubtitleStudioSheet(),
    );
  }

  @override
  ConsumerState<SubtitleStudioSheet> createState() =>
      _SubtitleStudioSheetState();
}

class _SubtitleStudioSheetState extends ConsumerState<SubtitleStudioSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SubtitleStyle _currentStyle;

  final List<String> _availableFonts = [
    'Cairo',
    'Tajawal',
    'Amiri',
    'Outfit',
    'Rubik',
    'Roboto',
  ];

  final List<Color> _presetColors = [
    Colors.white,
    const Color(0xFFFFD54F), // Anime Gold
    const Color(0xFF00F0FF), // Cyber Cyan
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF43F5E), // Rose Red
    const Color(0xFFA855F7), // Purple
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentStyle = ref.read(subtitleProvider).style;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateStyle(SubtitleStyle newStyle) {
    setState(() {
      _currentStyle = newStyle;
    });
    ref.read(subtitleProvider.notifier).updateStyle(newStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'استوديو التنسيق (Subtitle Studio)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Live Preview Card
          _buildLivePreviewCard(),

          // Tabs (Presets, Font, Colors, Position)
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(
                text: 'الأنماط الجاهزة',
                icon: Icon(Icons.auto_awesome, size: 18),
              ),
              Tab(text: 'الخط والحجم', icon: Icon(Icons.text_fields, size: 18)),
              Tab(
                text: 'الألوان والحدود',
                icon: Icon(Icons.color_lens_outlined, size: 18),
              ),
              Tab(text: 'الموضع والخلفية', icon: Icon(Icons.tune, size: 18)),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPresetsTab(),
                _buildFontTab(),
                _buildColorsTab(),
                _buildPositionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop&q=60',
          ),
          fit: BoxFit.cover,
          opacity: 0.35,
        ),
      ),
      alignment: Alignment.center,
      child: _renderPreviewText(),
    );
  }

  Widget _renderPreviewText() {
    const sampleText = 'أهلاً بك في LumaSub • تجربة ترجمة ذكية';

    TextStyle base = TextStyle(
      fontSize: _currentStyle.fontSize,
      fontWeight: _currentStyle.fontWeight,
      letterSpacing: _currentStyle.letterSpacing,
    );

    TextStyle fontStyle;
    switch (_currentStyle.fontFamily.toLowerCase()) {
      case 'cairo':
        fontStyle = GoogleFonts.cairo(textStyle: base);
        break;
      case 'tajawal':
        fontStyle = GoogleFonts.tajawal(textStyle: base);
        break;
      case 'amiri':
        fontStyle = GoogleFonts.amiri(textStyle: base);
        break;
      case 'outfit':
        fontStyle = GoogleFonts.outfit(textStyle: base);
        break;
      case 'rubik':
        fontStyle = GoogleFonts.rubik(textStyle: base);
        break;
      default:
        fontStyle = GoogleFonts.roboto(textStyle: base);
    }

    Widget content;
    if (_currentStyle.outlineWidth > 0) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Text(
            sampleText,
            textAlign: TextAlign.center,
            style: fontStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = _currentStyle.outlineWidth * 2
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..color = _currentStyle.outlineColor,
            ),
          ),
          Text(
            sampleText,
            textAlign: TextAlign.center,
            style: fontStyle.copyWith(
              color: _currentStyle.textColor,
              shadows: _currentStyle.glowRadius > 0
                  ? [
                      Shadow(
                        color: _currentStyle.glowColor,
                        blurRadius: _currentStyle.glowRadius,
                        offset: const Offset(0, 1.5),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        sampleText,
        textAlign: TextAlign.center,
        style: fontStyle.copyWith(
          color: _currentStyle.textColor,
          shadows: _currentStyle.glowRadius > 0
              ? [
                  Shadow(
                    color: _currentStyle.glowColor,
                    blurRadius: _currentStyle.glowRadius,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
      );
    }

    if (_currentStyle.showBackgroundBox) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: _currentStyle.boxPadding * 1.5,
          vertical: _currentStyle.boxPadding,
        ),
        decoration: BoxDecoration(
          color: _currentStyle.backgroundColor,
          borderRadius: BorderRadius.circular(_currentStyle.borderRadius),
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildPresetsTab() {
    final presets = [
      {
        'name': 'أبيض كلاسيكي',
        'style': SubtitleStyle.classicWhite,
        'icon': Icons.movie,
      },
      {
        'name': 'أنمي ذهبي',
        'style': SubtitleStyle.animeYellow,
        'icon': Icons.star,
      },
      {
        'name': 'سايبر نيون',
        'style': SubtitleStyle.cyberNeon,
        'icon': Icons.bolt,
      },
      {
        'name': 'نتفلكس مظلل',
        'style': SubtitleStyle.netflixBoxed,
        'icon': Icons.tv,
      },
      {
        'name': 'زمردي ناعم',
        'style': SubtitleStyle.emeraldGlow,
        'icon': Icons.diamond,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final item = presets[index];
        final style = item['style'] as SubtitleStyle;
        final name = item['name'] as String;
        final icon = item['icon'] as IconData;

        return Card(
          color: AppColors.surfaceVariant,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: style.textColor.withValues(alpha: 0.2),
              child: Icon(icon, color: style.textColor, size: 20),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${style.fontFamily} • ${style.fontSize.toInt()}px'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _updateStyle(style),
              child: const Text('تطبيق'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('نوع الخط:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableFonts.map((font) {
            final isSelected = _currentStyle.fontFamily == font;
            return ChoiceChip(
              label: Text(font),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (selected) {
                if (selected) {
                  _updateStyle(_currentStyle.copyWith(fontFamily: font));
                }
              },
            );
          }).toList(),
        ),
        const Divider(height: 32, color: Colors.white12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'حجم الخط:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_currentStyle.fontSize.toInt()} px',
              style: const TextStyle(color: AppColors.primaryLight),
            ),
          ],
        ),
        Slider(
          value: _currentStyle.fontSize,
          min: 14.0,
          max: 40.0,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
          onChanged: (val) =>
              _updateStyle(_currentStyle.copyWith(fontSize: val)),
        ),
      ],
    );
  }

  Widget _buildColorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'لون النص الأساسي:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildColorPickerRow(
          selectedColor: _currentStyle.textColor,
          onColorSelected: (col) =>
              _updateStyle(_currentStyle.copyWith(textColor: col)),
        ),
        const Divider(height: 30, color: Colors.white12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'سماكة الحد الخارجي (Stroke):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${_currentStyle.outlineWidth.toStringAsFixed(1)} px'),
          ],
        ),
        Slider(
          value: _currentStyle.outlineWidth,
          min: 0.0,
          max: 6.0,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
          onChanged: (val) =>
              _updateStyle(_currentStyle.copyWith(outlineWidth: val)),
        ),
        const SizedBox(height: 8),
        const Text(
          'لون الحد الخارجي:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildColorPickerRow(
          selectedColor: _currentStyle.outlineColor,
          onColorSelected: (col) =>
              _updateStyle(_currentStyle.copyWith(outlineColor: col)),
        ),
      ],
    );
  }

  Widget _buildPositionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الموضع الرأسي للترجمة:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(_currentStyle.verticalPositionPercentage * 100).toInt()}% من الشاشة',
            ),
          ],
        ),
        Slider(
          value: _currentStyle.verticalPositionPercentage,
          min: 0.4,
          max: 0.95,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
          onChanged: (val) => _updateStyle(
            _currentStyle.copyWith(
              verticalPositionPercentage: val,
              customOffset: null, // Clear custom drag offset on slider adjust
            ),
          ),
        ),
        const Divider(height: 30, color: Colors.white12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'إظهار صندوق خلفية شبه شفاف',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('يسهل القراءة في المشاهد شديدة السطوع'),
          value: _currentStyle.showBackgroundBox,
          activeThumbColor: AppColors.primary,
          onChanged: (val) =>
              _updateStyle(_currentStyle.copyWith(showBackgroundBox: val)),
        ),
      ],
    );
  }

  Widget _buildColorPickerRow({
    required Color selectedColor,
    required ValueChanged<Color> onColorSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _presetColors.map((col) {
          final isSelected = selectedColor.toARGB32() == col.toARGB32();
          return GestureDetector(
            onTap: () => onColorSelected(col),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: col,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white24,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: col.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
