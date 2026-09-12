/// Canonical entitlement tiers for Vela Player.
enum EntitlementTier {
  /// 100% Free Forever: Local video/audio playback, HW decoding, 200% boost,
  /// 10-band EQ, manual subtitle styling, gestures, zero ads.
  free,

  /// Plus ($0.99/wk or $1.99/mo):
  /// Subtitle health auto-fix, FPS drift conversion, SMB/WebDAV/SFTP Network Hub,
  /// Audio profiles, background downloads.
  plus,

  /// Pro ($3.99/mo or $14.99/yr):
  /// AI Acoustic auto-sync, AI Context-Aware translation, Character hair/eye styling,
  /// Burned-in Subtitle OCR, AI Super Resolution.
  pro,
}

/// A product plan offered in the store.
class SubscriptionPlan {
  final String id;
  final EntitlementTier tier;
  final String title;
  final String priceFormatted;
  final String period;
  final String badge;
  final List<String> highlights;

  const SubscriptionPlan({
    required this.id,
    required this.tier,
    required this.title,
    required this.priceFormatted,
    required this.period,
    this.badge = '',
    required this.highlights,
  });

  static const List<SubscriptionPlan> catalog = [
    SubscriptionPlan(
      id: 'vela_plus_weekly',
      tier: EntitlementTier.plus,
      title: 'بلاس أسبوعي (Plus Weekly)',
      priceFormatted: '\$0.99',
      period: 'أسبوعياً',
      highlights: [
        'إصلاح أخطاء وتداخلات ملفات الترجمة بضغطة زر',
        'تصحيح الانحراف الزمني لمعدل الإطارات (FPS Drift)',
        'خوادم الشبكة المنزلية والمكتبية (SMB, WebDAV, SFTP)',
      ],
    ),
    SubscriptionPlan(
      id: 'vela_plus_monthly',
      tier: EntitlementTier.plus,
      title: 'بلاس شهري (Plus Monthly)',
      priceFormatted: '\$1.99',
      period: 'شهرياً',
      badge: 'الأكثر شعبية',
      highlights: [
        'جميع مزايا بلاس',
        'تنزيل الفيديوهات من الشبكة إلى الجهاز في الخلفية',
        'أوضاع الصوت المتخصصة للأنمي والأفلام والرياضة',
      ],
    ),
    SubscriptionPlan(
      id: 'vela_pro_monthly',
      tier: EntitlementTier.pro,
      title: 'برو الذكاء الاصطناعي (Pro AI)',
      priceFormatted: '\$3.99',
      period: 'شهرياً',
      badge: 'ذكاء اصطناعي فائق',
      highlights: [
        'المزامنة الصوتية الذكية التلقائية (Acoustic VAD + DTW)',
        'الترجمة الذكية الفورية مع الحفاظ على التنسيق والمسرد',
        'تلوين الترجمة الذكي حسب لون شعر وعين الشخصيات',
        'استخراج الترجمات المدمجة من الصورة (OCR Subtitles)',
      ],
    ),
    SubscriptionPlan(
      id: 'vela_pro_yearly',
      tier: EntitlementTier.pro,
      title: 'برو سنوي (Pro Annual)',
      priceFormatted: '\$14.99',
      period: 'سنوياً',
      badge: 'توفير 70%',
      highlights: [
        'جميع مزايا برو AI لمدة عام كامل',
        'أولوية معالجة المشاريع والترجمة السياقية',
        'دعم تقني مباشر وتحديثات فورية',
      ],
    ),
  ];
}
