# خريطة هندسية شاملة + Master Build Prompt
## تطبيق Subtitle Intelligence + Media Player متعدد المنصات
**Android + iOS | Product Architecture | AI | Subtitle Engine | Privacy | Security | UX/UI | Billing | QA | Google Play / App Store**
*الإصدار: 1.0 — مُعدّ كنقطة انطلاق فعلية للتطوير والإنتاج*

---

## الفكرة الأساسية
منتج يجمع بين مشغل وسائط حديث وبين استوديو ذكي للترجمة. يستطيع المستخدم تشغيل الفيديو والصوت، استيراد ملفات الترجمة، إصلاح التوقيت، تنظيف النص، تحسين المظهر، ترجمة الترجمة بين لغات العالم، ثم إنشاء Styling متقدم قائم على الشخصيات والمشهد، مع تحكم يدوي كامل وطبقات خصوصية واضحة.

> **ملاحظة هندسية مهمة**: لن تكون كل ميزات الذكاء الاصطناعي Offline على كل جهاز. لذلك تُبنى المنصة على **Local-first + Cloud-optional** مع واجهات Provider-agnostic، بحيث يعمل المشغل والعمليات الأساسية محلياً، بينما الميزات المكلفة أو التي تحتاج نماذج كبيرة تستخدم المعالجة السحابية فقط بعد موافقة المستخدم الصريحة.

---

## فهرس الوثيقة

1. **Product Vision & Differentiation**
2. **Functional Scope**
3. **Subtitle Intelligence Architecture**
4. **Smart Synchronization Engine**
5. **Translation Engine**
6. **AI Visual Styling & Readability Guard**
7. **Media Player**
8. **UX/UI & Design System**
9. **Privacy, Security & Trust**
10. **Technical Architecture**
11. **Data Model & APIs**
12. **Monetization & Subscriptions**
13. **Performance & Cost Controls**
14. **Testing & QA**
15. **Release / Google Play / App Store Readiness**
16. **Development Roadmap**
17. **Master Build Prompt**
18. **Definition of Done (DoD)**

---

## 1. Product Vision & Differentiation

### الرؤية
بناء مشغل وسائط تكون الترجمة فيه جزءاً أساسياً من تجربة التشغيل، وليس مجرد ملف نصي يُعرض أسفل الفيديو. الميزة الفارقة هي **Subtitle Intelligence**: فهم التوقيت، النص، سرعة القراءة، المظهر، الشخصيات، والمشهد، ثم اقتراح وتنفيذ نتيجة أفضل مع إبقاء التحكم النهائي للمستخدم.

### Positioning
- **مشغل وسائط كامل** للمستخدم اليومي (ينافس ويتفوق على MX Player و VLC).
- **Subtitle Studio** للمستخدم الذي يصنع/يصحح/يترجم الترجمات باحترافية.
- **AI Styling** للمشاهد التي تحتوي على عدة شخصيات أو أساليب بصرية متباينة (الأنمي، المسلسلات، الأفلام).
- **Workflow متكامل**: `Import → Analyze → Fix → Translate → Style → Preview → Export`.
- **Local-first** لحماية ملفات المستخدم، مع Cloud AI اختياري عند الحاجة فقط.
- **واجهة لا تبدو "AI-looking"**: تصميم هادئ، واضح، سريع، واحترافي مستوحى من Apple و Linear و Notion.
- **مبدأ تنافسي حاسم**: لا تبدأ بمجرد تقليد MX Player بالكامل؛ ابنِ نواة ثورية حول الترجمة والذكاء الاصطناعي، ثم وسّع المشغل. هذا يقلل مخاطر المشروع ويعطيه سبباً واضحاً وجذاباً للاستخدام فوراً.

---

## 2. Functional Scope

| المجال | الإصدار الأساسي (Core) | الإصدار المتقدم (Pro / AI) |
|---|---|---|
| **Playback** | تشغيل الفيديو والصوت، Seek، Speed، Resume، Audio tracks، Subtitle tracks | PiP، Chapter-aware، Advanced gestures، Playback profiles، Device optimization |
| **Subtitle Formats** | SRT، VTT، ASS/SSA كحد أدنى | TTML، WebVTT advanced، Subtitle image formats حسب الترخيص |
| **Editing** | Offset، Split، Merge، Timing، Text editing | Batch operations، Rules engine، Versioning، Diff view، Automated repair |
| **Translation** | Source/Target، Auto-detect، Batch | Context memory، Glossary، Speaker consistency، Review queue، Quality pass |
| **Styling** | Font، Size، Color، Outline، Shadow، Position | Speaker profiles، Scene-aware styling، Color extraction، Automated contrast |
| **Library** | Folders، Recent، Favorites، History | Metadata، Artwork، Smart collections، Sync of project metadata |
| **Accessibility** | Dynamic text، High contrast، Reduced motion | Readability presets، Dyslexia-friendly options، Enhanced screen-reader |

### تفاصيل مدعومة داخل Subtitle Studio:
- إزاحة كافة الأسطر بمقدار زمني ($\pm\text{ms}$).
- تمديد أو ضغط التوقيت بنسبة مئوية (Time Stretch/Compress).
- تثبيت الارتكاز (Apply Anchor): "هذا السطر يبدأ هنا" ثم إعادة توزيع التوقيت خطياً.
- كشف التداخلات (Overlaps)، الأوقات السالبة، والفجوات المستحيلة.
- كشف سرعة القراءة المرتفعة (CPS - Characters Per Second $> 21$).
- كشف الأسطر الطويلة وتقسيمها وفق إيقاع القراءة الطبيعي وعلامات الترقيم.
- تنظيف المسافات وعلامات الترقيم دون تغيير المعنى.
- إيجاد الأسطر المكررة وشبه المكررة وحذفها.
- الحفاظ على وسوم الأنماط (Style Tags) عند التصدير للصيغ الداعمة لها (مثل ASS).
- التراجع والإعادة متعدد الخطوات (Undo/Redo) مع سجل إصدارات محفوظ.

---

## 3. Subtitle Intelligence Architecture

استخدم **Internal Subtitle Representation موحّدة (Unified Subtitle Model)**، ولا تجعل منطق التطبيق مرتبطاً بـ SRT أو ASS مباشرة.

```typescript
interface Cue {
  id: string;
  startMs: number;
  endMs: number;
  text: string;
  speakerId?: string;
  characterId?: string;
  styleId?: string;
  sourceFormat: 'srt' | 'vtt' | 'ass' | 'ttml';
  confidence: number;
  metadata: Record<string, any>;
}

interface SubtitleProject {
  id: string;
  mediaId: string;
  language: string;
  version: number;
  cues: Cue[];
  styleProfiles: StyleProfile[];
  glossaryId?: string;
  createdAt: string;
}
```

### خط المعالجة (Pipeline):
$$\text{Parser Adapters} \longrightarrow \text{Normalizer} \longrightarrow \text{Validator} \longrightarrow \text{Analyzer} \longrightarrow \text{Repair Planner} \longrightarrow \text{Preview} \longrightarrow \text{Commit Version} \longrightarrow \text{Export Adapter}$$

- كل عملية تعديل تنتج إصداراً جديداً (Version)؛ الملف الأصلي **Immutable** ولا يتم الكتابة فوقه أبداً.
- يُعرض سبب التعديل للمستخدم بوضوح: *Overlap fixed*، *CPS reduced*، *Punctuation normalized*، *Drift corrected*.

---

## 4. Smart Synchronization Engine

المزامنة طبقية تبدأ بالأقل استهلاكاً للموارد ثم تتدرج:

| المستوى | الطريقة | الاستخدام والحالة |
|:---:|---|---|
| **A** | **Global Offset** | عندما تكون الترجمة متقدمة أو متأخرة بالكامل بنفس المقدار ($\pm N\text{ ms}$). |
| **B** | **Multi-point Drift** | عندما يبدأ الملف صحيحاً ثم ينحرف تدريجياً باختلاف الـ FPS ($t' = t + \Delta_1 + \frac{t - t_1}{t_2 - t_1} (\Delta_2 - \Delta_1)$). |
| **C** | **Speech/Audio Alignment** | مطابقة موجات الكلام مع نصوص الحوار عبر Dynamic Time Warping عند توفر التفريغ. |
| **D** | **Scene/Anchor Alignment** | استخدام حدود المشاهد أو ارتكازات متعددة يحددها المستخدم. |
| **E** | **Human Review** | مراجعة بصرية عندما تكون درجة الثقة منخفضة أو المشهد صاخباً. |

> **قاعدة UX صارمة**: لا تنفذ مزامنة الذكاء الاصطناعي على الملف مباشرة. اعرض دائماً شاشة مقارنة: `Before / Proposed / Confidence / Accept / Reject / Revert`.

---

## 5. Translation Engine

### المعمارية:
$$\text{Source Cues} \longrightarrow \text{Lang Detect} \longrightarrow \text{Segmentation} \longrightarrow \text{Context Window} \longrightarrow \text{Glossary/Terms} \longrightarrow \text{Translation} \longrightarrow \text{Consistency} \longrightarrow \text{Constraints} \longrightarrow \text{Review} \longrightarrow \text{Export}$$

- استخدام نافذة سياقية (Context Window تضم 5 أسطر سابقة وسطرين تاليين) لمنع تدهور الضمائر والتذكير والتأنيث.
- مسرد مصطلحات (Glossary) لكل مشروع لحفظ أسماء الشخصيات والتقنيات والمصطلحات المفضلة.
- الحفاظ على معرفات المتحدثين والشخصيات عبر الترجمة.
- بوابات الجودة (Quality Gates): كشف الترجمات الفارغة، الطول الزائد، تسرب نصوص الحشو (Placeholders)، واختلاط اللغات الشاذ.
- محدد المعالجة (Local vs Cloud Selector) مع حاسبة تكلفة تقديرية (Usage Estimator) قبل بدء العمليات المكلفة.

---

## 6. AI Visual Styling & Readability Guard

### استخراج ألوان الشخصيات
- كاشف المشاهد (Scene Detector) يحدد لقطات الانتقال.
- عينات من الإطارات (Sample Frames) بدلاً من معالجة كل إطار لتوفير البطارية والحرارة.
- تتبع الشخصيات (Character Tracking) واستخراج ألوان الشعر والعين والزي السائدة.
- **حارس القراءة (Readability Guard)**: لا يُعتمد أي لون خام تلقائياً؛ بل يمر عبر فحص التباين (Contrast Ratio)، ويضاف خط حماية (Stroke) وظل ناعم أو يُبدل إلى أقرب درجة مقروءة تتوافق مع معايير WCAG AAA.
- **نمط الأنمي (Anime Mode)**: ألوان شعر وعيون دقيقة على رسومات نقية.
- **نمط التمثيل الواقعي (Live-Action Mode)**: تتبع متحفظ لمنع تذبذب ألوان الترجمة بين لقطة وأخرى.
- **الخصوصية**: التحليل مقتصر حصراً على السمات البصرية المطلوبة لتنسيق الترجمة، ولا يُستخدم لبناء أي ملف تعريفي عن الأشخاص.

---

## 7. Media Player (MX Player Killer)

- **طبقة تجريد التشغيل (Playback Abstraction)** تفصل واجهة المستخدم عن محرك التشغيل العتادي (Media3 ExoPlayer على Android و AVFoundation على iOS).
- دعم كامل للحاويات: MKV, MP4, WebM, TS, AVI, MOV مع فك ترميز عتادي لـ HEVC, H.264, VP9, AV1, 10-bit HDR.
- التبديل الفوري لمسارات الصوت والترجمات المدمجة والخارجية.
- **نظام الإيماءات**:
  - سحب رأسي على الثلث الأيسر: السطوع.
  - سحب رأسي على الثلث الأيمن: مستوى الصوت.
  - سحب أفقي: تقديم وتأخير مع شاشة مصغرة للتوقيت.
  - نقر مزدوج يمين/يسار: قفزة $\pm 10$ ثوانٍ.
  - ضغط مطول: تسريع $2.0\times$ فوري.
  - القرص بإصبعين: ملاءمة وتكبير (Fit, Fill, 16:9, 21:9).
- دعم صورة داخل صورة (PiP) والتشغيل في الخلفية كـ Media Session نظامية.

---

## 8. UX/UI & Design System

- **فلسفة التصميم**: المحتوى أولاً، عدم وضع أزرار مشتتة فوق الفيديو، واجهة تختفي بعد 3 ثوانٍ.
- **رموز التصميم الثابتة**: نظام مسافات إيقاعي (4pt / 8pt Grid)، هوية لونية مزدوجة (Dark Obsidian و Light Porcelain)، ولون نيلي بنفسجي كهربائي رصين (`#6366F1`).
- **طباعة ثنائية اللغة**: خط Inter للاتيني، وخط Readex Pro للعربي مع دعم كامل لاتجاه RTL والتشكيل.
- **الشاشات الرئيسية**:
  1. Onboarding & Permissions Explanation.
  2. Home / Continue Watching.
  3. Local Media Library.
  4. Fullscreen Immersive Player.
  5. Subtitle Studio & Timeline Inspector.
  6. Sync Wizard (Offset / Drift / Audio).
  7. Translation Studio & Project Glossary.
  8. AI Style Studio & Make Beautiful.
  9. Settings, Privacy & Subscriptions.

---

## 9. Privacy, Security & Trust

- **Local-First Default**: الفيديوهات والملفات لا تُرفع إلى السحابة تلقائياً.
- **المعالجة السحابية صريحة واختيارية**: بيان واضح لما سيُرسل ولماذا ومدة الاحتفاظ به قبل أي عملية.
- **أمن التخزين**: Android Keystore و iOS Keychain لتخزين الجلسات والرموز؛ لا مفاتيح API داخل التطبيق إطلاقاً.
- **روابط مشفرة مؤقتة (Presigned URLs)** مع حذف تلقائي للبيانات المؤقتة بعد انتهاء المهمة (خلال 15 دقيقة إلى 24 ساعة كحد أقصى).
- **التحقق السحابي الصارم من الاشتراكات** لمنع التلاعب.
- **متطلبات المتاجر لعام 2026**:
  - Google Play: استهداف `targetSdkVersion = 36` (Android 16)، إفصاح دقيق عن Data Safety، ومنع طلب `MANAGE_EXTERNAL_STORAGE` والاعتماد على Photo Picker و File Picker النظامي.
  - Apple: استخدام StoreKit 2 مع إثباتات JWS الرقمية وإفصاح كامل في Privacy Nutrition Labels.

---

## 10. Technical Architecture

- **التطبيق**: Flutter للواجهة الموحدة مع قنوات Native سريعة لمحركات الوسائط (`Media3` على Android و `AVFoundation` على iOS).
- **نواة الترجمة المشتركة (subtitle_core)**: حزمة مستقلة نقية بلغة Dart لمعالجة النصوص والتوقيتات دون اعتمادية على الواجهة.
- **الخادم الخلفي**: Modular Monolith مبني بـ **FastAPI**، مع قاعدة بيانات **PostgreSQL 16+**، طابور مهام **Redis Streams + Celery**، وتخزين سحابي **S3-compatible**.
- **بوابة الـ AI**: معمارية حيادية (Provider-Agnostic) تتيح التبديل بين النماذج المحلية والسحابية بسلاسة.

---

## 11. Data Model & APIs

### الكيانات الأساسية (Entities):
- `User`, `Device`, `MediaItem`, `SubtitleProject`, `SubtitleVersion`, `SubtitleCue`, `StyleProfile`, `TranslationJob`, `AIAnalysis`, `Entitlement`, `UsageLedger`, `Consent`.

### قواعد الـ API:
- ترويسة `Idempotency-Key` لعمليات إنشاء المهام والمدفوعات لمنع التكرار.
- ترقيم الصفحات القائم على المؤشر (Cursor Pagination).
- نموذج موحد للأخطاء (RFC 7807) بدون تسريب أي Stack traces.
- حدود لمعدل الاستخدام (Rate Limiting) على التوثيق والترجمة والرفع.

---

## 12. Monetization & Subscriptions

| الخطة | المزايا والحدود | التسعير المقترح |
|---|---|---|
| **Free ($0)** | مشغل كامل خالي من الإعلانات، تشغيل جميع الصيغ، استوديو تعديل الترجمة، المزامنة اليدوية، فحص الصحة، 50 نقطة AI للتجربة. | مجاني للأبد |
| **Plus** | مزامنة تلقائية بالصوت، تلوين الشخصيات، ترجمة سياقية (500 نقطة شهرية)، قوالب حفظ الأنماط. | $1.99 شهرياً / $14.99 سنوياً |
| **Pro** | توليد الترجمة من الصوت، ترجمة نصوص الشاشة بالفيديو (OCR)، معالجة جماعية، طابور ذو أولوية (2,500 نقطة شهرية). | $4.99 شهرياً / $39.99 سنوياً |

---

## 13. Performance & Cost Controls

- عدم تحميل الفيديو بالكامل في الذاكرة العشوائية (RAM)؛ الاعتماد على التدفق اللحظي.
- استخدام عينات إطارات (Sampled Frames) في التحليل البصري وتخزين النتائج مؤقتاً (Cache).
- قائمة أسطر افتراضية (Virtualised Cue List) في محرر الترجمة لدعم ملفات تضم 10,000+ سطر دون بطء.
- حدود واضحة للتكلفة والاستهلاك لكل مستخدم لمنع الخسائر المالية.

---

## 14. Testing & QA

- **Unit Tests**: لاختبارات توقيتات الأسطر، المحللات (SRT, VTT, ASS)، والتحقق من صحة المسرد.
- **Golden Files Tests**: اختبار استيراد وتصدير ملفات ترجمة حقيقية والتأكد من عدم ضياع أي وسم أو حرف.
- **Property Tests**: التأكد رياضيّاً من استحالة إنتاج سطر ينتهي قبل أن يبدأ.
- **مكتبة الفحص الشاملة (Fixture Library)**: نماذج حقيقية لأنمي، تمثيل واقعي، نصوص عربية RTL، يابانية، إنجليزية، ملفات تالفة التوقيت، وتداخلات.

---

## 15. Release / Google Play / App Store Readiness

- استهداف `targetSdk = 36` لنظام Android 16.
- تكامل Google Play Billing 9.1+ مع إشعارات RTDN.
- تكامل StoreKit 2 والاشتراكات المتجددة تلقائياً.
- شاشات وتصاميم واضحة للمتجر باللغتين العربية والإنجليزية.
- إطلاق تدريجي (Staged Rollout) مع متابعة معدلات الأعطال (Crash-Free Rate $> 99.5\%$).

---

## 16. Development Roadmap

```
المرحلة 0: التأسيس والتصميم وفحص الجدوى
   │
المرحلة 1: مشغل الوسائط الأساسي والمكتبة المحلية
   │
المرحلة 2: استوديو الترجمة الموحد وأدوات الإصلاح
   │
المرحلة 3: محرك المزامنة متعدد الطبقات (Smart Sync)
   │
المرحلة 4: محرك الترجمة السياقية ومسرد المصطلحات
   │
المرحلة 5: التلوين البصري للشخصيات وحارس القراءة
   │
المرحلة 6: الحسابات والاشتراكات والفوترة
   │
المرحلة 7: الأمان والأداء ومراقبة الجودة
   │
المرحلة 8: مراجعة سياسات المتاجر والإطلاق الإنتاجي
```

---

## 17. Master Build Prompt

انسخ النص التالي كاملاً ومرره لأي أداة بناء برمجي أو مهندس ذكاء اصطناعي لتنفيذ النظام بدقة متناهية:

```text
================================================================================
VELA MASTER SYSTEM SPECIFICATION & IMPLEMENTATION PROMPT
================================================================================

ROLE
You are the Principal Mobile Architect, Senior Media Engineer, Subtitle Systems Engineer, AI/ML Engineer, Security Engineer, Product Designer, QA Lead, DevOps Engineer, and App Store/Google Play release engineer.

MISSION
Build a production-grade Android + iOS application called Vela that combines a premium offline-first media player with a professional Subtitle Intelligence Studio. The application must be maintainable, testable, secure, accessible, multilingual, RTL/LTR ready, and suitable for real Google Play and App Store distribution.

NON-NEGOTIABLE ENGINEERING RULES
- Do not create mock screens pretending to be functional.
- Every primary button must have real behavior or a clearly documented unavailable state.
- Never destructively overwrite the user's original media or subtitle files.
- Use versioned subtitle projects with undo/redo.
- Playback must work offline wherever platform constraints permit.
- AI features must have deterministic fallback behavior and confidence/status.
- Cloud processing must be explicit and opt-in for private media.
- Never put API keys or store secrets in the client.
- Use provider-agnostic interfaces for AI providers.
- Do not silently change user content. Always show proposed transformations before commit when risk is meaningful.
- Respect store billing, copyright, privacy, and platform policies.

PRODUCT MODULES
1. Media Player
2. Local Media Library
3. Subtitle Import/Export
4. Subtitle Studio
5. Smart Sync
6. Translation Studio
7. AI Visual Styling
8. Style Presets
9. Accessibility
10. Accounts
11. Billing/Entitlements
12. Usage/Quotas
13. Privacy & AI Controls
14. Settings
15. Diagnostics/Help

PLAYER REQUIREMENTS
Support common video/audio formats subject to platform/decoder/licensing constraints. Implement seek, speed, resume, tracks, subtitles, gestures, lock controls, chapters, playlists, favorites, history, picture-in-picture where supported, and robust error states. Keep a player abstraction so the UI is not coupled to one decoder implementation.

SUBTITLE FORMATS
Implement adapters for SRT, WebVTT, ASS/SSA at minimum. Architect for additional formats. Normalize all subtitles to an internal Cue model. Preserve styling metadata where the target format supports it.

SUBTITLE MODEL
Cue: id, startMs, endMs, text, speakerId, styleId, confidence, metadata.
SubtitleProject: id, mediaId, language, sourceFormat, currentVersionId, glossaryId.
StyleProfile: id, font, size, weight, color, outline, shadow, background, position, margins, readability constraints.

SUBTITLE QUALITY ENGINE
Detect and repair: overlapping cues, invalid timestamps, negative durations, huge gaps, duplicate cues, reading-speed problems, excessive line length, poor line breaks, punctuation/whitespace inconsistencies, malformed style tags, and suspicious encoding.
Use rule-based deterministic checks first. Then optionally propose AI-assisted fixes. Provide before/after preview and an explanation for each class of repair.

SMART SYNC ENGINE
Implement a layered strategy:
A. Global offset detection.
B. Drift correction using multiple anchors.
C. Speech/audio alignment when transcription/alignment is available.
D. Scene/anchor alignment for local corrections.
E. Confidence scoring + human review.
Never silently overwrite. Provide Apply, Undo, Revert, and Version History.

TRANSLATION ENGINE
Implement source language detection, manual override, target language selection, context-aware segmentation, glossary/term memory, proper-name preservation, consistency pass, subtitle length/readability validation, review queue, retries, and export.
Provide Local/Cloud processing mode where technically feasible. Before cloud processing, display what data is sent, why it is needed, and retention behavior.

AI VISUAL STYLING
Implement an optional analysis pipeline that can:
- Detect scenes/shots.
- Sample representative frames.
- Detect and track recurring visual characters when feasible.
- Extract candidate colors from visible hair, eyes, clothing, or scene palette.
- Convert candidate colors into readable subtitle styles using contrast rules.
- Create speaker/character Style Profiles.
- Show confidence.
- Allow user override.
- Fall back to speaker colors or neutral styles when uncertain.
Do not infer sensitive traits. This feature is only for subtitle styling and visual consistency.

READABILITY GUARD
No AI-selected color may be rendered directly without contrast/readability checks. Add outline, shadow, background, opacity correction, or alternate nearby hue as needed. Include presets for dark scenes, bright scenes, high contrast, and color-vision accessibility.

UX/UI
Create a premium, minimal design inspired by modern Apple/Stripe/Linear usability principles without copying proprietary assets. Prioritize content, whitespace, hierarchy, typography, fast transitions, dark/light themes, RTL/LTR, Arabic and English localization, dynamic text scaling, reduced motion, accessible controls, and clear empty/error/loading states.

PRIMARY SCREENS
Onboarding, Home, Local Library, Player, Media Details, Subtitle Projects, Subtitle Studio, Sync Wizard, Translation Studio, Style Studio, AI Review, Downloads/Cache, Favorites/History, Settings, Privacy & AI, Account, Subscription, Help.

PRIVACY
Build local-first. Do not upload videos/audio/subtitles automatically. Use secure storage for tokens. Use short-lived access tokens and rotating refresh tokens. Use TLS. Add upload size/duration controls. Use signed URLs with short TTL when temporary cloud storage is required. Add automatic deletion policies. Support account deletion and data export. Analytics must not contain raw subtitle text or media content. Document all third-party SDK data collection.

SECURITY
Threat model the mobile app and backend. Validate file type and content. Protect against path traversal, malicious subtitle parsers, ZIP/file bombs if archives are supported, replayed webhooks, token theft, privilege escalation, and rate abuse. Add SAST, dependency scanning, secret scanning, and parser fuzzing.

BACKEND
Use modular APIs, PostgreSQL, Redis/queue workers, object storage only where needed, structured logs, metrics, and job idempotency. The AI gateway must support multiple providers. Make translation and vision providers swappable.

BILLING
Implement Free / Plus / Pro using Google Play Billing on Android and StoreKit 2 on iOS. Use a common entitlement service. Validate purchase/renewal server-side where applicable. Support restore, cancellation, grace period, retry states, plan changes, and cross-device entitlement. Never trust a client boolean such as isPremium.

QUOTAS
Meter expensive operations by feature and period. Example dimensions: translated minutes, AI-analysis minutes, batch jobs, maximum project duration, maximum cloud file size. Give the user transparent quota information. Do not offer unlimited AI until real cost telemetry proves it is viable.

OBSERVABILITY
Track crash rate, ANR, startup time, player error rate, subtitle parser failure, AI latency, job completion, cloud cost, and purchase errors. Do not log private subtitle/media content.

TESTING
Create unit tests, parser golden tests, property tests, integration tests, UI tests, performance tests, security tests, and store-flow tests. Maintain fixtures for Arabic/English/Japanese/Korean/Spanish/French, anime and live-action content, timing drift, overlap, malformed subtitles, and ASS styling.

PERFORMANCE
Avoid loading entire videos or huge cue arrays into memory. Virtualize lists. Stream media. Cache derived analysis. Debounce expensive operations. Use background workers/isolate/native queues where appropriate.

STORE READINESS
Prepare Android target API 36+ for current Google Play submission requirements. Complete Data Safety, privacy policy, content rating, permissions review, app signing, subscriptions, screenshots, store descriptions, and staged rollout configuration. Prepare equivalent App Store Connect metadata, privacy details, subscription group, and StoreKit configuration.

DELIVERY PROCESS
Work in the following order and keep every stage buildable:
1. Architecture + repository tree.
2. Domain models + interfaces.
3. Design system + navigation.
4. Offline player + local library.
5. Subtitle core + import/export.
6. Subtitle Studio + validation.
7. Smart Sync.
8. Translation.
9. AI Visual Styling.
10. Account + billing + quotas.
11. Security + privacy.
12. Observability + performance.
13. Automated tests.
14. Store release preparation.
At each stage: run tests, fix regressions, produce a working build, and document what changed.

DEFINITION OF REAL IMPLEMENTATION
Do not leave critical functionality as TODO. If a provider cannot be configured yet, implement a clean adapter interface plus a deterministic local/mock provider used only for development/tests, clearly separated from production.

FIRST OUTPUT
Before writing the main code, produce:
- Architecture decision record.
- Repository tree.
- Feature matrix with Free/Plus/Pro.
- Privacy threat model.
- Subtitle internal schema.
- API contracts.
- Design token set.
- Development milestones.
Then begin Phase 1.
================================================================================
```

---

## 18. Definition of Done (DoD)

- [x] عدم وجود أي مسار معروف يؤدي لفقدان البيانات أو تعطل حرج (Crash).
- [x] ملفات الوسائط والترجمة الأصلية الخاصة بالمستخدم لا تُمس أبداً (Immutable Originals).
- [x] كل عملية مدفوعة تفحص حالة الاستحقاق والحصة المتبقية (Entitlement & Quota).
- [x] المعالجة السحابية مشروطة بموافقة صريحة مع بيان مدة الاحتفاظ بالبيانات.
- [x] نجاح اختبارات Golden Files لاستيراد وتصدير SRT, VTT, ASS.
- [x] المزامنة تنتج نسخاً جديدة قابلة للتراجع الكامل (Reversible Versioning).
- [x] خط أنابيب الترجمة يدعم مسرد المصطلحات والمراجعة البشرية.
- [x] التلوين الذكي يحتوي على نسبة ثقة وحارس قراءة يضمن التباين العالي (Readability Guard).
- [x] دعم كامل وفحص بصري للغتين العربية (RTL) والإنجليزية (LTR).
- [x] مطابقة اشتراطات Google Play (`targetSdk = 36`) و Apple App Store (`Xcode 26` و `StoreKit 2`).
- [x] تطابق سياسة الخصوصية ونموذج Data Safety مع السلوك الفعلي للكود والـ SDKs.
- [x] جاهزية المراقبة التشغيلية وخطة التراجع (Rollback).

### مراجع السياسات المعتمدة (سبتمبر 2026):
- [Google Play Target SDK Requirements](https://support.google.com/googleplay/android-developer/answer/11926878)
- [Google Play Data Safety Disclosures](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Google Play Subscriptions Policy](https://support.google.com/googleplay/android-developer/answer/9900533)
- [Apple StoreKit 2 Documentation](https://developer.apple.com/storekit/)
- [Apple Auto-Renewable Subscriptions](https://developer.apple.com/app-store/subscriptions/)
- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
