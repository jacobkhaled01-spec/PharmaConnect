# 🎯 العرض الفني الشامل لمشروع فارما-كونكت
## (PharmaConnect: Technical Architecture & Client-Server Code Deck)
**نظام خادم وعميل موزع لتتبع وفرة الأدوية وإدارة المخزون متعدد الصيدليات بالحجز المتزامن**  
*معمارية 3-Tier Distributed Systems — 2026*

---

## فهرس شرائح العرض الفني (14 شريحة متكاملة مع الأكواد المشروحة)

| الشريحة | المحور والمحتوى | تصنيف الشريحة | المدة المقترحة |
| :---: | :--- | :---: | :---: |
| **01** | [واجهة المشروع وبطاقة الهوية الهندسية](#slide-01) | بطاقة تعريفية | دقيقة واحدة |
| **02** | [المشكلة الواقعية والحلول المعمارية المطبقة](#slide-02) | تحليل المتطلبات | دقيقة واحدة |
| **03** | [المعمارية الموزعة ثلاثية الطبقات (3-Tier Architecture)](#slide-03) | معمارية النظم | دقيقة ونصف |
| **04** | [هندسة البيانات والشكل المعياري الثالث (3NF Database)](#slide-04) | قواعد البيانات | دقيقة ونصف |
| **05** | [كود التخاطب والمصادقة بالتوكنات (REST Auth & Bearer Tokens)](#slide-05) | **كود عملي مشروح (1/5)** | دقيقة ونصف |
| **06** | [كود الحجز الذري وقفل التزامن (Atomic Concurrency Locking)](#slide-06) | **كود عملي مشروح (2/5)** | دقيقة ونصف |
| **07** | [كود الاستعلام الجغرافي الكروي (Spherical GeoSearch & Haversine)](#slide-07) | **كود عملي مشروح (3/5)** | دقيقة واحدة |
| **08** | [كود المزامنة اللحظية الحية (Real-Time State Polling & Live Feed)](#slide-08) | **كود عملي مشروح (4/5)** | دقيقة واحدة |
| **09** | [كود بوابة الربط المحاسبي (B2B Partner ERP Integration API)](#slide-09) | **كود عملي مشروح (5/5)** | دقيقة واحدة |
| **10** | [تطبيق الهاتف وتجربة المريض (Flutter & Clean Architecture)](#slide-10) | عميل الهاتف | دقيقة واحدة |
| **11** | [بوابة الويب للصيدليات والتكامل المحاسبي (Portal & B2B)](#slide-11) | بوابة الخادم | دقيقة واحدة |
| **12** | [ضمان الجودة وأتمتة العمليات (QA, Looping Engineering & CI/CD)](#slide-12) | الجودة والعمليات | دقيقة واحدة |
| **13** | [سيناريو العرض التشغيلي المباشر للأنظمة (Live System Demo)](#slide-13) | محاكاة تشغيلية | دقيقتان |
| **14** | [الخاتمة والأسئلة التقنية الشائعة (Technical FAQ)](#slide-14) | خلاصة فنية | دقيقة واحدة |

---

<a name="slide-01"></a>
## الشريحة 1: بطاقة المشروع وهوية النظام الموزع

### 🖥️ محتوى الشريحة (Visual Content)
- **اسم المنظومة:** فارما-كونكت (PharmaConnect System)
- **النمط المعماري:** نظام خادم وعميل موزع ثلاثي الطبقات (3-Tier Distributed Client-Server System).
- **التقنيات الأساسية:**
  - **الخادم المركزي:** PHP 8.2+ / Laravel 11 (Stateless RESTful APIs + Sanctum Bearer Authentication).
  - **عميل الهاتف:** Flutter 3.x / Dart 3 (Cross-Platform Mobile Client وفق معمارية Clean Architecture).
  - **قواعد البيانات:** Relational Database بتطابق تام مع الشكل المعياري الثالث (3NF) ودعم معاملات ACID.
  - **بوابة الصيدليات:** Responsive Web Portal مبنية بمحرك Blade ونظام تصميم طبي موحد.
  - **نظام الخرائط:** OpenStreetMap و CartoDB Slippy Tiles لحساب المسارات الكروية مجاناً.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "بسم الله الرحمن الرحيم، والصلاة والسلام على رسول الله. مرحباً بكم في العرض التقني المباشر لنظام فارما-كونكت (PharmaConnect). يمثل هذا النظام منصة موزعة متقدمة لتتبع وفرة الأدوية الحيوية وإدارة المخزون متعدد الصيدليات بالحجز المتزامن، حيث يجسد تطبيقاً عملياً صارماً لمعمارية 3-Tier Distributed Systems من خلال دمج خادم مركزي متين وخفيف بإطار عمل Laravel 11، وعميل هاتف لحظي للمرضى بإطار عمل Flutter 3، مع بوابة ويب متكاملة لإدارة المخزون والربط المحاسبي B2B."

---

<a name="slide-02"></a>
## الشريحة 2: المشكلة الواقعية والدوافع الهندسية

### 🖥️ محتوى الشريحة (Visual Content)
- **أزمة البحث اليدوي العشوائي:** هدر ما بين 45 إلى 120 دقيقة للبحث عن دواء طارئ في شوارع المدينة.
- **تشتت بيانات المخزون:** الصيدليات تعمل كـ "جزر معزولة" بأنظمة محاسبية متباينة ومغلقة دون ربط مركزي.
- **مشكلة الاتصال الكاذب:** تأكيد توفر الدواء هاتفياً ثم بيعه لعميل آخر قبل وصول المريض الفعلي.
- **حلول PharmaConnect الهندسية:**
  1. استعلام جغرافي كروي فوري يحدد الصيدليات المتوفر لديها الدواء مع المسافة بالأمتار.
  2. حجز مؤقت عادل (30 دقيقة TTL) يضمن حماية حق المريض بالوصول وحق الصيدلي في تصريف الدواء دون تعطيله.
  3. حماية المخزون من الحجز المزدوج بنسبة خطأ 0% عبر القفل التشاؤمي الحصري على مستوى الصف.
  4. مرونة عالية تضمن استمرار عمل عميل الهاتف حتى في حال تذبذب أو ضعف الإنترنت.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "المشكلة الواقعية التي يعالجها النظام هي الهدر الزمني والمادي الكبير في البحث اليدوي العشوائي عن الأدوية الحيوية، والذي يستنزف ما بين 45 إلى 120 دقيقة، إلى جانب عزلة الأنظمة الصيدلانية وظاهرة تأكيد التوفر هاتفياً ثم بيع الدواء لعميل آخر قبل وصول المريض. يقدم PharmaConnect استعلاماً فورياً ذكياً مبنياً على الإحداثيات الجغرافية والمسافة الكروية الحقيقية، مع نظام حجز مؤقت عادل (30 دقيقة TTL) وقفل تشاؤمي صارم للمخزون يمنع البيع المزدوج بنسبة خطأ 0%."

---

<a name="slide-03"></a>
## الشريحة 3: المعمارية الموزعة ثلاثية الطبقات (3-Tier Architecture)

### 🖥️ محتوى الشريحة (Visual Content)
- **1. Presentation Tier (طبقة العرض والعميل):**
  - تطبيق الهاتف الذكي (Flutter Client): واجهة للمرضى للبحث وحجز الدواء.
  - بوابة إدارة الصيدليات (Web Portal Blade): واجهة لإدارة المخزون والتسعير ومتابعة الحجوزات.
  - نقاط البيع وبرامج الكاشير (B2B Partner Systems): تكامل برمجي مباشر.
  - نمط التخاطب: Stateless RESTful JSON عبر بروتوكول HTTPS.
- **2. Logic Tier (طبقة المنطق والخادم المركزي):**
  - Laravel 11 RESTful API Gateway: فحص وتوجيه الطلبات.
  - الأمان بـ Sanctum: توكنات Bearer مشفرة بدون Sessions.
  - محركات الخدمات: `GeoSearchService`, `ReservationService`, `AuthService`.
  - نمط `Repository Pattern`: عزل استعلامات البيانات عن منطق الأعمال.
- **3. Data Tier (طبقة البيانات والتخزين):**
  - قاعدة بيانات علائقية موثوقة مصممة بالشكل المعياري الثالث (3NF).
  - دعم كامل للمعاملات الذرية (ACID Transactions) عبر `DB::transaction`.
  - قفل الصفوف التشاؤمي عبر محرك `InnoDB Row-Level Locking`.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 90 ثانية)
> "في المعمارية العامة للنظام، اعتمدنا نموذج 3-Tier Distributed Architecture بالكامل. يتواصل عميل الهاتف وبوابة الويب حصراً عبر طلبات Stateless RESTful API خفيفة وآمنة بصيغة JSON. وتتولى الطبقة الوسطى (Logic Tier) في خادم Laravel معالجة كافة قواعد الأعمال: التوثيق والتشفير عبر توكنات Sanctum، حساب المسافات الجغرافية، تطبيق المعاملات الذرية ACID، والاتصال بطبقة البيانات المنفصلة (Data Tier)، مما يضمن قابلية التوسع الأفقي والأمان العالي."

---

<a name="slide-04"></a>
## الشريحة 4: هندسة البيانات والشكل المعياري الثالث (3NF Database)

### 🖥️ محتوى الشريحة (Visual Content)
- **الجداول الـ 7 الرئيسية في المنظومة:**
  1. `users`: إدارة حسابات المرضى ومدراء الصيدليات والمشرفين (RBAC).
  2. `pharmacies`: بيانات الصيدليات، الهواتف، والإحداثيات الجغرافية (`latitude`, `longitude`).
  3. `medicines`: الفهرس القومي الموحد للأدوية (الاسم العلمي، التجاري، الشكل الدوائي، العيار).
  4. `pharmacy_medicines`: وسيط الربط؛ إدارة المخزون الفعلي والسعر الخاص بكل صيدلية.
  5. `reservations`: تذاكر الحجز والمهلة الزمنية TTL وكود الاستلام الفريد.
  6. `reservation_items`: تفاصيل الأصناف والكميات وأسعار الوحدة لحظة الحجز.
  7. `personal_access_tokens`: إدارة توكنات الوصول المشفرة لحزمة Laravel Sanctum.
- **المزايا الهندسية:**
  - انعدام التكرار (Zero Redundancy): تسجيل مواصفات الدواء مرة واحدة عالمياً.
  - استقلالية التسعير والمخزون لكل صيدلية.
  - دورة حياة خماسية للحجز: `pending` ➔ `confirmed` ➔ `completed` / `cancelled` / `expired`.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 90 ثانية)
> "في هندسة قاعدة البيانات، تم تطبيق أعلى معايير الـ Normalization بالشكل المعياري الثالث (3NF). قمنا بفصل الكتالوج الموحد للأدوية في جدول medicines، وجعلنا جدول pharmacy_medicines هو نقطة الربط التي تدير المخزون والسعر الفعلي لكل صيدلية باستقلالية تامة، مع دورة حياة محكمة للحجز تبدأ من pending وتمر بـ confirmed وصولاً لـ completed أو expired، مما يضمن التماسك المرجعي وانعدام التكرار."

---

<a name="slide-05"></a>
## الشريحة 5: كود التخاطب والمصادقة بالتوكنات (REST Auth & Bearer Tokens)

### 🖥️ محتوى الشريحة (Visual Content)

#### عميل الهاتف (Flutter / Dart) — `api_service.dart`:
```dart
// frontend/lib/core/network/api_service.dart
// 1. تجهيز ترويسات الطلب بنمط RESTful وحقن التوكن المشفر
Map<String, String> get _headers => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  if (_authToken != null)
    'Authorization': 'Bearer $_authToken', // توكن مصادقة العميل
};

// 2. دالة تسجيل الدخول وإرسال بيانات الاعتماد للخادم المركزي
Future<AuthResult> login(String email, String pwd) async {
  final uri = Uri.parse('$baseUrl/auth/login');
  final res = await http.post(
    uri,
    headers: _headers,
    body: json.encode({'email': email, 'password': pwd}), // تشفير كائن JSON
  ).timeout(const Duration(seconds: 5)); // مهلة أمان لحماية التطبيق من بطء الشبكة

  if (res.statusCode == 200) {
    final body = json.decode(utf8.decode(res.bodyBytes));
    _authToken = body['data']['token']; // حفظ التوكن محلياً للطلبات اللاحقة
    _currentUser = UserModel.fromJson(body['data']['user']);
    notifyListeners(); // إشعار واجهات التطبيق بتحديث حالة المستخدم فورياً
    return AuthResult(success: true, user: _currentUser);
  }
}
```

#### الخادم المركزي (Laravel / PHP) — `routes/api.php` & `AuthController.php`:
```php
// backend/routes/api.php
// 1. مسارات الـ API المحمية بواسطة وسيط Laravel Sanctum
Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']); // مسار عام للدخول
    Route::middleware('auth:sanctum')->group(function () { // مسارات مؤمنة بـ Bearer Token
        Route::get('/auth/profile', [AuthController::class, 'profile']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
    });
});

// backend/app/Http/Controllers/Api/V1/AuthController.php
// 2. التحقق الصارم من صحة المدخلات وإصدار توكن Bearer عديم الحالة
public function login(Request $request): JsonResponse {
    $data = $request->validate([
        'email' => 'required|email', 'password' => 'required|string'
    ]);
    $user = User::where('email', $data['email'])->first(); // البحث عن الحساب بالبريد
    if (!$user || !Hash::check($data['password'], $user->password)) { // مطابقة تجزئة كلمة المرور
        return response()->json(['message' => 'بيانات الدخول غير صحيحة'], 422);
    }
    // إصدار توكن Bearer مشفر خاص بجلسة تطبيق الهاتف
    $token = $user->createToken('mobile_app')->plainTextToken;
    return response()->json(['data' => ['token' => $token, 'user' => $user]]); // رد JSON للعميل
}
```

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 90 ثانية)
> "نستعرض هنا كود التخاطب والمصادقة بالتوكنات بين العميل والخادم. على اليمين نشاهد كود عميل Flutter في ملف api_service.dart الذي يقوم ببناء ترويسة الطلب ويحقن التوكن المشفر Bearer Token في ترويسة Authorization بصيغة JSON. وعلى اليسار نشاهد مسار الخادم المحمي في routes/api.php عبر وسيط auth:sanctum، حيث يستقبل AuthController الطلب ويتحقق من التوكن ويرجع بيانات المستخدم بصيغة JSON عديمة الحالة (Stateless)."

---

<a name="slide-06"></a>
## الشريحة 6: كود الحجز الذري وقفل التزامن (Atomic Concurrency Locking)

### 🖥️ محتوى الشريحة (Visual Content)

#### عميل الهاتف (Flutter / Dart) — `api_service.dart`:
```dart
// frontend/lib/core/network/api_service.dart
// إرسال طلب حجز دواء مؤقت مع تحديد مهلة الصلاحية الزمنية TTL
Future<ReservationModel> createReservation({
  required int stockId,
  int quantity = 1,
  int ttlMinutes = 30, // مهلة الحجز الافتراضية 30 دقيقة
}) async {
  final uri = Uri.parse('$baseUrl/reservations');
  final res = await http.post(
    uri,
    headers: _headers,
    body: json.encode({
      'pharmacy_medicine_id': stockId, // معرف الصنف بصيدلية محددة
      'quantity': quantity,             // الكمية المطلوبة
      'ttl_minutes': ttlMinutes,        // مهلة حجز الدواء
    }),
  ).timeout(const Duration(seconds: 15));

  if (res.statusCode == 200 || res.statusCode == 201) {
    final body = json.decode(res.body);
    final created = ReservationModel.fromJson(body['data']); // إنشاء كائن التذكرة
    _cachedReservations.insert(0, created); // تخزين التذكرة محلياً
    notifyListeners(); // إشعار شاشة التذكرة لبدء مؤقت العد التنازلي الحي
    return created;
  }
  throw Exception('تعذر إتمام الحجز');
}
```

#### الخادم المركزي (Laravel / PHP) — `ReservationService.php`:
```php
// backend/app/Services/ReservationService.php
public function createReservation(int $userId, int $stockId, int $qty): Reservation {
  // تنفيذ الحجز داخل معاملة ذرية متكاملة (ACID Transaction)
  return DB::transaction(function () use ($userId, $stockId, $qty) {
    // 1. قفل تشاؤمي على مستوى الصف يمنع تنافس مريضين على نفس العلبة (Race Condition)
    $stock = PharmacyMedicine::where('id', $stockId)
      ->lockForUpdate() // قفل حصري في InnoDB يمنع أي قراءة أو تعديل متزامن
      ->firstOrFail();

    // 2. التحقق الذري من توفر الرصيد الفعلي قبل الخصم
    if ($stock->available_quantity < $qty) {
      throw new Exception('عذراً، الكمية غير متوفرة حالياً');
    }

    // 3. الخصم الآمن للكمية وتحديث حالة الصنف تلقائياً
    $stock->decrement('available_quantity', $qty);
    if ($stock->available_quantity === 0) {
      $stock->update(['status' => 'out_of_stock']);
    }

    // 4. إنشاء سجل الحجز برمز فريد ومؤقت صلاحية 30 دقيقة
    return Reservation::create([
      'user_id' => $userId, 'pharmacy_id' => $stock->pharmacy_id,
      'reservation_code' => 'RES-'.strtoupper(Str::random(6)), // كود استلام الصيدلية
      'status' => 'pending',                                   // الحالة: قيد الانتظار
      'expires_at' => now()->addMinutes(30),                   // مهلة الـ TTL
    ]);
  });
}
```

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 90 ثانية)
> "هنا يظهر الحل البرمجي لأخطر معضلة في الأنظمة الموزعة وهي تنافس الحجز أو الـ Race Condition. في عميل الهاتف على اليمين يرسل المريض طلب الحجز بمهلة 30 دقيقة. وفي الخادم على اليسار داخل ملف ReservationService.php تُنفذ العملية بالكامل داخل معاملة ذرية DB::transaction مع استدعاء lockForUpdate() لقفل صف الدواء حصرياً على مستوى محرك InnoDB. هذا يضمن أنه لو طلب مريضان آخر علبة في نفس الجزء من الثانية، يحصل الأول عليها فوراً ويُرفض طلب الثاني بأمان تام دون أي بيع مزدوج."

---

<a name="slide-07"></a>
## الشريحة 7: كود الاستعلام الجغرافي الكروي (Spherical GeoSearch & Haversine)

### 🖥️ محتوى الشريحة (Visual Content)

#### عميل الهاتف (Flutter / Dart) — `api_service.dart`:
```dart
// frontend/lib/core/network/api_service.dart
// تمرير إحداثيات GPS الحالية ونصف قطر البحث في الـ Query String
Future<List<MedicineSearchItem>> searchMedicines({
  String? query, double? latitude, double? longitude, double radiusKm = 20.0,
}) async {
  final queryParams = <String, String>{
    if (query != null) 'q': query,                     // اسم الدواء المطلوب
    if (latitude != null) 'lat': latitude.toString(),  // خط العرض لموقع المريض
    if (longitude != null) 'lng': longitude.toString(),// خط الطول لموقع المريض
    'radius': radiusKm.toString(),                     // نصف القطر الأقصى (كم)
  };

  final uri = Uri.parse('$baseUrl/medicines/search')
      .replace(queryParameters: queryParams);

  final res = await http.get(uri, headers: _headers); // إرسال طلب GET خفيف
  final body = json.decode(utf8.decode(res.bodyBytes));
  // تحويل استجابة الـ JSON لقائمة صيدليات مرتبة تصاعدياً بالأمتار
  return (body['data'] as List)
      .map((item) => MedicineSearchItem.fromJson(item))
      .toList();
}
```

#### الخادم المركزي (Laravel / PHP) — `EloquentMedicineRepository.php`:
```php
// backend/app/Repositories/Eloquent/EloquentMedicineRepository.php
// تطبيق خوارزمية هافرسين الرياضية لحساب المسافة الكروية الحقيقية
private function calculateHaversineDistance(float $lat1, float $lon1, float $lat2, float $lon2): float {
    $earthRadiusKm = 6371.0; // نصف قطر كوكب الأرض بالكيلومتر
    $dLat = deg2rad($lat2 - $lat1); // تحويل فرق درجات العرض إلى راديان
    $dLon = deg2rad($lon2 - $lon1); // تحويل فرق درجات الطول إلى راديان
    // معادلة هافرسين المثلثية الكروية
    $a = sin($dLat / 2) * sin($dLat / 2) +
         cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
         sin($dLon / 2) * sin($dLon / 2);
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    return $earthRadiusKm * $c; // الناتج: المسافة الواقعية المستقيمة (كم)
}

// تصفية الصيدليات ضمن النطاق وفرز النتائج من الأقرب إلى الأبعد للمريض
return $collection->filter(function ($item) use ($radiusKm) {
    return $item->distance_km <= $radiusKm; // استبعاد الصيدليات البعيدة
})->sortBy('distance_km')->values();         // فرز تصاعدي حسب المسافة
```

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "نستعرض هنا كود الاستعلام الجغرافي الكروي. يقوم عميل Flutter في ملف api_service.dart بإرسال إحداثيات GPS الحالية (خط الطول ودوائر العرض) ونصف قطر البحث. ويتولى خادم Laravel في EloquentMedicineRepository.php تطبيق خوارزمية هافرسين الكروية الرياضية مع نصف قطر الأرض 6371 كم لحساب البعد الدقيق لكل صيدلية، وتصفية الصيدليات التي تقع خارج النطاق وترتيب الأقرب للمريض لحظياً دون أي حاجة لاستخدام خدمات خارجية مدفوعة."

---

<a name="slide-08"></a>
## الشريحة 8: كود المزامنة اللحظية الحية (Real-Time State Polling & Live Feed)

### 🖥️ محتوى الشريحة (Visual Content)

#### عميل الهاتف (Flutter / Dart) — `reservation_pass_screen.dart`:
```dart
// frontend/lib/presentation/screens/reservation_pass_screen.dart
// استطلاع دوري لحالة الحجز بالخلفية لاقتناص تأكيد الصيدلي فوراً
void _startStatusPolling() {
  _pollTimer = Timer.periodic(const Duration(seconds: 2), (t) async {
    // 1. استعلام الخادم عن الحالة الحالية للتذكرة بواسطة كود الحجز
    final fresh = await ApiService()
        .getReservationDetails(_reservation.reservationCode);

    if (fresh != null && mounted) {
      // 2. التحقق مما إذا تم تأكيد تسليم الدواء بالويب وتحويل الحالة لـ completed
      final becameCompleted = (_reservation.status != 'completed') 
          && (fresh.status == 'completed');
      setState(() {
        _reservation = fresh; // تحديث بيانات التذكرة في واجهة المريض
        _remainingSeconds = fresh.currentRemainingSeconds;
      });

      if (becameCompleted) {
        t.cancel(); // إيقاف الاستطلاع لتوفير موارد الجهاز والشبكة
        HapticFeedback.heavyImpact(); // اهتزاز تفاعلي لتنبيه المريض
        _showSuccessBadge(); // إظهار شارة الاستلام الخضراء بنجاح
      }
    }
  });
}
```

#### بوابة الويب (Blade / JavaScript) — `reservations.blade.php`:
```javascript
// backend/resources/views/pharmacy/reservations.blade.php
// فحص دوري كل 5 ثوانٍ لتحديث جدول الحجوزات دون إعادة تحميل الصفحة
async function fetchLatestReservations() {
    try {
        // 1. جلب شريحة الـ HTML المحدثة للحجوزات الواردة من السيرفر
        const res = await fetch('/pharmacy/reservations/live-feed');
        if (res.ok) {
            const htmlText = await res.text();
            const parser = new DOMParser();
            const doc = parser.parseFromString(htmlText, 'text/html');
            const newWrap = doc.getElementById('reservations-table-wrapper');
            const currWrap = document.getElementById('reservations-table-wrapper');
            
            // 2. تحديث DOM فقط في حال وجود حجز جديد أو تغيير حالة حجز قائم
            if (newWrap && currWrap && currWrap.innerHTML !== newWrap.innerHTML) {
                currWrap.innerHTML = newWrap.innerHTML; // تحديث فوري وسلس للجدول
            }
        }
    } catch (err) {
        console.warn('Auto-sync check failed:', err); // معالجة صامتة لانقطاع الشبكة
    }
}
setInterval(fetchLatestReservations, 5000); // تكرار الفحص دورياً كل 5 ثوانٍ
```

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "هنا يظهر كود المزامنة اللحظية الحية بين الأطراف. في عميل الهاتف على اليمين، يعمل مؤقت استطلاع دوري Timer.periodic كل ثانيتين للاستعلام عن حالة التذكرة في الخلفية؛ وفور تأكيد الصيدلي بالويب، تلتقط التذكرة التحول إلى completed وتوقف المؤقت وتظهر شارة الاستلام الخضراء. وعلى اليسار في بوابة الويب نرى كود الجافاسكريبت setInterval الذي يستعلم مسار live-feed كل 5 ثوانٍ ليحدّث جدول الحجوزات الواردة آلياً دون الحاجة لإعادة تحميل الصفحة."

---

<a name="slide-09"></a>
## الشريحة 9: كود بوابة الربط المحاسبي (B2B Partner ERP Integration API)

### 🖥️ محتوى الشريحة (Visual Content)

#### حمولة JSON من نظام الكاشير (POS / ERP):
```json
// HTTP POST /api/v1/partner/inventory/sync
// Headers: X-Pharmacy-Id: 1 | Content-Type: application/json
// حمولة مزامنة المخزون والأسعار الواردة من برنامج محاسبة الصيدلية (يمن سوفت / الإبداع)
{
  "items": [
    {
      "barcode": "6291100123456", // باركود الصنف الدوائي الموحد
      "quantity": 25,              // الكمية الجديدة المتوفرة على رف الصيدلية
      "price": 1200.00             // السعر الفعلي المعتمد بالريال
    },
    {
      "barcode": "6291100987654",
      "quantity": 10,
      "price": 3500.00
    }
  ]
}

// استجابة الخادم الفورية بنجاح المزامنة وتحديث الرصيد السحابي:
{
  "success": true,
  "message": "تمت مزامنة المخزون مع برنامج المحاسبة بنجاح",
  "updated_count": 2
}
```

#### الخادم المركزي (Laravel / PHP) — `PartnerIntegrationApiController.php`:
```php
// backend/app/Http/Controllers/Api/V1/PartnerIntegrationApiController.php
// دالة معالجة المزامنة الدورية للمخزون من أنظمة الـ ERP ونقاط البيع (POS)
public function syncInventory(Request $request): JsonResponse {
    $pharmacy = $this->resolvePharmacy($request); // استخراج هوية الصيدلية المصادقة
    // التحقق الصارم من صحة مصفوفة الأصناف وأسعارها وكمياتها
    $validated = $request->validate([
        'items' => 'required|array|min:1',
        'items.*.barcode' => 'nullable|string',
        'items.*.quantity' => 'required|integer|min:0',
        'items.*.price' => 'required|numeric|min:0',
    ]);

    // معالجة كل صنف وتحديث كميته وسعره بالسجلات السحابية
    foreach ($validated['items'] as $itemData) {
        $medicine = Medicine::where('barcode', $itemData['barcode'])->first();
        if ($medicine) {
            PharmacyMedicine::updateOrCreate(
                ['pharmacy_id' => $pharmacy->id, 'medicine_id' => $medicine->id], // شرط المطابقة
                ['available_quantity' => $itemData['quantity'], 'price' => $itemData['price']] // القيم المحدثة
            );
        }
    }
    return response()->json(['success' => true, 'message' => 'تمت المزامنة بنجاح']); // رد فوري
}
```

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "لربط الأنظمة الصيدلانية القائمة في السوق، صممنا بوابة الربط المحاسبي B2B Partner API. نشاهد على اليمين نموذج حمولة الـ JSON التي يرسلها برنامج الكاشير والمحاسبة (مثل يمن سوفت أو الإبداع) عبر مسار sync متضمنة الباركود والكمية والسعر. وعلى اليسار كود PartnerIntegrationApiController الذي يقوم بالبحث عن الصيدلية عبر الترويسة واستخدام updateOrCreate لمزامنة آلاف الأصناف لحظياً وربطها بالمخزون السحابي بطلب واحد."

---

<a name="slide-10"></a>
## الشريحة 10: تطبيق الهاتف المحمول وتجربة المريض (Flutter & Clean Architecture)

### 🖥️ محتوى الشريحة (Visual Content)
- **معمارية Clean Architecture:**
  - طبقة `core`: إدارة الشبكة `ApiService`، الموقع `LocationService`، والثيمات.
  - طبقة `data`: نماذج البيانات المحكمة `ReservationModel` والتحويل الآمن.
  - طبقة `presentation`: الشاشات والويدجتس مع مؤقتات حية.
  - خريطة المسار الذكية: مربعات CartoDB / OSM المجانية.
- **تذكرة الحجز والمزامنة اللحظية:**
  - مؤقت عد تنازلي حي (30 دقيقة).
  - كود الحجز و QR Code للاستلام بماسح الباركود.
  - المزامنة التلقائية والتحول لشارة الاستلام الخضراء.
  - مرونة الشبكة (Offline Resilience) عند انقطاع الإنترنت.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "في عميل الهاتف المحمول، اعتمدنا إطار عمل Flutter وفق معمارية Clean Architecture لضمان فصل طبقات core و data و presentation وسهولة الصيانة. يتميز التطبيق بنظام تصميم طبي زمردي مريح، وخريطة تفاعلية ذكية، وتذكرة حجز رقمية متطورة بمؤقت عد تنازلي حي يبدأ من 30 دقيقة، مع كود استلام سريع و QR Code، بالإضافة لمزامنة خلفية تلتقط لحظياً تأكيد الصيدلي لاستلام الدواء وتتحول فوراً لشارة النجاح الخضراء."

---

<a name="slide-11"></a>
## الشريحة 11: بوابة الصيدلية والربط المحاسبي (Pharmacy Portal & B2B)

### 🖥️ محتوى الشريحة (Visual Content)
- **بوابة الويب للصيدليات (Web Portal):**
  - لوحة تحكم خفيفة وسريعة تفتح من أي جهاز أو متصفح.
  - إدارة المخزون وتعديل الأسعار وتنبيهات الرصيد الحرج.
  - شاشة الحجوزات الواردة مع تحديث تلقائي كل 5 ثوانٍ.
  - تأكيد التسليم والمحاسبة بضغطة زر واحدة.
- **بوابة الربط المحاسبي (B2B Partner API):**
  - مسارات `POST /api/v1/partner/inventory/sync` لمزامنة آلاف الأصناف.
  - مسار `POST /api/v1/partner/inventory/update-item` لتعديل رصيد الصنف فور بيعه محلياً.
  - مسار `POST /api/v1/partner/reservations/{id}/fulfill` لصرف الحجز بماسح الباركود.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "لإدارة الصيدليات وربط بيئات الأعمال، يوفر النظام قناتين: الأولى بوابة ويب متجاوبة وخفيفة يستعرض من خلالها الصيدلي الحجوزات الواردة لحظياً مع ميزة التحديث التلقائي الدوري كل 5 ثوانٍ، وتأكيد تسليم الدواء بضغطة زر. والقناة الثانية هي بوابة الربط المحاسبي (B2B Partner API) التي تتيح للبرامج المحاسبية ونقاط البيع (POS) مزامنة المخزون وتحديث الكميات وصرف الحجوزات عبر ماسح الباركود بشكل آلي بالكامل."

---

<a name="slide-12"></a>
## الشريحة 12: ضمان الجودة وهندسة البرمجيات (QA & CI/CD Pipelines)

### 🖥️ محتوى الشريحة (Visual Content)
- **منهجية الحلقات المغلقة (Looping Engineering):**
  - دورة تطوير صارمة: تخطيط ➔ تنفيذ معياري ➔ اختبار آلي ➔ تدقيق ➔ توثيق فوري.
  - كود PHP خاضع لأداة `Laravel Pint` بنسبة توافق 100%.
  - كود Dart خاضع لـ `Flutter Analyze` بصفر أخطاء وصفر تحذيرات.
  - توثيق علمي شامل وفق معايير APA 7th Edition.
- **خطوط أنابيب GitHub Actions المؤتمتة:**
  - 12 اختباراً تكاملياً ووظيفياً (Feature Tests) تغطي قفل التزامن، والبحث الجغرافي، وعزل الجلسات.
  - اختبارات Flutter التلقائية للواجهات والبيانات.
  - حماية فرع `main` ومنع دمج أي كود لا يجتاز الاختبارات.
  - جاهزية النشر السحابي التلقائي على منصة Render.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "لضمان جودة وموثوقية النظام، اتبعنا منهجية الحلقات المغلقة (Looping Engineering) مع خطوط أنابيب CI/CD تلقائية على GitHub Actions. يخضع كود الخادم لفحص التنسيق بـ Laravel Pint، ويخضع تطبيق Flutter لـ Flutter Analyze بصفر أخطاء وصفر تحذيرات، مع تنفيذ حزمة اختبارات تكاملية ووظيفية بنسبة نجاح 100% تغطي قفل التزامن، والبحث الجغرافي، وعزل الجلسات، قبل النشر السحابي الآلي للإنتاج."

---

<a name="slide-13"></a>
## الشريحة 13: سيناريو العرض التشغيلي المباشر (End-to-End Live Demo)

### 🖥️ محتوى الشريحة (Visual Content)

| الخطوة | البيئة والمنصة | الإجراء المنفذ في النظام (Action) | النتيجة الهندسية والتقنية |
| :---: | :--- | :--- | :--- |
| **1** | بوابة الويب (المتصفح) | الصيدلي يسجل دخوله ويعدل مخزون **Norvasc** إلى 10 وسعره 3800 ريال. | حفظ فوري بقاعدة البيانات مع رسالة نجاح. |
| **2** | تطبيق الهاتف (Flutter) | المريض يبحث عن دواء "Norvasc" في التطبيق. | ظهور صيدلية الأمل بالسعر الجديد والمسافة بالأمتار. |
| **3** | تطبيق الهاتف | المريض يحدد حجز عبوة واحدة ويؤكد الحجز فورياً. | إصدار تذكرة بمؤقت 30 دقيقة وكود حجز فريد. |
| **4** | بوابة الويب | مراقبة شاشة الحجوزات الواردة بالويب. | ظهور الحجز آلياً وخصم المخزون من 10 إلى 9 علب. |
| **5** | بوابة الويب | الصيدلي يضغط زر "تم التسليم والمحاسبة". | تحديث حالة الحجز فوراً إلى completed. |
| **6** | تطبيق الهاتف | تذكرة المريض المفتوحة تلتقط التأكيد بالخلفية آلياً. | توقف المؤقت وظهور شارة النجاح الخضراء فوراً. |

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 120 ثانية)
> "ننتقل الآن إلى سيناريو العرض التشغيلي المباشر للأنظمة المتزامنة. نشاهد على اليمين بوابة الصيدلية وعلى اليسار تطبيق هاتف العميل يعملان في بيئة سحابية حية: يعدل الصيدلي سعر وكمية دواء Norvasc فتظهر فوراً على هاتف المريض. يقوم المريض بتأكيد الحجز فتصدر تذكرته الرقمية ويبدأ مؤقت الـ 30 دقيقة وينخفض المخزون فورياً في شاشة الصيدلي. وأخيراً يضغط الصيدلي 'تم التسليم والمحاسبة'، فتتحول شاشة تذكرة المريض تلقائياً ولحظياً إلى شارة الاستلام الخضراء المكتملة."

---

<a name="slide-14"></a>
## الشريحة 14: الخاتمة وأهم المعايير والأسئلة التقنية الشائعة (Technical FAQ)

### 🖥️ محتوى الشريحة (Visual Content)
- **أهم المنجزات والتطلعات المستقبلية:**
  - منظومة متكاملة 3-Tier جاهزة للتشغيل التجاري والربط الطبي.
  - استقلالية تامة واعتماد على تقنيات مجانية 100% للخرائط والبيانات.
  - آفاق التطوير: دمج الدفع بالمحافظ الرقمية، وإدارة أساطيل التوصيل، والتنبؤ بنفاد الأدوية بالذكاء الاصطناعي.
- **أهم الأسئلة التقنية الشائعة (Technical FAQ):**
  - **س: أين معالجة الـ Race Condition؟**  
    ج: بدالة `createReservation` عبر `lockForUpdate()` داخل `DB::transaction()`.
  - **س: أين خوارزمية المسافة الكروية؟**  
    ج: بدالة `calculateHaversineDistance()` بنصف قطر الأرض 6371 كم.
  - **س: كيف يعمل الأمان بدون Session بالموبايل؟**  
    ج: عبر `Bearer Token` مشفر من حزمة Laravel Sanctum.
  - **س: كيف يتكامل النظام مع برامج المحاسبة القائمة؟**  
    ج: عبر Partner B2B RESTful API لمزامنة المخزون وصرف الحجوزات آلياً.

---

### 🎙️ نص إلقاء الشريحة (Speaker Script — 60 ثانية)
> "في الختام، يقدم نظام PharmaConnect نموذجاً معمارياً وبرمجياً متكاملاً وجاهزاً للتشغيل والإنتاج الفعلي في خدمة القطاع الصحي وإدارة سلاسل الإمداد الدوائي مع توثيق شامل لأكواد العميل والخادم. شكراً لحسن استماعكم، ونحن جاهزون لمناقشة كافة التفاصيل المعمارية والبرمجية للنظام والإجابة على استفساراتكم."
