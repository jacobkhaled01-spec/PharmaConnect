import 'medicine_search_model.dart';

class ReservationModel {
  final int id;
  final String reservationCode;
  final String status;
  final double totalAmount;
  final String currency;
  final DateTime? expiresAt;
  final int ttlSecondsRemaining;
  final bool isExpired;
  final PharmacyInfo pharmacy;
  final List<ReservationItemModel> items;
  final DateTime? createdAt;

  ReservationModel({
    required this.id,
    required this.reservationCode,
    required this.status,
    required this.totalAmount,
    required this.currency,
    this.expiresAt,
    required this.ttlSecondsRemaining,
    required this.isExpired,
    required this.pharmacy,
    required this.items,
    this.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? 0,
      reservationCode: json['reservation_code'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'YER',
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      ttlSecondsRemaining: json['ttl_seconds_remaining'] ?? 1800,
      isExpired: json['is_expired'] ?? false,
      pharmacy: PharmacyInfo.fromJson(json['pharmacy'] ?? {}),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ReservationItemModel.fromJson(item))
              .toList() ??
          [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  /// احتساب الثواني المتبقية الحقيقية بناءً على فارق توقيت النظام الآن
  int get currentRemainingSeconds {
    if (status == 'completed' || status == 'cancelled') return 0;
    if (expiresAt != null) {
      final diff = expiresAt!.difference(DateTime.now()).inSeconds;
      return diff > 0 ? diff : 0;
    }
    return ttlSecondsRemaining;
  }

  /// هل انتهت المهلة فعلياً بناءً على ساعة الجهاز الآن
  bool get isCurrentlyExpired {
    if (status == 'completed' || status == 'cancelled') return false;
    if (status == 'expired') return true;
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    return isExpired;
  }
}

class ReservationItemModel {
  final String medicineName;
  final String scientificName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? imageUrl;

  ReservationItemModel({
    required this.medicineName,
    required this.scientificName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.imageUrl,
  });

  factory ReservationItemModel.fromJson(Map<String, dynamic> json) {
    return ReservationItemModel(
      medicineName: json['medicine_name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
    );
  }
}
