---
name: pharmaconnect-design-system
description: >-
  دليل تطبيقي وأكواد جاهزة لنظام تصميم الواجهات الطبية (Green & White UI/UX Design System)
  لواجهات الويب وتطبيق Flutter في مشروع PharmaConnect.
---

# مهارة تطبيق نظام تصميم الواجهات الطبية (Medical Green & White System)

تحدد هذه المهارة حزم الألوان والمكونات والقوالب الجاهزة لبناء واجهات ويب وتطبيقات موبايل ذات طابع طبي فائق الجاذبية والراحة البصرية.

## 1. شفرات ألوان Flutter و CSS

### أ. في Flutter (Dart Theme Data):
```dart
import 'package:flutter/material.dart';

class PharmaTheme {
  static const Color primaryGreen = Color(0xFF059669);
  static const Color primaryGreenLight = Color(0xFF10B981);
  static const Color primaryGreenDark = Color(0xFF065F46);
  static const Color mintBackground = Color(0xFFECFDF5);
  static const Color mintAccent = Color(0xFFD1FAE5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: primaryGreenLight,
        surface: surfaceWhite,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSurface: textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreenDark),
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
```

---

## 2. مكونات الواجهات القياسية
1. **بطاقة الصيدلية ومخزون الدواء (Medicine Pharmacy Card):**
   - تعرض اسم الصيدلية، عنوانها، والمسافة الجغرافية منها بالكيلومتر.
   - تعرض شارة حالة التوفر (متوفر: أخضر زمردي `#059669` / متبقي قليل: برتقالي هادئ `#D97706`).
   - زر حجز سريع (Quick Reserve Button) مفعم بالأخضر الطبي وبحواف ناعمة.
2. **شاشات الويب لإدارة المخزون (Laravel Blade / Tailwind):**
   - جدول نظيف بأسطح بيضاء نقية وحدود ناعمة (`bg-white shadow-sm border border-slate-200 rounded-xl`).
   - شريط بحث ديناميكي وفلاتر حسب التوفر والصلاحية.
   - إشعارات منبثقة بتصميم هادئ ومريح للعين.
