---
description: معايير وإرشادات دورة حياة تطوير هندسة البرمجيات (SDLC) لنظام فارما-كونكت
globs: ["**/*"]
alwaysApply: true
---

# قواعد دورة حياة هندسة البرمجيات (Software Engineering SDLC Standards)

تُلزم هذه القاعدة الوكيل البرمجي والفريق باتباع مراحل دورة حياة تطوير البرمجيات المعيارية (SDLC) بشكل منهجي وتسلسلي متين:

## 1. مرحلة التحليل وهندسة المتطلبات (Requirements Engineering)
- **المتطلبات الوظيفية (Functional Requirements):**
  - صياغة المتطلبات بنمط قصص المستخدم (User Stories):  
    *«كـ [نوع المستخدم: صيدلي / مريض / مشرف]، أريد [الوظيفة]، لكي أتمكن من [الفائدة والقيمة المضافة]».*
  - تحديد معايير القبول (Acceptance Criteria) لكل متطلب وظيفي.
- **المتطلبات غير الوظيفية (Non-Functional Requirements):**
  - **الأداء والزمن (Performance & Latency):** ألا يتجاوز زمن استجابة استعلام البحث الجغرافي 2 ثانية.
  - **الأمان (Security):** تشفير كلمات المرور (Bcrypt/Argon2)، وتأمين واجهات الـ API باستخدام Bearer Tokens (Sanctum/JWT).
  - **التزامن (Concurrency & Consistency):** منع حجز نفس العبوة الدوائية لأكثر من مريض في نفس اللحظة عبر آليات الأقفال والمعاملات (Database Transactions & Pessimistic/Optimistic Locking).
  - **قابلية التوسع (Scalability):** دعم إضافة مئات الصيدليات دون تأثر بنية الجداول.
- **وثيقة متطلبات النظام (SRS):** إعداد وثيقة متطلبات برمجية متوافقة مع معايير IEEE 830.

---

## 2. مرحلة التحليل والتصميم المعماري (System Modeling & Architecture)
- **مخططات لغة النمذجة الموحدة (UML Diagrams):**
  - **Use Case Diagram:** نمذجة تفاعلات الصيدلي، المريض، ومدير النظام مع المنظومة.
  - **Class Diagram:** فئات الكائنات وتوزيع العلاقات (Inheritance, Aggregation, Composition, Interfaces).
  - **Sequence Diagram:** توضيح تسلسل تدفق البيانات بين واجهة العميل والخادم وقاعدة البيانات في العمليات الحرجة (مثل عملية البحث والحجز الفوري).
  - **Activity Diagram:** نمذجة مسار دورة حياة الدواء والحجز من الإنشاء إلى التسليم أو الإلغاء.
- **تصميم قاعدة البيانات (Database Architecture & ERD):**
  - إعداد مخطط الكيانات والعلاقات (Entity-Relationship Diagram) مع التأكيد على درجات التطبيع (3NF Normalization).
  - ضبط المفاتيح الأساسية (Primary Keys)، الخارجية (Foreign Keys)، والفهارس (Indexes) على حقول البحث المتكرر (مثل `medicine_name`, `pharmacy_id`).

---

## 3. مرحلة التنفيذ البرمجي (Implementation & Coding)
- فصل طبقات النظام (Layered Architecture):
  - **Controllers:** استقبال الطلبات، التحقق من المدخلات (Request Validation)، وإرجاع الاستجابات المهيكلة (JSON/Views).
  - **Services:** احتواء منطق الأعمال الكامل (Business Logic Layer) لمنع تضخم المتحكمات (Fat Models/Fat Controllers).
  - **Repositories:** الاستعلامات المباشرة مع قاعدة البيانات لتمكين سهولة الاستبدال والاختبار.
- كتابة أكواد معلقة وواضحة (Clean Code & PHPDoc / DartDoc).

---

## 4. مرحلة الاختبار وضمان الجودة (Quality Assurance & Testing)
- **اختبارات الوحدة (Unit Tests):** اختبار دوال الخدمات وحسابات المخزون والتخفيض ومؤقتات الحجز بشكل معزول.
- **اختبارات التكامل (Integration Tests):** التحقق من صحة ربط وحدات الـ API بقاعدة البيانات وتفاعل الخادم مع العميل.
- **اختبار الـ APIs عبر Postman:** توثيق المجموعات (Collections) وتجهيز بيئات الاختبار (Environments) لمسارات الويب والموبايل.

---

## 5. التوثيق الأكاديمي (Academic Documentation - APA 7th Edition)
- توثيق جميع التقارير والمراجع العلمية وأوراق البحث المعتمدة في المشروع بنظام **APA 7th Edition**.
