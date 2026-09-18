# سجل التغييرات (Project Change Log)

جميع التعديلات والخطوات البرمجية والتوثيقية لمشروع الصيدلية (خادم وعميل).

## [1.9.0] - 2026-09-18
### أضيف (Added)
- **إنجاز المرحلة الخامسة: تطوير عميل الهاتف المحمول (Phase 5 Mobile Client - Flutter):**
  - **نماذج البيانات وتحويل الـ JSON (Data Models):**
    - بناء `MedicineSearchItem`, `MedicineInfo`, `PharmacyInfo` لتمثيل وتفكيك نتائج البحث والوفرة الجغرافية.
    - بناء `ReservationModel`, `ReservationItemModel` لمعالجة بيانات تذكرة الحجز ومهلة الـ TTL.
  - **خدمة الشبكة والاتصال (Network & Resilience Layer):**
    - بناء `ApiService` الموحد للاتصال بـ RESTful API Gateway عبر حزمة `http: ^1.2.0`.
    - توفير آلية صمود وFallback محاكية متطابقة مع قاعدة بيانات صنعاء لضمان تشغيل وسلاسة التطبيق في أي بيئة اتصال.
  - **شاشات وتجربة المستخدم الطبية (Medical UI/UX Screens):**
    - تحديث `HomeScreen` بالبحث التفاعلي اللحظي، بطاقات الأدوية والصيدليات المتوفرة مع حساب المسافات وأسعار الدواء.
    - بناء شاشة `MedicineDetailsScreen` لعرض المواصفات الدوائية والجرعات، وتنبيهات الوصفة الطبية، ومحدد كمية الحجز الذكي.
    - بناء شاشة `ReservationPassScreen` لتذكرة الحجز اللحظية برمز الاستجابة السريع ومؤقت عد تنازلي حي للـ TTL (30 دقيقة) وتحديث فوري للحالة عند الانتهاء.
  - **الاختبارات التلقائية وفحص الجودة:**
    - إضافة اختبارات الوحدة `models_and_flow_test.dart` لاختبار الـ JSON Deserialization وتصفية البحث.
    - اجتياز فحص **Flutter Analyze** بنسبة 100% (No issues found).
    - اجتياز اختبارات **Flutter Test** بالكامل (4/4 tests passed).

## [1.8.0] - 2026-09-18
### أضيف (Added)
- **إنجاز المرحلة الرابعة: تطوير الخادم وبوابة المخزون والـ APIs (Phase 4 Backend & Web Portal):**
  - **طبقة المستودعات والخدمات (Repository & Service Pattern):**
    - بناء واجهة `MedicineRepositoryInterface` وتطبيقها `EloquentMedicineRepository` متضمناً حساب المسافات الجغرافية الدقيقة بصيغة **Haversine Formula**.
    - بناء واجهة `ReservationRepositoryInterface` وتطبيقها `EloquentReservationRepository` لمعالجة استعادة المخزون بعد انتهاء مهلة الـ TTL.
    - بناء خدمة البحث الجغرافي `GeoSearchService` لدعم الفلترة المكانية والترتيب حسب المسافة أو السعر.
    - بناء خدمة الحجوزات `ReservationService` لدعم المعاملات الذرية وحماية التزامن وأقفال الصفوف (Pessimistic Locking `lockForUpdate`) وتوليد أكواد الحجز `RES-XXXXXX` واحتساب مهلة الـ 30 دقيقة.
    - ربط المستودعات بالحاوية في `AppServiceProvider`.
  - **واجهات برمجة التطبيقات (Centralized RESTful APIs - v1):**
    - بناء `MedicineSearchResource` و `ReservationResource` لتوحيد بنية الاستجابات JSON.
    - تطوير متحكمات الـ API: `AuthController`, `MedicineSearchController`, `ReservationApiController`.
    - تفعيل 9 مسارات RESTful للبحث والحجز وإدارة التوكنات بـ Laravel Sanctum.
  - **بوابة الويب لإدارة مخزون الصيدليات (Multi-Tenant Web Portal):**
    - تطوير متحكم إدارة المخزون `PharmacyInventoryController` ومتحكم الجلسات `WebAuthController`.
    - بناء الواجهات الطبية بـ Blade بالأخضر الزمردي والأبيض الصافي:
      - `layouts/pharmacy.blade.php`: القالب الرئيسي المتجاوب.
      - `pharmacy/inventory.blade.php`: جدول المخزون وإحصائيات الأصناف والتعديل الفوري للكميات والأسعار.
      - `pharmacy/reservations.blade.php`: شاشة طلبات الحجز الواردة ومؤقتات العد التنازلي وتأكيد الاستلام.
      - `auth/login.blade.php`: شاشة تسجيل دخول الصيدلية.
  - **الاختبارات التلقائية وضمان الجودة:**
    - كتابة اختبارات الميزات: `GeoSearchApiTest` و `ReservationConcurrencyTest` لاختبار أقفال التزامن ومنع الحجز المزدوج.
    - اجتياز اختبارات **PHPUnit** كاملة بنسبة 100% (5 passed, 17 assertions).
    - اجتياز فحص **Laravel Pint** بنسبة 100% بدون أي أخطاء تنسيقية.

## [1.7.0] - 2026-09-18
### أضيف (Added)
- إنجاز المرحلة الثالثة: إعداد وتهيئة بيئات العمل البرمجية (Laravel 11, Flutter 3.41, 7 Migrations, 7 Eloquent Models, Database Seeder).

## [1.6.0] - 2026-09-18
### أضيف (Added)
- إنجاز المرحلة الثانية: وثيقة التصميم المعماري والنمذجة وقواعد البيانات `docs/ARCHITECTURE_AND_DESIGN.md`.

## [1.5.0] - 2026-09-18
### أضيف (Added)
- إنجاز المرحلة الأولى: وثيقة مواصفات متطلبات النظام الرسمية `docs/SRS.md`.

## [1.4.0] - 2026-09-18
### أضيف (Added)
- خريطة طريق وخطوات العمل التنفيذية التفصيلية `docs/ROADMAP.md`.

## [1.3.0] - 2026-09-18
### أضيف (Added)
- منظومة CI/CD واختبارات الجودة ومراجعة الكود وهيكلة المجلدات.

## [1.2.0] - 2026-09-18
### أضيف (Added)
- دستور المشروع الأصلي لمحرك Gemini: `GEMINI.md`.

## [1.1.0] - 2026-09-18
### معدل (Changed)
- اعتماد معمارية تعدد الصيدليات (Multi-Pharmacy / Multi-Tenant System).

## [1.0.0] - 2026-09-18
### أضيف (Added)
- صياغة وثيقة مقترح المشروع المعتمد `مقترح_المشروع_المعتمد.md`.
