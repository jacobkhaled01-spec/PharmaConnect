---
description: معايير إدارة النسخ والتحكم بالمستودع والربط بـ GitHub لمشروع PharmaConnect
globs: ["**/*"]
alwaysApply: true
---

# معايير إدارة النسخ والتحكم بـ Git و GitHub (Git & GitHub Workflow)

تحدد هذه الوثيقة بروتوكول حفظ التعديلات وإدارة فروع العمل والربط بالمستودع السحابي الرسمي.

## 1. بيانات المستودع المعتمد (Official Repository)
- **رابط المستودع الرسمي:**  
  👉 `https://github.com/jacobkhaled01-spec/PharmaConnect`
- **البروتوكول:** HTTPS / SSH.
- **الفرع الأساسي:** `main`.

---

## 2. استراتيجية الفروع (Branching Model - Git Flow)
1. **فرع `main`:**  
   الفرع الرئيسي الذي يحتوي على النسخة المستقرة المعتمدة فقط، ولا يتم الرفع عليه مباشرة إلا بعد اكتمال مرحلة مستقرة ومختبرة.
2. **فرع `develop`:**  
   فرع التطوير اليومي ودمج الميزات قبل إطلاق الإصدار.
3. **فروع الميزات (`feature/<feature-name>`):**  
   إنشاء فرع مستقل لكل مهمة أو وحدة جديدة (مثال: `feature/pharmacy-inventory-web`, `feature/patient-search-api`, `feature/reservation-logic`).
4. **فروع الإصلاحات العاجلة (`hotfix/<issue-name>`):**  
   لإصلاح المشاكل الحرجة التي تظهر في الفرع الرئيسي.

---

## 3. معايير صياغة رسائل الـ Commits (Conventional Commits)
تُكتب رسائل الـ Commit بصيغة دقيقة وواضحة وفق النمط التالي:
`<type>(<scope>): <subject>`

### الأنواع المعتمدة (Types):
- `feat`: إضافة وظيفة أو ميزة برمجية جديدة (مثال: `feat(inventory): add batch medicine stock update API`).
- `fix`: إصلاح خطأ برمجي (Bug) (مثال: `fix(auth): resolve JWT expiration token mismatch`).
- `docs`: إضافة أو تحديث في ملفات التوثيق والـ Markdown (مثال: `docs: update project proposal and SRS`).
- `style`: تعديلات على تصميم وتنسيق الواجهات والألوان دون المساس بمنطق الكود (مثال: `style(theme): apply medical green color palette`).
- `refactor`: إعادة هيكلة الكود لتطبيق مبادئ OOP النظيفة دون تغيير في السلوك الخارجي.
- `test`: إضافة أو تعديل اختبارات الوحدة والتكامل (مثال: `test(reservation): add concurrency hold test`).
- `chore`: تحديثات التهيئة والمكتبات وملفات البيئة (مثال: `chore: update gitignore and composer dependencies`).

---

## 4. سياسة الحفظ والتأمين
- عدم إضافة ملفات الإعدادات الحساسة (`.env`, `credentials.json`, `keys`) إلى المستودع نهائياً.
- فحص حالة التعديلات بـ `git status` والتأكد من نقاء شجرة التعديلات قبل أي Push.
