---
name: pharmaconnect-testing-and-ci
description: >-
  دليل تطبيقي لإجراء الاختبارات التلقائية (Unit & Feature Tests)، فحص التنسيق بـ Laravel Pint،
  واختبارات Flutter Test، وتكوين وإدارة خطوط أنابيب CI/CD في GitHub Actions.
---

# مهارة الاختبارات التلقائية والتكامل المستمر (Automated Testing & CI/CD)

توفر هذه المهارة أوامر وأكواد تشغيل الاختبارات وفحص الجودة التلقائي لمشروع **PharmaConnect**.

## 1. فحص التنسيق والجودة بـ Laravel Pint
- **تشغيل الفحص دون تعديل (Test Mode):**
  ```bash
  cd backend
  ./vendor/bin/pint --test
  ```
- **إصلاح التنسيق تلقائياً (Auto-fix):**
  ```bash
  cd backend
  ./vendor/bin/pint
  ```

---

## 2. تشغيل اختبارات PHPUnit / Pest للـ Backend
- **تشغيل كافة الاختبارات:**
  ```bash
  cd backend
  php artisan test
  ```
- **تشغيل اختبارات وحدة معينة (Unit Test):**
  ```bash
  php artisan test --filter=ReservationTest
  ```
- **نموذج اختبار وحدة لمعاملة الحجز المؤقت:**
  ```php
  public function test_medicine_reservation_decrements_stock_temporarily()
  {
      $medicine = Medicine::factory()->create(['stock' => 5]);
      $response = $this->postJson('/api/v1/reservations', [
          'medicine_id' => $medicine->id,
          'quantity' => 1
      ]);
      $response->assertStatus(201);
      $this->assertEquals(4, $medicine->fresh()->available_stock);
  }
  ```

---

## 3. تشغيل فحص واختبارات تطبيق الهاتف (Flutter)
- **التحليل الساكن للكود:**
  ```bash
  cd frontend
  flutter analyze
  ```
- **تشغيل اختبارات الوحدة والواجهات:**
  ```bash
  cd frontend
  flutter test
  ```

---

## 4. إعدادات GitHub Actions وتصحيح فشل الـ Pipeline
- في حال فشل خط الأنابيب (CI Workflow Failure):
  1. فحص الـ Logs لمعرفة الخطوة المسببة (Pint / Test / Lint).
  2. تشغيل الأمر محلياً وتصحيح الخطأ.
  3. عمل commit وتحديث الـ Pull Request.
