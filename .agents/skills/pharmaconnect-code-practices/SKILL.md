---
name: pharmaconnect-code-practices
description: >-
  معايير وإرشادات كتابة الأكواد النظيفة (Clean Code Practices)، وقواعد التنسيق،
  وأنماط إعادة الهيكلة (Refactoring)، وتجنب الـ Code Smells في مشروعي Laravel و Flutter.
---

# مهارة الممارسات البرمجية الفضلى (Coding Best Practices & Standards)

توفر هذه المهارة مرجعاً عملياً لكتابة أكواد نظيفة، قابلة للقراءة، وسهلة الصيانة في مشروعي Laravel و Flutter.

## 1. قواعد التسميات القياسية (Naming Conventions)
- **في Laravel (PHP):**
  - **Controllers:** مفرد بصيغة باسكال متبوع بـ Controller (مثل: `MedicineController`, `ReservationController`).
  - **Models:** مفرد بصيغة باسكال (مثل: `Medicine`, `Pharmacy`, `StockReservation`).
  - **Tables:** جمع بصيغة snake_case (مثل: `medicines`, `pharmacies`, `stock_reservations`).
  - **Methods:** بصيغة camelCase تبدأ بفعل واضح (مثل: `findAvailableMedicines()`, `cancelExpiredReservations()`).
  - **Routes:** بصيغة الجمع مع الفواصل (مثل: `api/v1/medicines/search`, `api/v1/pharmacies/{id}/stock`).
- **في Flutter (Dart):**
  - **Classes & Widgets:** بصيغة PascalCase (مثل: `PharmacyCard`, `MedicineSearchScreen`).
  - **Variables & Functions:** بصيغة camelCase (مثل: `selectedPharmacy`, `fetchNearbyStock()`).
  - **Files:** بصيغة lowercase_with_underscores (مثل: `medicine_card.dart`, `reservation_provider.dart`).

---

## 2. معايير الكود النظيف وتجنب روائح الكود (Clean Code & Code Smells)
1. **تجنب الدوال الطويلة (Avoid Long Methods):**
   - ألا تتجاوز الدالة الواحدة 25-30 سطراً؛ إذا كانت أطول، يتم تجزئتها إلى دوال أصغر ذات مسؤولية محددة.
2. **تجنب تضخم المتحكمات (Fat Controllers Smell):**
   - المتحكم يستقبل الطلب، يطلب من الخدمة (Service) المعالجة، ويعيد الاستجابة؛ ولا يكتب فيه أي منطق معقد لقواعد البيانات.
3. **تجنب الأرقام والنصوص السحرية (Avoid Magic Numbers & Strings):**
   - تعريف الحالات كثوابت أو Enums:
     ```php
     enum ReservationStatus: string {
         case PENDING = 'pending';
         case CONFIRMED = 'confirmed';
         case EXPIRED = 'expired';
     }
     ```
4. **التحقق من صحة المدخلات (Form Requests Validation):**
   - استخدام فئات مخصصة لـ FormRequest في Laravel بدلاً من `$request->validate()` داخل المتحكمات.

---

## 3. إرشادات إعادة الهيكلة (Refactoring Best Practices)
- **استخراج الفئات والخدمات (Extract Class/Service):** عند ملاحظة تكرار استعلامات الحجز في أكثر من مكان، تُستخرج إلى `ReservationService`.
- **التخلص من تكرار الاستعلامات (Solve N+1 Query Problem):**
  - استخدام التحميل المسبق للعلاقات (Eager Loading):
    ```php
    // ممارسة صحيحة:
    $pharmacies = Pharmacy::with(['medicines', 'location'])->get();
    ```
