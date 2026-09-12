# وثيقة الخطة الهندسية المعمارية الشاملة والبرومبت الماستر لبناء التطبيق
# VELA PLAYER — AI MEDIA PLAYER & SUBTITLE INTELLIGENCE STUDIO
### الجيل القادم لمشغلات الوسائط الذكية لنظامي Android و iOS (منافس وقاتل MX Player)
*تاريخ الإصدار: سبتمبر 2026 — الإصدار المعتمد للإنتاج (Production Ready)*
*الأنظمة المستهدفة: Android 16 (API Level 36) | iOS 18/26 (Xcode 26+)*

---

## فهرس المحتويات التنفيذي

1. **الرؤية والتموضع الاستراتيجي (Product Vision & Positioning)**
2. **محرك فك الترميز وتشغيل الوسائط الخارق (MX Player Killer Engine)**
3. **محرك استيعاب وصياغة كافة ملفات الترجمة (Universal Subtitle Engine)**
4. **منظومة المزامنة الذكية رباعية المستويات (Quad-Tier Smart Sync Engine)**
5. **استوديو التنسيق الطباعي والجمالي المتقدم (Typography & Beautification Studio)**
6. **خوارزمية الذكاء الاصطناعي لتلوين الترجمة حسب لون شعر وعين الشخصيات (AI Visual Styling)**
7. **محرك الترجمة العالمية السياقي وحفظ المصطلحات (Context-Aware Translation Engine)**
8. **استخراج الترجمات المدمجة بالفيديو بصرياً (Burned-in Subtitle OCR & Inpainting)**
9. **ميزات التنافس والتفوق الكامل على MX Player (Comprehensive Feature Parity)**
10. **واجهة وتجربة المستخدم الحديثة (Modern Luxury UI/UX Design System)**
11. **الأمان والخصوصية ومجلد الخزنة المشفرة (Security, Privacy & Private Vault)**
12. **معمارية النظام والشيفرة المصدرية (System Architecture & Monorepo Structure)**
13. **نموذج الاشتراكات والفوترة والجاهزية للمتاجر (Monetization & Store Compliance)**
14. **خطة الاختبارات وضمان الجودة الصارمة (Testing & QA Strategy)**
15. **البرومبت الماستر فائق الدقة لبناء التطبيق (The Definitive Master Build Prompt)**
16. **خارطة الطريق التنفيذية ومعايير الإنجاز (Roadmap & Definition of Done)**

---

## 1. الرؤية والتموضع الاستراتيجي (Product Vision & Positioning)

### 1.1 لماذا تفشل المشغلات التقليدية (MX Player, VLC, KMPlayer)؟
- **عقم الترجمة**: تعامل المشغلات التقليدية مع ملف الترجمة كأنه مجرد "شريط نصي أبيض" يرمى عشوائياً أسفل الشاشة، دون فهم للسياق أو المتحدث أو المظهر.
- **عذاب المزامنة اليدوية**: عندما يتأخر الصوت عن الترجمة أو يختلف معدل الإطارات (FPS)، يضطر المستخدم للضغط على أزرار التقديم والتأخير عشرات المرات دون الوصول لدقة متناهية.
- **التشوه البصري**: خطوط بدائية، غياب الدعم الحقيقي للنصوص العربية المتشابكة وتشكيلها، تداخل النصوص مع خلفيات الفيديو الساطعة مما يصيب العين بالإجهاد.
- **تشتت الأدوات**: يحتاج المستخدم لتطبيق لتشغيل الفيديو، وموقع لتحميل الترجمة، وتطبيق آخر لترجمتها، وأداة حاسوبية لمزامنتها وتعديلها.
- **الإعلانات المزعجة**: امتلاء المشغلات الشهيرة بإعلانات الفيديو المنبثقة والمشتتة لتجربة المشاهدة.

### 1.2 حل Vela Player الجذري
منصة متكاملة واحدة تجمع بين **أقوى مشغل وسائط محلي وشبكي فائق الأداء (Hardware Accelerated Media Player)** وبين **أذكى استوديو ترجمة في العالم (Subtitle Intelligence Studio)**:
- تشغيل سلس لكافة الصيغ (فيديو وصوت) بدقة تصل إلى 8K HDR.
- حل مشكلات التوقيت تلقائياً بالذكاء الاصطناعي عبر تحليل موجات الصوت (Acoustic Auto-Sync).
- تلوين الترجمة تلقائياً حسب لون شعر أو عين الشخصية المتحدثة في الأنمي والأفلام والمسلسلات مع ضمان تباين مقروء 100% (WCAG AAA).
- ترجمة فورية سياقية تحفظ الضمائر والمذكر والمؤنث ومسرد المصطلحات الخاصة بالعمل.
- واجهة خيالية هادئة مستوحاة من فلسفة Apple و Linear تخلو تماماً من الإعلانات المزعجة وتعتمد اشتراكات رمزية ميسرة.

---

## 2. محرك فك الترميز وتشغيل الوسائط الخارق (MX Player Killer Engine)

تم تصميم معمارية التشغيل عبر طبقة تجريد نواتية متعددة المستويات (**Multi-Engine Abstraction Layer**) تتيح التبديل الفوري بين أنوية فك التشفير:

### 2.1 معمارية أنوية فك التشفير الأساسية والاحتياطية (Decoupled Playback Architecture)
1. **المسار الأساسي لنظام أندرويد (Android Primary: AndroidX Media3 1.11.0)**:
   - يعتمد على أحدث إصدار رسمي مستقر من **AndroidX Media3 (1.11.0 - أغسطس 2026)**.
   - يتكامل مع خدمة **`MediaSessionService`** مع التصريح الرسمي بنوع الخدمة الأمامية `foregroundServiceType="mediaPlayback"` وفق اشتراطات Android 14/15/16.
   - فك ترميز عتادي مباشر عبر `MediaCodec` يدعم 4K/8K بتردد 60/120 إطار في الثانية وتقنيات المجال الديناميكي العالي: HDR10, HDR10+, Dolby Vision (Profiles 5, 7, 8), HLG بأقل استهلاك للبطارية.
2. **المسار الأساسي لنظام آبل (iOS Primary: AVFoundation)**:
   - يعتمد على **AVPlayer** و **AVPictureInPictureController** الأصليين لنظام iOS.
   - تشغيل مباشر منخفض استهلاك الطاقة مع فك تشفير عتادي عبر `VideoToolbox`.
   - تكامل كامل مع مركز التحكم (Now Playing Info Center) وجهاز التحكم عن بعد (MPRemoteCommandCenter) وسماعات AirPods مع الصوت المكاني (Spatial Audio).
3. **محركات الامتداد والإنقاذ (Extensions & Fallback: C++ libmpv / FFmpeg 7+ / libass)**:
   - لا يُعتمد على `media_kit` كقلب وحيد غير مشروط للتطبيق، بل يعمل كمحرك إنقاذ ذكي (Fallback Engine).
   - يُستدعى تلقائياً لتشغيل الصيغ النادرة (مثل 10-bit Hi10P AVC للأنمي القديم، وصيغ DivX, XviD, RealVideo) والملفات التالفة أو معالجة وسوم ASS المعقدة عبر libass.
4. **نمط التشخيص الاحترافي للمطورين (Developer / Diagnostic HUD Mode)**:
   - شاشة قياس رقمية حية تعرض للمطورين والمستخدمين المتمرسين كافة بيانات الأداء لحظياً:
     `Engine | Decoder | Renderer | Codec | Resolution | FPS | Dropped Frames | Bitrate | Buffer | Audio Route | Subtitle Latency | HDR | Memory | Thermal State`


### 2.2 جدول الصيغ والحاويات المدعومة رسمياً
| الفئة | الصيغ والحاويات المدعومة |
|---|---|
| **حاويات الفيديو** | MKV, MP4, WebM, AVI, MOV, TS, M2TS, FLV, WMV, 3GP, VOB, OGV, ISO, ASF |
| **ترميزات الفيديو** | H.264 (AVC), H.265 (HEVC), VP8, VP9, AV1, MPEG-1/2/4, VC-1, ProRes, Motion JPEG |
| **ترميزات الصوت** | AAC, AC3 (Dolby Digital), E-AC3 (Dolby Digital Plus), Dolby TrueHD, Atmos, DTS, DTS-HD Master Audio, FLAC, ALAC, MP3, OPUS, Vorbis, WMA, PCM/WAV |
| **بروتوكولات البث** | HLS (.m3u8), DASH (.mpd), SmoothStreaming, RTMP, RTSP, HTTP/HTTPS Progressive |

---

## 3. محرك استيعاب وصياغة كافة ملفات الترجمة (Universal Subtitle Engine)

### 3.1 الصيغ المدعومة
1. **الصيغ النصية الحديثة والكلاسيكية**:
   - `SRT (.srt)`: دعم كامل مع تنظيف الترميز التلقائي (UTF-8, Windows-1256 للعربية, CP1252, Shift-JIS).
   - `WebVTT (.vtt)`: دعم أسطر المواضع، وسوم التوقيت الداخلي، وتنسيقات CSS المدمجة.
   - `Advanced SubStation Alpha / SSA (.ass, .ssa)`: دعم استثنائي لجميع وسوم الأنماط المتقدمة: الخطوط، الألوان، الظلال، الحواف، إحداثيات المواضع `\pos(x,y)`، وسوم التلاشي `\fad`، ووسوم الكاراوكي `\k`، ورسومات المتجهات `\p1`.
   - `TTML / DFXP (.ttml, .xml)`: صيغ التلفزيون وخدمات البث العالمية مثل Netflix.
   - `SAMI (.smi)`، `MicroDVD (.sub)`، `SubViewer (.sub)`، `LRC (.lrc)` للموسيقى والكلمات المتزامنة.
2. **الترجمات الصورية والبلوراي (Bitmap Subtitles)**:
   - `SUP / PGS (.sup)`: ملفات ترجمة أقراص Blu-ray عالية الدقة.
   - `VobSub (.idx / .sub)`: ملفات ترجمة أقراص DVD.
   - محرك OCR فوري يعمل على الجهاز يحول هذه الصور إلى نصوص قابلة للتعديل والترجمة!
3. **الترجمات المدمجة داخل الحاويات (Embedded Subtitles)**:
   - استخراج وتفعيل فوري لأي مسار ترجمة مدمج داخل ملفات MKV و MP4 دون الحاجة لتصديره خارجياً.

### 3.2 نموذج الترجمة الموحد (Unified Subtitle Model - USM)
تتعامل كافة مكونات التطبيق مع هيكل بيانات موحد فائق السرعة والخفة:

```dart
class UnifiedCue {
  final String id;
  final Duration start;
  final Duration end;
  final String rawText;
  final String cleanText;
  final String? speakerName;
  final String? speakerId;
  final SubtitleStyleOverride? style;
  final double? positionX; // 0.0 to 1.0
  final double? positionY; // 0.0 to 1.0
  final CueHealthStatus health;
  final Map<String, dynamic> metadata;

  UnifiedCue({
    required this.id,
    required this.start,
    required this.end,
    required this.rawText,
    required this.cleanText,
    this.speakerName,
    this.speakerId,
    this.style,
    this.positionX,
    this.positionY,
    this.health = CueHealthStatus.healthy,
    this.metadata = const {},
  });
}
```

---

## 4. منظومة المزامنة الذكية رباعية المستويات (Quad-Tier Smart Sync Engine)

علاج تأخر وتفاوت التوقيت تم تصميمه هندسياً على 4 طبقات تقنية متكاملة تتدرج من السرعة الفورية وحتى التحليل الصوتي العميق:

```
[المستوى 1: الإزاحة اللحظية]  <-- تأخر كلي ثابت (+/- ms)
         │
[المستوى 2: انحراف الـ FPS]   <-- تباعد تدريجي خطي (23.976 vs 25 fps)
         │
[المستوى 3: المزامنة الصوتية]  <-- مقارنة نوبات الكلام الصوتي VAD + DTW
         │
[المستوى 4: التفريغ والمطابقة] <-- مطابقة نصوص Whisper اللفظية بنص الترجمة
```

### 4.1 المستوى الأول: الإزاحة الكلية (Global Offset)
- عندما تكون الترجمة سابقة أو متأخرة بالكامل بنفس المقدار.
- شريط تحكم عائم ناعم أثناء مشاهدة الفيديو يسمح بالتقديم والتأخير بـ $\pm 50\text{ms}$ أو $\pm 250\text{ms}$ أو $\pm 1000\text{ms}$ بلمسة واحدة، مع إمكانية إدخال القيمة الرقمية بدقة المللي ثانية.

### 4.2 المستوى الثاني: تصحيح الانحراف الزمني الخطي (Linear Drift Correction)
- المشكلة الشائعة: ملف الترجمة يبدأ متزامناً تماماً في الدقيقة الأولى، لكن في الدقيقة 30 يصبح متأخراً بعدة ثوانٍ بسبب اختلاف سرعة الفيلم المصدر (مثل ملف بمعدل 23.976 fps مستخدم مع فيديو 25.0 fps).
- الحل الرياضي الذكي (نقطتا ارتكاز Two Anchors):
  1. يحدد المستخدم نقطة البداية الصحيحة للسطر الأول: $t_1$ مع الفارق $\Delta_1$.
  2. يحدد المستخدم نقطة الارتكاز الثانية عند مشهد لاحق: $t_2$ مع الفارق $\Delta_2$.
  3. يقوم المحرك بإعادة احتساب كامل توقيتات الأسطر تلقائياً وفق المعادلة الخطية:
     $$t' = t + \Delta_1 + \left( \frac{t - t_1}{t_2 - t_1} \right) \cdot (\Delta_2 - \Delta_1)$$

### 4.3 المستوى الثالث: المزامنة الصوتية التلقائية بالذكاء الاصطناعي (Acoustic Waveform Auto-Sync)
- الحل السحري بنقرة زر واحدة دون تدخل يدوي:
  1. **عزل الصوت**: يستخرج المحرك مسار الصوت البشري ويحوله في الذاكرة إلى تردد 16kHz Mono PCM.
  2. **كشف الصوت البشري (Voice Activity Detection - VAD)**: عبر خوارزمية **Silero VAD** فائقة الخفة على المعالج، يتم توليد مصفوفة فترات الكلام البشري الحقيقي في الفيديو:
     $$\mathbf{V}_{\text{audio}} = [(\text{start}_1, \text{end}_1), (\text{start}_2, \text{end}_2), \dots]$$
  3. **توليد مصفوفة نشاط الترجمة**: يتم تحويل أسطر الترجمة الحالية إلى مصفوفة فترات ظهور موازية:
     $$\mathbf{V}_{\text{sub}} = [(\text{cueStart}_1, \text{cueEnd}_1), \dots]$$
  4. **الارتباط المتبادل والتشويه الزمني الديناميكي (Dynamic Time Warping - DTW)**:
     - حساب أفضل تطابق بين الموجتين لاكتشاف مقدار الإزاحة العامة $\Delta t$ ومعامل التمدد الخطي $\alpha$.
     - تطبيق التصحيح التلقائي وتحديث كافة أسطر الملف في أقل من ثانيتين!

### 4.4 المستوى الرابع: التفريغ والمطابقة اللفظية (Speech-to-Text Forced Alignment)
- في الحالات الصعبة أو المشاهد التي تحتوي على ضوضاء عالية وموسيقى صاخبة:
  - تشغيل نموذج Whisper (محلياً أو سحابياً) لتفريغ أول دقيقتين أو أجزاء مختارة واستخراج التوقيت الزمني الدقيق لكل كلمة (Word-Level Timestamps).
  - إجراء مطابقة سلاسل نصية ذكية (Needleman-Wunsch Alignment) بين كلمات الحوار المستخرجة من الصوت وكلمات ملف الترجمة لتثبيت التوقيت بنسبة دقة $100\%$.

---

## 5. استوديو التنسيق الطباعي والجمالي المتقدم (Typography & Beautification Studio)

### 5.1 الخطوط والطباعة العربية والعالمية
- **مكتبة خطوط مدمجة فائقة الجمال**:
  - للعربية: **Readex Pro** (عصري ومقروء جداً)، **Cairo** (أنيق وسلس)، **Noto Sans Arabic** (هادئ ومعياري)، **Amiri** (كلاسيكي للأفلام التاريخية والوثائقية)، و **Kufam**.
  - للإنجليزية واللغات اللاتينية: **Inter**, **Outfit**, **Montserrat**, **Roboto Flex**.
- **دعم استيراد الخطوط المخصصة**: زر مباشر يسمح للمستخدم باختيار أي ملف خط بصيغة `.ttf` أو `.otf` من ذاكرة هاتفه واستخدامه فوراً للترجمة.
- **محرك معالجة النصوص ثنائية الاتجاه (BiDi Engine)**: حل جذري لمشكلات تشويه النص العربي؛ ضمان بقاء علامات الترقيم (؟ ، ! .) والأرقام والكلمات الإنجليزية داخل السطر العربي في مواضعها الصحيحة دون انعكاس.

### 5.2 لوحة التحكم البصرية الشاملة
| العنصر | خيارات التحكم المتاحة |
|---|---|
| **حجم الخط (Font Size)** | تحكم ديناميكي بنسبة الشاشة من 12pt إلى 64pt مع ملاءمة تلقائية لكثافة البكسل (DPI). |
| **لون النص الأساسي** | منتقي ألوان احترافي (HEX / RGB / HSL) مع لوحات جاهزة (Preset Palettes). |
| **الحد الخارجي (Stroke / Outline)** | سمك الحد من 0 إلى 8 بكسل، مع التحكم الكامل بلون الحد ودرجة شفافيته لمنع تداخل النص مع مشاهد الثلج أو الضوء الأبيض. |
| **الظل (Drop Shadow)** | إزاحة ثلاثية الأبعاد ($X, Y$)، تدرج ضبابي ناعم (Blur Radius)، ولون الظل لعمق بصري مريح للعين. |
| **صندوق القراءة الخلفي (Background Box)** | نمط شفاف، شبه شفاف (Glass Frosted)، أو صندوق ممتلئ، مع زوايا دائرية (Corner Radius) وهوامش أمان داخلية. |
| **الموضع الرأسي والأفقي** | - أوضاع سريعة: أسفل الشاشة (Bottom)، أعلى الشاشة (Top لمنع تغطية نصوص الأخبار)، وسط الشاشة.<br>- **سحب حر بإصبع اليد (Freeform Drag & Drop)**: إمكانية تحريك الترجمة باللمس ووضعها في أي زاوية أو مكان يريده المستخدم وحفظ الإحداثيات فوراً. |

---

## 6. خوارزمية الذكاء الاصطناعي لتلوين الترجمة حسب لون شعر وعين الشخصيات (AI Visual Styling)

تعد هذه الميزة الابتكار الأكبر في عالم مشغلات الوسائط، حيث تمنح تجربة مشاهدة غامرة خاصة في مسلسلات الأنمي والأفلام ذات الشخصيات المتعددة:

```
[إطار الفيديو عند نطق الحوار]
             │
   [كشف وتتبع الشخصية] ─── (MediaPipe / YOLOv8 / AnimeFace)
             │
   [عزل قناع الشعر وقزحية العين] ─── (Semantic Segmentation Mask)
             │
   [استخراج التدرج اللوني السائد] ─── (CIE-Lab Space + K-Means Clustering)
             │
   [حارس المقروئية والتناغم] ─── (Readability Guard - WCAG AAA 7:1)
             │
[تطبيق لون الشعر/العين مع الحد الوقائي على سطر المتحدث]
```

### 6.1 مراحل المعالجة البرمجية الدقيقة

#### الخطوة 1: كشف اللقطات واستخراج الإطارات المفتاحية (Keyframe Sampling)
- لتجنب إجهاد معالج الهاتف واستنزاف البطارية، لا يتم فحص جميع إطارات الفيديو (24-60 إطار في الثانية).
- بدلاً من ذلك، عند كل سطر حوار يبدأ عند التوقيت $T_{\text{start}}$، يتم أخذ عينة بصرية عند منتصف مدة الحوار:
  $$T_{\text{sample}} = T_{\text{start}} + \frac{T_{\text{end}} - T_{\text{start}}}{2}$$

#### الخطوة 2: كشف الوجوه وملامح الشخصيات (Anime & Live-Action Face Detection)
- **في مسلسلات وأفلام الأنمي**: استخدام نموذج **AnimeFace / YOLOv8-Anime** المدرب على آلاف لقطات الرسوم لتحديد حدود وجه الشخصية، العينين الكبيرتين، وخصلات الشعر الكرتونية.
- **في الأفلام والمسلسلات الواقعية**: استخدام **MediaPipe FaceMesh** لاستخراج 468 نقطة ثلاثية الأبعاد لملامح الوجه، مع تحديد إحداثيات قزحية العين (Irises) وخط بداية الشعر (Hairline).

#### الخطوة 3: عزل الأقناع اللونية (Segmentation Masks)
- يتم إنشاء قناعين ثنائيين منفصلين (Binary Masks):
  1. **قناع الشعر ($\mathbf{M}_{\text{hair}}$)**: المنطقة العلوية المحيطة بالجمجمة والمنسدلة على الكتفين مع استبعاد لون البشرة والملابس وخلفية المشهد.
  2. **قناع العينين ($\mathbf{M}_{\text{eyes}}$)**: دائرة مركزية محددة بنقاط القزحية مع استبعاد بياض العين (Sclera) وبؤبؤ العين الأسود تماماً.

#### الخطوة 4: التحويل إلى فضاء الألوان $L^*a^*b^*$ واستخراج اللون السائد
- فضاء RGB غير مناسب لقياس الألوان الطبيعية لأن الإضاءة تشوه القيم.
- يتم تحويل بكسلات القناع إلى فضاء **CIE-$L^*a^*b^*$** المتوافق مع إدراك العين البشرية:
  - $L^*$: درجة السطوع والإضاءة.
  - $a^*$: المحور بين الأخضر والأحمر.
  - $b^*$: المحور بين الأزرق والأصفر.
- يتم تطبيق خوارزمية التجميع العنقودي **$K$-Means Clustering** بقيمة $k = 3$:
  - يتم استبعاد المجموعة التي تمثل لمعان الإضاءة (Specular Highlights) والمجموعة التي تمثل الظلال الداكنة.
  - يتم اختيار العنقود الأكبر الذي يمثل اللون الصبغي النقي للشعر أو العين.

#### الخطوة 5: حارس المقروئية الإلزامي (Readability Guard - WCAG AAA)
- **القاعدة الذهبية**: لا يُسمح أبداً بعرض لون الشخصية بشكل خام إذا كان سيؤدي لصعوبة القراءة.
- يقوم الحارس باحتساب التباين الضوئي وفق معيار **WCAG 2.2 AAA** (نسبة تباين لا تقل عن 7:1):
  - إذا كانت الشخصية ذات شعر أصفر فاقع أو رمادي فاتح أو أبيض: يُلزم المحرك بتطبيق حد خارجي عريض (Black Stroke 3.5px) وظل ناعم داكن خلف النص، أو تعديل طفيف لدرجة الإشباع (Chroma Adjustment).
  - إذا كانت الشخصية ذات شعر أسود حالك وخلفية المشهد ليلية: يقوم المحرك تلقائياً برفع إضاءة اللون قليلاً أو إضافة توهج محيطي (Glow Effect) بلون ثانوي من زي الشخصية.

#### الخطوة 6: ربط المتحدث وحفظ بطاقة الشخصية (Speaker Profile)
- عند اكتشاف اسم المتحدث في الملف (مثل `[Luffy]:` أو وسوم أسلوب ASS)، يتم ربط اللون بملف الشخصية داخل المشروع.
- تُعرض للشخص شاشة جانبية سريعة تسمح له بتغيير خيار التلوين بلمسة واحدة:
  - *"تلوين حسب لون شعر لوفي (أسود نفاث مع حد أبيض)"*
  - *"تلوين حسب لون عين زورو (أخضر زمردي)"*
  - *"تلوين حسب زي الشخصية"*

---

## 7. محرك الترجمة العالمية السياقي وحفظ المصطلحات (Context-Aware Translation Engine)

### 7.1 الترجمة السياقية عبر النافذة المنزلقة (Sliding Context Window)
تعتمد الترجمات الآلية التقليدية على ترجمة كل سطر بمعزل عن الآخر، مما يؤدي إلى:
- أخطاء فادحة في الضمائر (ترجمة "He" بدلاً من "She").
- تحويل صيغ المذكر إلى مؤنث والعكس في اللغة العربية.
- تدهور أسلوب الحوار الدرامي.

**حل Vela الذكي**:
يتم تجميع الأسطر في دفعات سياقية ذكية (نافذة منزلقة من 6 إلى 10 أسطر متتالية) مع تمرير أسماء المتحدثين ووصف نوع العمل (أنمي، فيلم وثائقي، خيال علمي) لنماذج الترجمة، مما ينتج صياغة لغوية عربية متماسكة ودرامية تنافس الترجمة البشرية.

### 7.2 مسرد المصطلحات وحماية الأسماء (Project Glossary)
- يتيح التطبيق لكل فيلم أو مسلسل إنشاء مسرد مصطلحات خاص (Glossary).
- تمنع هذه الميزة تشويه أسماء الشخصيات والتقنيات والأماكن (مثل ضمان بقاء "Jutsu" أو "Sharingan" أو أسماء المركبات الفضائية كما هي دون ترجمتها إلى كلمات مضحكة).

### 7.3 الحفاظ المطلق على التوقيت ووسوم التنسيق
- يقوم المحرك بحماية وسوم الـ HTML والـ ASS مثل `<i>`, `<b>`, `{\an8}`, `\N`، حيث يتم عزلها قبل إرسال النص لمحرك الترجمة ثم إعادة دمجها في مواضعها الصحيحة بدقة متناهية.

---

## 8. استخراج الترجمات المدمجة بالفيديو بصرياً (Burned-in Subtitle OCR & Inpainting)

في كثير من الأحيان، يتوفر للمستخدم فيديو يحتوي على ترجمة "محروقة ومدمجة بالصورة" (Hardcoded Subtitles) بلغة أخرى غير مرغوبة أو بجودة رديئة:
1. **كشف وتحديد مكان النص (Text Detection)**: استخدام نموذج خفيف مثل **CRAFT / PaddleOCR** لتحديد المستطيلات المحيطة بالنصوص المكتوبة على إطارات الفيديو.
2. **استخراج النص وتوقيته (Optical Character Recognition - OCR)**: تحويل النصوص المحروقة إلى ملف ترجمة ناعم بصيغة SRT مع توقيت ظهور واختفاء كل جملة.
3. **طمس أو إزالة النص القديم (Fast Video Inpainting)**: إمكانية تطبيق قناع طمس ذكي ناعم (Gaussian Blur Mask) فوق مكان الترجمة القديمة أسفل الفيديو، لعرض الترجمة الجديدة الأنيقة فوقها دون أي تداخل بصري مشوه.

---

## 9. ميزات التنافس والتفوق الكامل على MX Player (Comprehensive Feature Parity)

| الميزة | MX Player Pro | Vela Player (تطبيقنا) |
|---|:---:|:---:|
| **فك ترميز عتادي وبرمجي (HW / HW+ / SW)** | مدعوم | مدعوم ومحسن لنظامي Android و iOS |
| **تضخيم الصوت الفائق (Audio Boost)** | حتى 200% (أندرويد فقط) | حتى 200% (+12dB) مع مانع تشويه الصوت (Soft Limiter) على Android و iOS |
| **معادل الصوت (Audio Equalizer)** | أساسي | احترافي (10-Band EQ) مع تضخيم الجهير ومحسن نقاء الحوارات |
| **الوضع الليلي للصوت (Night Mode)** | غير متوفر | متوفر (ضغط المجال الديناميكي لرفع الهمس وخفض الانفجارات) |
| **إيماءات السطوع ومستوى الصوت والتقديم** | مدعوم | مدعوم مع نافذة مصغرة للإطار (Thumbnail Scrubbing) |
| **تسريع لحظي بضغط مطول (2.0x Boost)** | غير متوفر | مدعوم بسلاسة بنقرة واحدة مستمرة |
| **تكبير ونسبة العرض (Pinch to Zoom)** | مدعوم (حتى 200%) | مدعوم من 50% حتى 400% مع أوضاع (Fit, Fill, 16:9, 18:9, 21:9, Zoom) |
| **تشغيل في الخلفية وصورة داخل صورة (PiP)** | مدعوم | مدعوم بنظام MediaSessionService المكتمل والتحكم عبر شاشة القفل |
| **تصفح ومشاركة الشبكات المحلية (SMB, DLNA, WebDAV, FTP)** | يحتاج إضافات معقدة | مدمج أصلياً لاكتشاف سيرفرات المنزل والكمبيوتر بنقرة واحدة |
| **تشغيل روابط البث والتورنت المباشر (Magnet)** | دعم روابط عادي | دعم روابط HLS/DASH + تشغيل مباشر لملفات الماجنت والتورنت |
| **خزنة الخصوصية المشفرة (Secret Vault)** | قفل بسيط بكلمة مرور | تشفير محلي كامل AES-256 محمي بالبصمة الحيوية (Fingerprint / Face ID) |
| **قفل الأطفال الذكي (Kids Lock)** | مدعوم | مدعوم مع رسومات تفاعلية مرحة لإلغاء القفل |
| **تكرار مقطع (A-B Repeat)** | مدعوم | مدعوم مع ميزة حفظ مقاطع لتعلم اللغات الأجنبية |
| **بحث وتحميل الترجمات من الإنترنت** | OpenSubtitles قديم | بحث تلقائي عبر بصمة الفيديو (Hash Matching) عبر OpenSubtitles REST v3 و Subdl |
| **المزامنة الصوتية بالذكاء الاصطناعي** | غير موجود إطلاقاً | مدمج أصلياً (Acoustic Waveform VAD + DTW) بنقرة زر |
| **تلوين الترجمة حسب لون شعر وعين الشخصيات** | غير موجود إطلاقاً | ابتكار حصري عالمي مع حارس المقروئية WCAG AAA |
| **ترجمة النصوص بين جميع لغات العالم** | يحتاج أدوات خارجية | مدمج سياقياً مع مسرد للمصطلحات |
| **الإعلانات المزعجة** | مليء بالإعلانات بالنسخة المجانية | خالي تماماً من الإعلانات في جميع الباقات |

---

## 10. واجهة وتجربة المستخدم الحديثة (Modern Luxury UI/UX Design System)

### 10.1 الهوية البصرية وفلسفة التصميم
- **فلسفة المحتوى أولاً (Content-First Immersive Experience)**: واجهة مشغل الفيديو تختفي بالكامل بعد 3 ثوانٍ من عدم اللمس، ولا تظهر أي أزرار أو حواف مشتتة تعيق تجربة المشاهدة.
- **التصميم الزجاجي الفاخر (Dark Frosted Glassmorphism)**: استخدام أسطح داكنة بلمعان زجاجي ناعم مع ضبابية حركية (Backdrop Blur 20px) وحدود رفيعة جداً (`rgba(255, 255, 255, 0.08)`).
- **الألوان المعتمدة**:
  - خلفية السواد المطلق (AMOLED Pure Black): `#000000` لشاشات الهواتف المتطورة لتوفير طاقة البطارية.
  - السطح الداكن (Obsidian Surface): `#0D0F17`.
  - لون التمييز الكهربائي (Electric Indigo Accent): `#6366F1` متدرجاً مع البنفسجي الفاخر `#8B5CF6`.
  - الألوان الوظيفية: الأخضر الزمردي للنجاح `#10B981`، الأحمر المرجاني للتحذير `#EF4444`، والعنبري للحالات الخاصة `#F59E0B`.

### 10.2 الحركات التفاعلية واستجابة اللمس (120Hz Micro-Interactions)
- حركات انتقال سلسة ونابضة بالحياة (Spring Physics & Hero Animations) عند فتح مشغل الفيديو واستوديو التنسيق.
- اهتزازات لمسية خفيفة (Haptic Feedback) عند تغيير مستوى الصوت إلى الحد الأقصى أو عند الوصول لنقطة مزامنة دقيقة.
- دعم كامل ودقيق لاتجاه اليمين لليسار (RTL) للغة العربية مع الحفاظ على ملاءمة الأيقونات وحركة السحب.

---

## 11. الأمان والخصوصية ومجلد الخزنة المشفرة (Security, Privacy & Private Vault)

### 11.1 مبدأ الخصوصية المحلية أولاً (Local-First Architecture)
- كافة عمليات تشغيل الفيديو، وتصفح الملفات، وتعديل التوقيتات، واستعراض الترجمات تتم **محلياً 100%** على جهاز المستخدم دون الاتصال بالإنترنت.
- لا يتم إرسال أي فيديو أو مقطع صوتي لسيرفرات خارجية إطلاقاً.
- ميزات الذكاء الاصطناعي السحابية (كالترجمة الآلية المتقدمة) تتطلب موافقة صريحة من المستخدم مع إظهار حجم النص المرسل وتشفيره بالكامل عبر HTTPS/TLS 1.3 وحذفه فور اكتمال المعالجة.

### 11.2 خزنة الفيديوهات والترجمات السرية (Secure Vault)
- مجلد خاص داخل التطبيق يتم تشفير مسارات ملفاته وبياناته الوصفية محلياً باستخدام معيار **AES-256-GCM**.
- المفاتيح المشفرة تُخزن في عتاد الحماية المتقدم للجهاز: **Android Keystore** لنظام أندرويد و **iOS Keychain** لأجهزة آبل.
- الدخول للخزنة يتطلب بصمة الإصبع، التعرف على الوجه (Face ID)، أو رمز مرور سري (PIN).
- منع ظهور الفيديوهات الموجودة داخل الخزنة في استوديو الصور أو مشغلات الوسائط الأخرى في الهاتف (إضافة ملف `.nomedia` التلقائي).

---

## 12. معمارية النظام والشيفرة المصدرية (System Architecture & Monorepo Structure)

تعتمد البنية البرمجية على معمارية أحادية المستودع مجزأة إلى حزم مستقلة (**Modular Monorepo**) تضمن سهولة الاختبار والصيانة والتطوير المستقبلي:

```
ahmedabbas358/Vela-Player
├── packages/
│   ├── player_engine/           # محرك التشغيل وفك الترميز والإيماءات والـ PiP
│   │   ├── lib/src/decoders/    # واجهات الربط العتادي (MediaCodec / VideoToolbox / libmpv)
│   │   ├── lib/src/gestures/    # معالجات اللمس، السحب، السطوع، ومستوى الصوت
│   │   └── lib/src/audio/       # المعادل الصوتي (EQ)، وتضخيم الصوت 200%، والوضع الليلي
│   │
│   ├── subtitle_core/           # نواة الترجمة النقية (Pure Dart - Zero UI dependencies)
│   │   ├── lib/src/parsers/     # محللات SRT, VTT, ASS, TTML, MicroDVD
│   │   ├── lib/src/sync/        # خوارزميات Offset, Drift Correction, VAD, DTW
│   │   └── lib/src/health/      # فحص أخطاء الترجمة (Overlaps, CPS, Negative Timings)
│   │
│   ├── ai_studio/               # حزمة الذكاء الاصطناعي ومعالجة الرؤية الحاسوبية
│   │   ├── lib/src/face_detect/ # كشف وجوه وملامح الأنمي والتمثيل الواقعي
│   │   ├── lib/src/color/       # عزل الشعر والعين وحساب الألوان السائدة في فضاء Lab
│   │   ├── lib/src/readability/ # حارس المقروئية والتباين الإلزامي (WCAG AAA)
│   │   └── lib/src/translation/ # محرك الترجمة السياقية ومسرد المصطلحات
│   │
│   ├── network_streamer/        # محرك اتصالات الشبكة المحلية والبث
│   │   ├── lib/src/smb/         # بروتوكولات SMB v2/v3 للاتصال بالحواسيب
│   │   ├── lib/src/dlna/        # بروتوكولات DLNA/UPnP لسيرفرات الوسائط
│   │   └── lib/src/torrent/     # البث المتتابع لملفات التورنت والماجنت
│   │
│   └── design_system/           # الرموز البصرية، الألوان، المكونات، والخطوط
│
├── backend/                     # الخادم السحابي المساند للمهام الكبيرة (FastAPI + Python 3.11)
│   ├── app/api/v1/              # واجهات الفوترة، والترجمة المتقدمة، وإشعارات المتاجر
│   ├── app/services/ai/         # بوابات نماذج Whisper و DeepL والترجمة السياقية
│   └── app/services/billing/    # التحقق من إيصالات Google Play و StoreKit 2
│
└── lib/                         # تطبيق فلاتر المجمع (Flutter Application Assembly)
    ├── core/                    # إدارة الأذونات، التخزين المشفر، وإدارة الحالة (Riverpod)
    └── features/                # شاشات التطبيق: المشغل، الاستوديو، المكتبة، والخزنة
```

---

## 13. نموذج الاشتراكات والفوترة والجاهزية للمتاجر (Monetization & Store Compliance)

### 13.1 باقات الاشتراك وأسعارها الرمزية المدروسة
لضمان تحقيق أوسع انتشار عالمي وكسب ثقة المستخدمين، تم اعتماد نموذج **Freemium عادل وخالي تماماً من الإعلانات**:

| الباقة | السعر المقترح | المزايا المتاحة |
|---|:---:|---|
| **الباقة المجانية للأبد (Free)** | **$0.00** | - مشغل فيديو وصوت كامل 100% بدون أي إعلانات.<br>- فك ترميز عتادي كامل لكافة الصيغ 4K/8K.<br>- كافة الإيماءات وتضخيم الصوت 200% ومعادل الصوت.<br>- تعديل يدوي كامل للترجمة وتغيير الخط والموضع.<br>- 30 نقطة تجربة مجانية لميزات الذكاء الاصطناعي. |
| **التذكرة الأسبوعية (Weekly)** | **$0.99** / أسبوع | - وصول كامل لكافة ميزات الذكاء الاصطناعي.<br>- مخصصة لمشاهدة فيلم أو عطلة نهاية الأسبوع دون التزام طويل. |
| **الباقة الشهرية (Monthly Pro)** | **$1.99** / شهر | - مزامنة صوتية غير محدودة بالذكاء الاصطناعي.<br>- تلوين الترجمة حسب لون شعر وعين الشخصيات لكافة المسلسلات.<br>- 500 نقطة ترجمة سياقية شهرياً.<br>- تصفح سيرفرات الشبكة ومجلد الخزنة المشفرة. |
| **الباقة السنوية (Annual VIP)** | **$14.99** / سنة | - وفر أكثر من 40% (ما يعادل $1.24 فقط شهرياً).<br>- كافة ميزات Pro مع معالجة سريعة ذات أولوية قصوى و 2,500 نقطة ترجمة شهرياً. |
| **رخصة مدى الحياة (Lifetime)** | **$34.99** مرة واحدة | - دفع لمرة واحدة وامتلاك التطبيق وميزاته للأبد للمستخدمين الأوفياء. |

### 13.2 الامتثال التقني الكامل لمتاجر التطبيقات (Google Play & Apple App Store)
1. **متطلبات Google Play لعام 2026**:
   - استهداف أحدث إصدار نظام: `compileSdk = 36` و `targetSdkVersion = 36` (Android 16).
   - **تفادي الرفض الشائع**: عدم طلب إذن `MANAGE_EXTERNAL_STORAGE` المرفوض غالباً، والاعتماد بدلاً من ذلك على أذونات الوسائط المخصصة لنظام Android 13+ (`READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`) مع منتقي ملفات النظام (Storage Access Framework - SAF) لاختيار المجلدات بحرية كاملة ودون أي مخالفة لسياسات جوجل.
   - دمج مكتبة **Google Play Billing Library 9.1+** مع معالجة إشعارات المطورين في الوقت الفعلي (RTDN).
   - استيفاء كامل لنموذج سلامة البيانات (Data Safety Section) وإثبات عدم تتبع المستخدمين أو بيع بياناتهم.
2. **متطلبات Apple App Store**:
   - بناء التطبيق باستخدام أحدث SDK عبر Xcode 26+.
   - دمج تقنية **Apple StoreKit 2** للاشتراكات المتجددة تلقائياً مع توفير زر "استعادة المشتريات" (Restore Purchases) وشروط الاستخدام (EULA) وسياسة الخصوصية الواضحة.
   - دعم كامل لتقنيات آبل: Picture-in-Picture، شاشة القفل، والتحكم عبر سماعات AirPods.

---

## 14. خطة الاختبارات وضمان الجودة الصارمة (Testing & QA Strategy)

1. **اختبارات المطابقة الذهبية للملفات (Golden File Tests)**:
   - فحص استيراد وتصدير أكثر من 500 ملف ترجمة حقيقي من مختلف الصيغ والتأكد من عدم ضياع أي حرف أو وسم تنسيق.
2. **اختبارات التوقيت الحسابي (Deterministic Property Tests)**:
   - التحقق رياضياً من استحالة إنتاج أي سطر ينتهي قبل بدايته، أو أسطر ذات مدة سالبة، أو تداخلات زمنية غير منطقية.
3. **مكتبة وسائط الفحص المتنوعة (Media Fixtures)**:
   - نماذج فيديو حقيقية لقطات أنمي سريعة (60fps)، أفلام مظلمة، مقاطع ذات ضوضاء صوتية مرتفعة، ونصوص عربية غنية بالحركات والتشكيل.
4. **اختبارات فك التشفير والأداء (Performance Benchmarks)**:
   - استهلاك ذاكرة عشوائية (RAM) أقل من 150 ميجابايت أثناء تشغيل فيديو 4K بمعدل 60 إطار في الثانية.
   - زمن بدء تشغيل الفيديو (Startup Latency) أقل من 300 مللي ثانية.

---

## 15. البرومبت الماستر فائق الدقة لبناء التطبيق (The Definitive Master Build Prompt)

انسخ هذا النص الماستر بالكامل ومرره لأي وكيل برمجي ذكي أو فريق هندسي للبدء فوراً في التوليد البرمجي الدقيق للنظام:

```text
================================================================================
VELA PLAYER — ULTIMATE MASTER SYSTEM SPECIFICATION & PRODUCTION BUILD PROMPT
================================================================================

ROLE & IDENTITY:
You are the Principal Cross-Platform Mobile Systems Architect, Core Media Streaming Engineer (C++/FFmpeg/libmpv), Subtitle Processing Scientist, Applied AI/Vision Engineer, High-End Product Designer, and App Store/Google Play Release Lead.

MISSION:
Build a complete, production-grade, commercial-ready mobile application called "Vela Player" for Android and iOS using Flutter (with native C++/Kotlin/Swift bridges where performance requires). The app combines an ultra-high-performance offline media player (decisively outperforming MX Player and VLC) with a revolutionary Subtitle Intelligence Studio.

CORE VALUE PROPOSITION & CAPABILITIES:
1. UNIVERSAL MEDIA PLAYBACK (MX PLAYER KILLER):
   - Multi-engine architecture: Hardware (HW via MediaCodec & VideoToolbox), Hardware Plus (HW+ with custom shader color grading), and Software (SW via C++ libmpv / FFmpeg 7+ for 10-bit Hi10P anime and legacy codecs).
   - Video containers: MKV, MP4, WebM, AVI, MOV, TS, M2TS, FLV, WMV, ISO.
   - Audio formats: AAC, AC3, E-AC3, TrueHD, Atmos, DTS, DTS-HD, FLAC, ALAC, MP3, OPUS.
   - Audio supercharge: Up to 200% Preamp Audio Boost with soft limiter (zero distortion clipping). 10-Band Graphic Equalizer, Bass Boost, Vocal Clarity enhancer, and Night Mode Dynamic Range Compressor.
   - Intuitive precision gestures: Left vertical drag = Brightness (0-100%); Right vertical drag = Volume (0-200%); Horizontal drag = Seek with live thumbnail scrubbing preview; Double tap = +/-10s seek; Long press = Instant 2.0x speed boost; Two-finger pinch = Free zoom 50% to 400% with aspect ratio switcher (Fit, Fill, 16:9, 18:9, 21:9).
   - Background audio playback with full MediaSessionService notification / iOS lockscreen controls and Picture-in-Picture (PiP).
   - Network streaming: SMB v2/v3, FTP, SFTP, WebDAV, DLNA/UPnP, HLS (.m3u8), DASH, and sequential Torrent/Magnet stream buffering.
   - Privacy Vault: AES-256 encrypted hidden folder protected by biometric authentication (Fingerprint / Face ID).
   - Kids Lock: Screen touch-freeze mode with playful unlocking sequence.
   - Language Learning tools: A-B Repeat loop mode and pitch-corrected variable speed (0.25x to 4.0x).

2. UNIVERSAL SUBTITLE ENGINE:
   - Bi-directional support for SRT, WebVTT (.vtt), ASS/SSA (.ass, .ssa with full vector drawing \p1, positioning \pos, and karaoke \k tags), TTML, SAMI, MicroDVD, and LRC.
   - PGS/SUP and VobSub bitmap subtitle rendering with integrated on-device OCR text extraction.
   - Embedded MKV/MP4 subtitle track extraction on the fly without external file demuxing.
   - In-app subtitle downloader integrating OpenSubtitles REST API v3 (with video hash matching) and Subdl.

3. QUAD-TIER SMART SYNCHRONIZATION:
   - Tier 1: Global Offset slider (+/- ms).
   - Tier 2: 2-Point Linear Drift Correction calculating t' = t + delta1 + ((t - t1)/(t2 - t1)) * (delta2 - delta1) to resolve 23.976 vs 25 vs 29.97 FPS frame mismatches.
   - Tier 3: Acoustic Waveform Auto-Sync extracting 16kHz mono audio, detecting human voice activity (Silero VAD), and performing Dynamic Time Warping (DTW) / Cross-Correlation against subtitle cue timestamps for 1-tap instant synchronization.
   - Tier 4: Speech-to-Text Forced Alignment using Whisper word-level timestamps matched via Needleman-Wunsch sequence alignment.

4. AI VISUAL CHARACTER STYLING (HAIR & EYE COLOR EXTRACTION):
   - Keyframe extraction at dialogue timestamps.
   - Face and character detection tailored for both Anime (AnimeFace / YOLOv8-Anime) and Live-Action (MediaPipe FaceMesh).
   - Semantic segmentation masks for character hair contours and iris centers.
   - Dominant color extraction using K-Means (k=3) clustering in perceptually uniform CIE-L*a*b* color space, ignoring specular highlights and deep shadows.
   - Readability Guard: Mandatory WCAG 2.2 AAA contrast enforcement (minimum 7:1 ratio) automatically applying protective dark borders (Stroke >= 3.5px), drop shadows, or chroma adjustment so light/dark hair colors never become unreadable over bright video frames.
   - Full manual override via interactive Character Palette Bottom Sheet.

5. CONTEXT-AWARE TRANSLATION & BEAUTIFICATION:
   - Universal translation between any world languages (English, Arabic, Japanese, Korean, Spanish, French, German, Turkish, etc.).
   - Sliding Context Window (6-10 sequential dialogue lines) preserving dramatic tone, pronouns, and masculine/feminine Arabic grammatical agreement.
   - Project Glossary to lock proper character names, techniques, and franchise terminology.
   - Rich typography studio: Embedded Cairo, Readex Pro, Noto Sans Arabic, and Inter fonts, plus native custom .ttf/.otf file importer.
   - Full drag-and-drop subtitle positioning on screen with custom X/Y coordinate persistence.
   - True BiDi Arabic text shaping with diacritics and punctuation flip protection.

6. HARDCODED (BURNED-IN) SUBTITLE OCR & INPAINTING:
   - Detection of burned-in video subtitles via lightweight CRAFT / PaddleOCR.
   - Automatic extraction into editable soft SRT cues and optional smooth Gaussian inpainting overlay to mask original burned-in text.

7. UX/UI & LUXURY DESIGN SYSTEM:
   - Modern dark luxury aesthetics: AMOLED Pure Black (#000000) and Obsidian (#0D0F17) with frosted glassmorphism (Backdrop Blur 20px, 1px subtle borders).
   - Electric Indigo accent (#6366F1) and Violet (#8B5CF6).
   - Fluid 120Hz micro-animations, physics-based springs, and haptic feedback.
   - 100% ad-free experience across all tiers.
   - Native bilingual RTL (Arabic) and LTR (English) localization.

8. MONETIZATION & STORE READINESS:
   - Free tier: 100% ad-free, full hardware player, all gestures, manual subtitle styling, and trial AI credits.
   - Symbolic subscription plans: Weekly ($0.99), Monthly Pro ($1.99 - $2.49), Annual VIP ($14.99), and Lifetime License ($34.99 - $39.99).
   - Official integration with Google Play Billing 9.1+ and Apple StoreKit 2 with server-side receipt validation.
   - Target Android 16 (API Level 36) and iOS 18/26 SDKs.
   - Scoped storage compliance using Android 13+ granular media permissions and SAF File Picker (zero usage of dangerous MANAGE_EXTERNAL_STORAGE).

ENGINEERING CONSTRAINTS:
- NEVER destructively overwrite user video or subtitle files (Immutable Project Versioning with full Undo/Redo).
- Local-first architecture: All player and manual editing features work completely offline.
- Memory leak prevention: Virtualized cue lists, frame buffer reuse, and streaming playback without loading entire video files into RAM.
- Deliver production code, fully typed interfaces, comprehensive unit/widget tests, and complete error boundaries.
================================================================================
```

---

## 16. خارطة الطريق التنفيذية ومعايير الإنجاز (Roadmap & Definition of Done)

```
[المرحلة 1: النواة العتادية] ──> مشغل الوسائط، فك الترميز HW/SW، وكامل إيماءات اللمس وتضخيم الصوت 200%
             │
[المرحلة 2: استوديو الترجمة] ──> محللات الصيغ (SRT/VTT/ASS)، الفحص الصحي، وسحب وإسقاط المواضع
             │
[المرحلة 3: المزامنة الصوتية] ──> محرك الإزاحة، وتصحيح انحراف الـ FPS، ومزامنة VAD + DTW الصوتية
             │
[المرحلة 4: الذكاء الاصطناعي] ──> عزل ألوان شعر وعين الشخصيات، حارس المقروئية، والترجمة السياقية
             │
[المرحلة 5: الشبكات والخزنة] ──> مشاركة SMB/DLNA، تشغيل التورنت، ومجلد الخزنة المشفرة بالبصمة
             │
[المرحلة 6: الفوترة والمتاجر] ──> دمج Google Play Billing و StoreKit 2، وفحوصات نشر Android 16
```

### معايير الإنجاز الصارمة (Definition of Done):
- [x] تشغيل سلس لفيديوهات 4K 60fps باستهلاك معالج منخفض وبدون أي تقطيع في الإطارات.
- [x] حل مشكلة تأخر الترجمة بلمسة واحدة عبر المزامنة الصوتية التلقائية.
- [x] تلوين الأسطر حسب الشخصية بنسبة مقروئية وتباين تتجاوز معايير WCAG AAA.
- [x] دعم وتنسيق كامل للغة العربية (RTL) دون أي تشويه في التشكيل أو علامات الترقيم.
- [x] خلو التطبيق تماماً من الإعلانات وجاهزيته الكاملة للاشتراكات المعتمدة على متجري Google Play و App Store.
- [x] مطابقة كافة اشتراطات الأمان وحماية بيانات المستخدمين لعام 2026.
