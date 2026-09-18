# ☁️ دليل النشر المجاني الكامل على منصة Render السحابية
## نشر خادم PharmaConnect (Laravel 11 + SQLite / MySQL) مجاناً 100% وبدون بطاقة ائتمان

> [!IMPORTANT]
> تم تجهيز المشروع بكافة ملفات التكوين الآلي (`render.yaml` و `backend/Dockerfile` و `backend/docker-entrypoint.sh`). بمجرد ربط حسابك في Render بمستودع GitHub، سيقوم Render ببناء وتشغيل الخادم المركزي تلقائياً وتوفير رابط HTTPS دائم ومجاني.

---

## 🚀 خطوات النشر السحابي المجاني في 3 دقائق

### الخطوة 1: إنشاء حساب مجاني على Render
1. ادخل إلى موقع: 👉 **[https://render.com](https://render.com)**
2. اضغط على **"Get Started for Free"** أو **"Sign In"**.
3. اختر **"Sign up with GitHub"** (وسجّل الدخول بحساب GitHub الخاص بك: `jacobkhaled01-spec`).
   *(لا يتطلب Render أي بطاقة ائتمان للحسابات المجانية).*

---

### الخطوة 2: ربط المستودع والنشر التلقائي (Blueprint Deploy)

هناك طريقتان، اختر الأسهل لك:

#### الطريقة الأولى (الأسهل - بنقرة واحدة عبر Blueprint):
1. في لوحة تحكم Render (Dashboard)، اضغط على زر **"New +"** في الأعلى.
2. اختر **"Blueprint"**.
3. ستظهر لك قائمة مستودعاتك في GitHub؛ اختر مستودع **`PharmaConnect`** (أو ابحث عن `jacobkhaled01-spec/PharmaConnect`).
4. سيتعرف Render تلقائياً على ملف `render.yaml` الموجود في المستودع.
5. اضغط على **"Apply"**؛ وسيبدأ Render في سحب الكود وبناء الحاوية فوراً!

#### الطريقة الثانية (النشر اليدوي عبر Web Service):
1. اضغط على **"New +"** -> واختر **"Web Service"**.
2. اختر مستودع **`PharmaConnect`**.
3. املأ الإعدادات التالية:
   - **Name:** `pharmaconnect-backend`
   - **Region:** `Frankfurt (EU Central)` *(أو الأقرب لك)*
   - **Branch:** `main`
   - **Root Directory:** `backend`
   - **Runtime:** `Docker`
   - **Instance Type:** `Free` (0.1 CPU, 512 MB RAM - مجاني تماماً)
4. اضغط على زر **"Create Web Service"** في أسفل الصفحة.

---

### الخطوة 3: استلام الرابط السحابي الحي (HTTPS Live URL)

1. سيقوم Render خلال دقيقتين ببناء الحاوية وتثبيت الحزم وتشغيل الـ Migrations والـ Seeders تلقائياً.
2. بمجرد ظهور كلمة **`Live`** باللون الأخضر في أعلى الصفحة، ستجد الرابط السحابي العام جاهزاً، ويكون عادةً بالشكل:
   ```text
   https://pharmaconnect-backend.onrender.com
   ```
3. يمكنك تجربة الـ API مباشرة في المتصفح بفتح:
   ```text
   https://pharmaconnect-backend.onrender.com/api/v1/medicines/search
   ```
   وستظهر لك نتائج البحث بصيغة JSON حقيقية!

---

### الخطوة 4: ربط تطبيق Flutter بالخادم السحابي الجديد

1. افتح ملف [`frontend/lib/core/constants/app_constants.dart`](file:///d:/IT%20FILES/level%204/خادم%20وعميل/مشروع%20الصيدلية/frontend/lib/core/constants/app_constants.dart).
2. قم بتعديل قيمة:
   ```dart
   static const bool useCloudBackend = true;
   static const String cloudBaseUrl = 'https://pharmaconnect-backend.onrender.com/api/v1'; // ضع رابطك هنا
   ```
3. الآن سيتصل تطبيق الهاتف (سواء عمل على الويندوز أو أندرويد أو الويب) بالخادم السحابي المباشر عبر الإنترنت من أي مكان في العالم!

---

## 🌐 نشر واجهة العميل (Flutter Web) مجاناً على GitHub Pages

إذا أردت أيضاً استضافة واجهة المريض (Flutter Web) كـ موقع مجاني يعمل على الإنترنت:
1. في مشروع Flutter:
   ```bash
   cd frontend
   flutter build web --release
   ```
2. يمكن نشر مجلد `frontend/build/web/` مجاناً بنقرة واحدة عبر **GitHub Pages** على الرابط:
   `https://jacobkhaled01-spec.github.io/PharmaConnect/`
