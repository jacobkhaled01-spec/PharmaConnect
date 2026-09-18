---
description: قواعد ومعايير البرمجة كائنية التوجه (OOP) والمعمارية النظيفة وأنماط التصميم
globs: ["**/*"]
alwaysApply: true
---

# قواعد البرمجة كائنية التوجه والمعمارية النظيفة (OOP & Clean Architecture)

تحدد هذه الوثيقة المعايير الصارمة لتنظيم الأكواد، وتطبيق المفاهيم كائنية التوجه، وأنماط التصميم لضمان أعلى مستويات إعادة الاستخدام وسهولة الصيانة والتطوير.

## 1. مبادئ البرمجة كائنية التوجه الأساسية (Core OOP Pillars)
1. **التغليف (Encapsulation):**
   - حماية الخصائص الحساسة وجعل المتغيرات خاصة (Private/Protected) مع توفير دوال وصول (Getters/Setters) أو خصائص محسوبة.
   - إخفاء تعقيدات الاتصال بقاعدة البيانات أو واجهات الـ API الخارجية داخل أصناف متخصصة.
2. **التجريد (Abstraction):**
   - بناء الواجهات البرمجية (Interfaces / Abstract Classes) للعقود البرمجية المشتركة (مثل: `MedicineRepositoryInterface`, `NotificationServiceInterface`).
   - اعتماد الأصناف المستهلكة على الواجهات المجردة وليس على التنفيذ الحتمي المباشر.
3. **الوراثة (Inheritance) وإعادة الاستخدام:**
   - استخدام الوراثة في العلاقات الهرمية الحقيقية (Is-A Relationship) مثل الفئات الأساسية للمتحكمات والنماذج المشتركة (`BaseController`, `BaseModel`).
   - تفضيل التركيب على الوراثة (Composition over Inheritance) عند الرغبة في مشاركة السلوكيات عبر الـ Traits (في PHP) أو Mixins (في Dart).
4. **تعدد الأشكال (Polymorphism):**
   - دعم التبديل السلس بين آليات المعالجة المختلفة (مثل تعدد بوابات الإشعارات: SMS، Push Notification، و Email عبر واجهة موحدة `NotifierInterface`).

---

## 2. مبادئ SOLID الخمسة
- **S - Single Responsibility Principle (SRP):**
  - كل فئة (Class) لها سبب واحد فقط للتغيير ومسؤولية واحدة محددة بدقة.
- **O - Open/Closed Principle (OCP):**
  - الفئات والوحدات تكون مفتوحة للإضافة والتوسع، ولكنها مغلقة أمام التعديل الذي قد يكسر الوظائف القائمة.
- **L - Liskov Substitution Principle (LSP):**
  - يجب أن تكون الفئات المشتقة قادرة على استبدال الفئات الأساسية دون الإخلال بسلامة عمل البرنامج.
- **I - Interface Segregation Principle (ISP):**
  - تقسيم الواجهات الكبيرة المعقدة إلى واجهات أصغر وأكثر تخصصاً لكي لا يُجبر العميل على الاعتماد على دوال لا يحتاجها.
- **D - Dependency Inversion Principle (DIP):**
  - تعتمد الوحدات عالية المستوى على التجريدات (Interfaces)، وتُحقن التبعيات عبر حاوية حقن التبعيات (Dependency Injection Container).

---

## 3. أنماط التصميم المؤسسية المعتمدة (Design Patterns)
1. **نمط المستودع (Repository Pattern):**
   - عزل منطق استعلامات واسترجاع البيانات (Eloquent Queries) في طبقة مستودعات وسيطة:
     ```php
     interface MedicineRepositoryInterface {
         public function searchByNameAndLocation(string $name, float $lat, float $lng, float $radius);
         public function getPharmacyStock(int $pharmacyId);
     }
     ```
2. **نمط طبقة الخدمات (Service Layer Pattern):**
   - تغليف منطق المعاملات المعقدة (مثل حجز دواء، خصم المخزون، وإرسال تنبيه) داخل كلاس خدمة مخصص (`ReservationService`).
3. **نمط كائنات نقل البيانات (Data Transfer Objects - DTOs / Resources):**
   - توحيد بنية البيانات المتبادلة بين الخادم والعميل باستخدام Laravel API Resources لمنع تسريب بيانات الحقول الداخلية أو كشف بنية قاعدة البيانات.
4. **نمط المكونات القابلة لإعادة الاستخدام في Flutter:**
   - فصل شاشات العرض عن منطق الحالة (State Management: Bloc / Provider / Riverpod).
   - بناء مكتبة مكونات مصغرة قابلة لإعادة الاستخدام (Widgets Library: `CustomPharmacyCard`, `AppButton`, `StockBadge`).

---

## 4. ضمان قابلية الصيانة والتوسع (Maintainability & Extensibility)
- **مبدأ DRY (Don't Repeat Yourself):** تجنب كتابة نفس المنطق مرتين نهائياً؛ بل نقله إلى Helper أو Service أو Widget مشترك.
- **الاقتران الضعيف والتماسك العالي (Low Coupling, High Cohesion):** تقليل اعتماد المكونات على تفاصيل المكونات الأخرى لتسهيل التعديل المستقبلي دون مفاجآت جانبية.
- **المعايير القياسية للتسميات والترميز (Coding Standards):**
  - اتباع مواصفات **PSR-12** لأكواد PHP / Laravel.
  - اتباع التوجيهات الرسمية لـ **Effective Dart** في Flutter.
