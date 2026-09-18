---
description: معايير إدارة النسخ والتحكم بالمستودع ومراحل مراجعة الكود والربط بـ GitHub لمشروع PharmaConnect
globs: ["**/*"]
alwaysApply: true
---

# معايير إدارة النسخ والتحكم بـ Git و GitHub (Git & GitHub Workflow)

تحدد هذه الوثيقة بروتوكول حفظ التعديلات وإدارة فروع العمل ومراحل مراجعة الأكواد والربط بالمستودع السحابي الرسمي.

## 1. بيانات المستودع المعتمد (Official Repository)
- **رابط المستودع الرسمي:**  
  👉 `https://github.com/jacobkhaled01-spec/PharmaConnect`
- **الفرع الأساسي:** `main`.

---

## 2. استراتيجية الفروع (Branching Model - Git Flow)
1. **فرع `main`:**  
   الفرع الرئيسي المستقر، ويُحمى بقواعد حماية الفروع (Branch Protection Rules) لمنع الرفع المباشر بدون مراجعة واجتياز الـ CI/CD.
2. **فرع `develop`:**  
   فرع التطوير النشط والتكامل.
3. **فروع الميزات (`feature/<feature-name>`):**  
   إنشاء فرع مستقل لكل ميزة جديدة (مثال: `feature/pharmacy-inventory-web`, `feature/patient-search-api`).

---

## 3. دورة مراجعة الكود الإلزامية (GitHub Code Review Lifecycle)
قبل دمج أي Pull Request إلى `develop` أو `main`، يجب استيفاء المراحل التالية بالترتيب:
1. **Generate (التوليد البرمجي):** كتابة الكود النظيف وتطبيق مبادئ OOP والـ Repository Pattern.
2. **Self-Review (المراجعة الذاتية):** فحص التعديلات محلياً وتحديث ملف `CHANGELOG.md`.
3. **Pint & Lint Testing (فحص التنسيق والجودة):**
   - تشغيل `./vendor/bin/pint --test` للـ Backend.
   - تشغيل `flutter analyze` للـ Frontend.
4. **Auto Testing (الاختبارات التلقائية):**
   - اجتياز اختبارات PHPUnit / Pest للـ Backend.
   - اجتياز اختبارات `flutter test` للـ Frontend.
5. **CI Pipeline Pass (اجتياز خط الأنابيب):** تحقق الإشارة الخضراء لـ GitHub Actions.
6. **Peer Review & Merge (اعتماد المطورين والدمج):** موافقة المراجعين عبر Pull Request Template.

---

## 4. معايير صياغة رسائل الـ Commits (Conventional Commits)
`<type>(<scope>): <subject>`

- `feat`: ميزة جديدة.
- `fix`: إصلاح خلل.
- `docs`: تحديث في ملفات التوثيق.
- `style`: تعديلات الواجهات والتنسيقات.
- `refactor`: إعادة هيكلة الكود.
- `test`: إضافة أو تعديل اختبارات.
- `ci`: تعديلات خطوط أنابيب GitHub Actions.
- `chore`: تحديثات ملفات التهيئة والمكتبات.
