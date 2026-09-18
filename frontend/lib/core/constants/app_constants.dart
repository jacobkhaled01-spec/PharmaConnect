import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'PharmaConnect';
  static const String appTagline = 'المنصة الذكية لتتبع وفرة الأدوية بين الصيدليات';

  // Base API Configuration
  // لتفعيل الاتصال بالخادم السحابي الحي على Render، اجعل هذه القيمة true
  static const bool useCloudBackend = false;
  static const String cloudBaseUrl = 'https://pharmaconnect-backend.onrender.com/api/v1';

  static String get baseUrl {
    if (useCloudBackend) {
      return cloudBaseUrl;
    }
    if (kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS))) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    // للأجهزة المحمولة ومحاكي الأندرويد
    return 'http://10.0.2.2:8000/api/v1';
  }

  // Endpoints
  static const String searchMedicinesEndpoint = '/medicines/search';
  static const String reservationsEndpoint = '/reservations';
  static const String myReservationsEndpoint = '/reservations/my';
  static const String pharmacyStockEndpoint = '/pharmacies';
  static const String authLoginEndpoint = '/auth/login';

  // Business Rules Constants
  static const int defaultTtlMinutes = 30;
  static const double defaultSearchRadiusKm = 10.0;
}
