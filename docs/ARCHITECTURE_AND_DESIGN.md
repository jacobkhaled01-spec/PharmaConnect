# وثيقة التصميم المعماري والنمذجة وقواعد البيانات (System Architecture & Design Document)
**مشروع:** فارما-كونكت (PharmaConnect)  
**المقرر:** خادم وعميل (Client-Server Architecture) - المستوى الرابع  
**المعيار:** متوافق مع معايير هندسة البرمجيات ونمذجة UML وتوثيق APA 7th Edition  
**التاريخ:** 2026-09-18  
**النسخة:** 1.0 (معتمدة للمرحلة الثانية)  

---

## 1. المعمارية العامة للنظام (High-Level System Architecture)

يعتمد نظام **PharmaConnect** معمارية الخادم والعميل متعددة الطبقات (Multi-Layered Client-Server Architecture) مع دعم العزل المنطقي للصيدليات (Multi-Tenant Logical Isolation):

```mermaid
graph TD
    subgraph "Clients Layer (طبقة العملاء)"
        MC["تطبيق الهاتف الذكي - المريض (Flutter Mobile Client)"]
        WC["بوابة الويب - إدارة مخزون الصيدليات (Laravel Blade/Vue)"]
        AC["بوابة الإدارة المركزية (Admin Dashboard)"]
    end

    subgraph "API Gateway & Security (بوابة الاتصال والأمان)"
        Sanctum["Laravel Sanctum (Token Auth)"]
        Session["Web Session Auth (CSRF Protected)"]
        RateLimit["Rate Limiting & Throttle"]
    end

    subgraph "Application & Service Layer (طبقة الخدمات ومنطق الأعمال)"
        SearchSvc["GeoSearchService (خوارزمية البحث المكاني Haversine)"]
        InvSvc["InventoryService (إدارة المخزون والتسعير)"]
        ResSvc["ReservationService (منطق الحجز وأقفال التزامن)"]
        JobExpiry["ReservationTTLJob (معالجة انتهاء مدة الحجز آلياً)"]
    end

    subgraph "Data Access Layer (طبقة المستودعات - Repository Pattern)"
        MedRepo["MedicineRepositoryInterface"]
        PharmRepo["PharmacyRepositoryInterface"]
        ResRepo["ReservationRepositoryInterface"]
    end

    subgraph "Persistence & Caching (قواعد البيانات والتخزين المؤقت)"
        MySQL[("MySQL 8.0 (قاعدة البيانات المركزية - ACID)")]
        Redis[("Redis (مؤقتات الـ TTL والـ Caching)")]
    end

    MC -->|"HTTPS / JSON"| Sanctum
    WC -->|"HTTPS / HTML"| Session
    AC -->|"HTTPS / HTML"| Session

    Sanctum --> RateLimit
    Session --> RateLimit

    RateLimit --> SearchSvc
    RateLimit --> InvSvc
    RateLimit --> ResSvc

    SearchSvc --> MedRepo
    InvSvc --> PharmRepo
    ResSvc --> ResRepo
    JobExpiry --> ResRepo

    MedRepo --> MySQL
    PharmRepo --> MySQL
    ResRepo --> MySQL
    ResSvc <--> Redis
    JobExpiry <--> Redis
```

---

## 2. تصميم قاعدة البيانات ونموذج الكيانات والعلاقات (Database Schema & ERD)

### 2.1 مخطط الكيانات والعلاقات (Entity-Relationship Diagram - ERD)

```mermaid
erDiagram
    USERS ||--o| PHARMACIES : "owns/manages"
    USERS ||--o{ RESERVATIONS : "places"
    CATEGORIES ||--o{ MEDICINES : "classifies"
    PHARMACIES ||--o{ PHARMACY_MEDICINES : "stocks"
    MEDICINES ||--o{ PHARMACY_MEDICINES : "cataloged_in"
    PHARMACIES ||--o{ RESERVATIONS : "receives"
    RESERVATIONS ||--|{ RESERVATION_ITEMS : "contains"
    PHARMACY_MEDICINES ||--o{ RESERVATION_ITEMS : "reserved_from"

    USERS {
        bigint id PK
        string name
        string email UK
        string phone UK
        string password
        enum role "admin, pharmacy, patient"
        timestamp email_verified_at
        timestamps created_at
    }

    PHARMACIES {
        bigint id PK
        bigint user_id FK
        string name
        string license_number UK
        string phone
        string address
        decimal latitude "10,8"
        decimal longitude "11,8"
        boolean is_active
        boolean is_verified
        timestamps created_at
    }

    CATEGORIES {
        bigint id PK
        string name
        string slug UK
        string description
        timestamps created_at
    }

    MEDICINES {
        bigint id PK
        bigint category_id FK
        string scientific_name
        string trade_name
        string barcode UK
        string dosage_form
        string strength
        string manufacturer
        boolean is_prescription_required
        timestamps created_at
    }

    PHARMACY_MEDICINES {
        bigint id PK
        bigint pharmacy_id FK
        bigint medicine_id FK
        int available_quantity
        decimal price "10,2"
        enum status "available, low_stock, out_of_stock"
        timestamps updated_at
    }

    RESERVATIONS {
        bigint id PK
        string reservation_code UK
        bigint user_id FK
        bigint pharmacy_id FK
        enum status "pending, confirmed, completed, expired, cancelled"
        decimal total_amount "10,2"
        timestamp expires_at
        timestamp confirmed_at
        timestamp completed_at
        timestamps created_at
    }

    RESERVATION_ITEMS {
        bigint id PK
        bigint reservation_id FK
        bigint pharmacy_medicine_id FK
        int quantity
        decimal unit_price "10,2"
        timestamps created_at
    }
```

### 2.2 التحقق من درجات التطبيع (Database Normalization - 3NF)
1. **النموذج الأولي (1NF):** كافة الحقول ذرية (Atomic)، ولا توجد مصفوفات أو بيانات مكررة داخل الحقل الواحد.
2. **النموذج الثاني (2NF):** كل جدول يمتلك مفتاحاً رئيسياً أحادياً (`id`)، وجميع الحقول غير المفتاحية تعتمد اعتماداً وظيفياً كاملاً على المفتاح الرئيسي.
3. **النموذج الثالث (3NF):** لا يوجد أي اعتماد انتقالي (Transitive Dependency) بين الحقول غير المفتاحية؛ حيث تم فصل بيانات الفئات والكيانات المستقلة (مثل `categories` و `pharmacy_medicines`) في جداول منفصلة.

### 2.3 استراتيجية الفهارس والأداء (Indexing Strategy)
- **فهرس البحث المكاني (Spatial / Composite Index):**  
  فهرس مركب على `PHARMACIES (latitude, longitude)` لتسريع استعلامات البحث الجغرافي وحساب المسافة دون عمل Full Table Scan.
- **فهرس فريد مركب (Unique Composite Index):**  
  `PHARMACY_MEDICINES (pharmacy_id, medicine_id)` لمنع تكرار نفس الدواء في مخزون الصيدلية الواحدة وضمان نزاهة البيانات.
- **فهارس البحث النصي (B-Tree Search Indexes):**  
  فهارس على `MEDICINES (scientific_name)`, `MEDICINES (trade_name)`, و `MEDICINES (barcode)`.
- **فهرس مؤقتات الحجز (Index on Reservations Expiry):**  
  فهرس على `RESERVATIONS (status, expires_at)` لتسريع مهمة الخلفية (Scheduled Job) التي تلغي الحجوزات المنتهية كل دقيقة.

---

## 3. مخططات لغة النمذجة الموحدة (UML Diagrams)

### 3.1 مخطط الفئات كائنية التوجه (UML Class Diagram)
يطبق المخطط مبادئ SOLID ونمط الـ **Repository & Service Pattern**:

```mermaid
classDiagram
    class BaseController {
        +sendResponse(data, message) Response
        +sendError(error, code) Response
    }

    class MedicineController {
        -MedicineServiceInterface medicineService
        +search(Request request) JsonResponse
        +details(int id) JsonResponse
    }

    class ReservationController {
        -ReservationServiceInterface reservationService
        +store(ReservationRequest request) JsonResponse
        +cancel(int id) JsonResponse
        +confirmPickup(int id) JsonResponse
    }

    class MedicineServiceInterface {
        <<interface>>
        +searchNearbyMedicines(string query, float lat, float lng, float radius) Collection
        +getMedicineDetails(int id) MedicineDTO
    }

    class ReservationServiceInterface {
        <<interface>>
        +createReservation(int userId, int pharmacyMedicineId, int qty) ReservationDTO
        +expireReservations() int
        +confirmPickup(int reservationId, int pharmacyId) bool
    }

    class MedicineService {
        -MedicineRepositoryInterface medicineRepo
        +searchNearbyMedicines(...)
        +getMedicineDetails(...)
    }

    class ReservationService {
        -ReservationRepositoryInterface reservationRepo
        -PharmacyMedicineRepositoryInterface stockRepo
        +createReservation(...)
        +expireReservations(...)
        +confirmPickup(...)
    }

    class MedicineRepositoryInterface {
        <<interface>>
        +searchWithLocation(string query, float lat, float lng, float radius) Collection
        +findById(int id) Medicine
    }

    class EloquentMedicineRepository {
        +searchWithLocation(...)
        +findById(...)
    }

    BaseController <|-- MedicineController
    BaseController <|-- ReservationController
    MedicineController --> MedicineServiceInterface
    ReservationController --> ReservationServiceInterface
    MedicineServiceInterface <|.. MedicineService
    ReservationServiceInterface <|.. ReservationService
    MedicineService --> MedicineRepositoryInterface
    MedicineRepositoryInterface <|.. EloquentMedicineRepository
```

---

### 3.2 مخطط التتابع لمسار البحث الجغرافي اللحظي (Sequence Diagram: Geo-Search)

```mermaid
sequenceDiagram
    autonumber
    actor Patient as المريض (Flutter App)
    participant API as خادم الـ API (Laravel)
    participant Svc as GeoSearchService
    participant Repo as MedicineRepository
    participant DB as قاعدة البيانات (MySQL)

    Patient->>API: GET /api/v1/medicines/search?q=Paracetamol&lat=15.35&lng=44.20
    activate API
    API->>Svc: searchNearbyMedicines("Paracetamol", 15.35, 44.20, radius=10km)
    activate Svc
    Svc->>Repo: queryStockWithHaversineFormula("Paracetamol", 15.35, 44.20, 10)
    activate Repo
    Repo->>DB: SELECT medicines, pharmacies, (Haversine Distance) WHERE available_quantity > 0 ORDER BY distance ASC
    activate DB
    DB-->>Repo: قائمة الصيدليات المتوفر بها الدواء مع المسافات والأسعار
    deactivate DB
    Repo-->>Svc: كائنات البيانات (Data Entities)
    deactivate Repo
    Svc-->>API: مصفوفة نتائج مهيكلة (MedicineSearchResource)
    deactivate Svc
    API-->>Patient: 200 OK (قائمة الصيدليات والأسعار والمسافة بالكيلومتر)
    deactivate API
```

---

### 3.3 مخطط التتابع للحجز المؤقت والتحكم بالتزامن (Sequence Diagram: Concurrency Reservation)

```mermaid
sequenceDiagram
    autonumber
    actor Patient as المريض (Flutter Client)
    participant API as ReservationController
    participant Svc as ReservationService
    participant DB as MySQL (ACID Transactions)
    participant Job as ReservationTTLJob
    actor Pharmacist as الصيدلية (Web Portal)

    Patient->>API: POST /api/v1/reservations {pharmacy_medicine_id: 12, qty: 1}
    activate API
    API->>Svc: createReservation(userId, 12, 1)
    activate Svc
    Svc->>DB: بدء معاملة ذرية (DB::beginTransaction)
    Svc->>DB: SELECT * FROM pharmacy_medicines WHERE id=12 FOR UPDATE (Pessimistic Lock)
    activate DB
    Note over Svc,DB: حجز وقفل الصف لمنع أي طلب متزامن لنفس العبوة
    alt الكمية المتوفرة كافية (available_quantity >= 1)
        Svc->>DB: UPDATE pharmacy_medicines SET available_quantity = available_quantity - 1
        Svc->>DB: INSERT INTO reservations (code, expires_at = NOW + 30min, status='pending')
        Svc->>DB: إتمام المعاملة (DB::commit)
        DB-->>Svc: تم الحفظ بنجاح
        deactivate DB
        Svc-->>API: Reservation Created (رمز الحجز، مؤقت 30 دقيقة)
        API-->>Patient: 201 Created {reservation_code: "RES-9821", ttl_seconds: 1800}
        API--)Pharmacist: إشعار فوري بورود حجز جديد (Web Notification)
    else الكمية غير كافية أو محجوزة
        Svc->>DB: التراجع عن المعاملة (DB::rollBack)
        Svc-->>API: خطأ: نفاد الكمية المتاحة
        API-->>Patient: 422 Unprocessable Entity (عذراً، نفد المخزون أثناء الطلب)
    end
    deactivate Svc
    deactivate API

    opt في حال انقضاء 30 دقيقة دون استلام الدواء
        activate Job
        Job->>DB: SELECT * FROM reservations WHERE status='pending' AND expires_at < NOW()
        Job->>DB: UPDATE reservations SET status='expired'
        Job->>DB: UPDATE pharmacy_medicines SET available_quantity = available_quantity + 1 (إعادة المخزون)
        Job--)Patient: تنبيه بإلغاء الحجز لانتهاء المهلة الزمنية
        deactivate Job
    end
```

---

### 3.4 مخطط الأنشطة لدورة حياة المخزون والحجز (UML Activity Diagram)

```mermaid
stateDiagram-v2
    [*] --> متوفر_في_المخزون: الصيدلي يضيف الصنف والكمية
    متوفر_في_المخزون --> طلب_حجز_مؤقت: المريض يطلب الحجز من تطبيق الموبايل
    
    state طلب_حجز_مؤقت {
        [*] --> قفل_الصف_المتزامن
        قفل_الصف_المتزامن --> فحص_الكمية
        فحص_الكمية --> خصم_الكمية_وبدء_المؤقت: الكمية متوفرة
        فحص_الكمية --> رفض_الطلب: الكمية 0
    }

    خصم_الكمية_وبدء_المؤقت --> قيد_الانتظار_30_دقيقة

    state قيد_الانتظار_30_دقيقة {
        [*] --> انتظار_حضور_المريض
        انتظار_حضور_المريض --> حضور_المريض_وتأكيد_الصيدلي: خلال 30 دقيقة
        انتظار_حضور_المريض --> تجاوز_المهلة_الزمنية: بعد 30 دقيقة
    }

    حضور_المريض_وتأكيد_الصيدلي --> مكتمل_ومسلم: خصم نهائي من المخزون
    تجاوز_المهلة_الزمنية --> ملغي_لانتهاء_المهلة: إعادة الكمية تلقائياً للمخزون
    ملغي_لانتهاء_المهلة --> متوفر_في_المخزون

    مكتمل_ومسلم --> [*]
```

---

## 4. معايير واجهات برمجة التطبيقات (RESTful API Specifications)

### 4.1 المعايير المعتمدة:
- **تنسيق البيانات:** JSON حصراً في الطلب والاستجابة (`Content-Type: application/json`, `Accept: application/json`).
- **المصادقة:** ترويسة المصادقة المعتمدة: `Authorization: Bearer <Sanctum-Token>`.
- **أكواد الحالة القياسية (HTTP Status Codes):**
  - `200 OK`: نجاح الاستعلام واسترجاع البيانات.
  - `201 Created`: نجاح إنشاء الحجز أو الحساب.
  - `400 Bad Request`: خطأ في صياغة المدخلات.
  - `401 Unauthorized`: غياب التوكن أو انتهاء صلاحيته.
  - `403 Forbidden`: محاولة الوصول لمورد غير مصرح (مثال: صيدلي يحاول تعديل مخزون صيدلية أخرى).
  - `404 Not Found`: الصنف أو الصيدلية غير موجودة.
  - `422 Unprocessable Entity`: فشل التحقق من صحة الحقول (Validation Failed) أو نفاد المخزون أثناء الحجز.
  - `500 Internal Server Error`: خطأ داخلي في الخادم مع تسجيل السجل (Log) في بيئة معزولة.

### 4.2 نماذج الاستجابة الموحدة (Standard JSON Response Structure):

* **استجابة النجاح (Success Response):**
```json
{
  "success": true,
  "message": "تم العثور على الأدوية بنجاح",
  "data": [
    {
      "medicine_id": 105,
      "trade_name": "Panadol Extra",
      "scientific_name": "Paracetamol + Caffeine",
      "pharmacy": {
        "id": 14,
        "name": "صيدلية الشفاء المركزية",
        "distance_km": 1.4,
        "address": "شارع حدة - صنعاء",
        "phone": "+967771234567"
      },
      "price": 1200.00,
      "currency": "YER",
      "status": "available",
      "stock_quantity": 8
    }
  ],
  "meta": {
    "count": 1,
    "search_radius_km": 10
  }
}
```

* **استجابة الخطأ (Error Response):**
```json
{
  "success": false,
  "message": "عذراً، نفد المخزون أثناء معالجة الحجز",
  "errors": {
    "pharmacy_medicine_id": ["الكمية المطلوبة غير متوفرة حالياً في هذه الصيدلية"]
  }
}
```

---

## 5. معايير التصميم وتدفق الشاشات (UI/UX Screen Flow)

### 5.1 تدفق شاشات تطبيق الهاتف (Flutter Flow):
1. **شاشة Splash:** شعار المنصة بالأخضر الزمردي وخلفية بيضاء نقية مع مؤشر تحميل ناعم.
2. **شاشة الاستكشاف والبحث الرئيسية:**
   - شريط بحث ذكي مزود بقارئ باركود ومحدد تلقائي للموقع الجغرافي.
   - تصنيفات سريعة (أدوية شائعة، مضادات حيوية، أدوية مزمنة).
3. **شاشة نتائج الصيدليات والأسعار:**
   - بطاقات بيضاء ناعمة بظلال هادئة تعرض اسم الصيدلية، المسافة بالأمتار/الكيلومتر، السعر، وشارة الحالة (متوفر بالأخضر / وشيك النفاذ بالبرتقالي).
4. **شاشة تفاصيل الدواء والحجز المؤقت:**
   - عرض الجرعة والشركة المصنعة والبدائل العلمية المتوفرة في صيدليات أخرى.
   - زر الحجز الفوري الأخضر (عرض مدة الحجز: 30 دقيقة).
5. **شاشة تذكرة الحجز اللحظية (Reservation Pass):**
   - كود الحجز (QR Code ورقم مميز) + مؤقت عد تنازلي حي (Live Countdown) حتى انتهاء الـ 30 دقيقة.

### 5.2 تدفق شاشات بوابة ويب الصيدلية (Laravel Web Flow):
1. **شاشة تسجيل الدخول للصيدلية:** تسجيل آمن باسم المستخدم والرقم السري.
2. **لوحة التحكم الرئيسية (Dashboard):** مؤشرات رقمية للكميات المتوفرة، الحجوزات النشطة، والتنبيهات.
3. **شاشة إدارة المخزون (Inventory Grid):** جدول تفاعلي لتعديل الكمية والسعر بنقرة واحدة وتفعيل/تعطيل توفر الصنف.
4. **شاشة الحجوزات الواردة (Live Orders):** قائمة لحظية بالحجوزات مع زر "تأكيد التسليم والمحاسبة" وزر "إلغاء".

---

## 6. المراجع العلمية (References - APA 7th Edition)
1. Sommerville, I. (2016). *Software Engineering* (10th ed.). Pearson Education.
2. Fowler, M. (2002). *Patterns of Enterprise Application Architecture*. Addison-Wesley Professional.
3. Gamma, E., Helm, R., Johnson, R., & Vlissides, J. (1994). *Design Patterns: Elements of Reusable Object-Oriented Software*. Addison-Wesley.
4. Fielding, R. T. (2000). *Architectural Styles and the Design of Network-based Software Architectures* (Doctoral dissertation). University of California, Irvine.
5. Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of Database Systems* (7th ed.). Pearson.
