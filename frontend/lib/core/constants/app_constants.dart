class AppConstants {
  static const String appName = 'PharmaConnect';
  static const String appTagline = 'المنصة الذكية لتتبع وفرة الأدوية بين الصيدليات';

  // Base API Configuration
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // للمحاكي الافتراضي
  static const String liveBaseUrl = 'http://localhost:8000/api/v1';

  // Endpoints
  static const String searchMedicinesEndpoint = '/medicines/search';
  static const String reservationsEndpoint = '/reservations';
  static const String pharmacyStockEndpoint = '/pharmacies';
  static const String authLoginEndpoint = '/auth/login';

  // Business Rules Constants
  static const int defaultTtlMinutes = 30;
  static const double defaultSearchRadiusKm = 10.0;
}
