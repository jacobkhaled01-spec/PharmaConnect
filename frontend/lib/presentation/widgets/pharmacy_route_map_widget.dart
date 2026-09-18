import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/medicine_search_model.dart';

class PharmacyRouteMapWidget extends StatelessWidget {
  final PharmacyInfo pharmacy;
  final double distanceKm;
  final double userLat;
  final double userLng;

  const PharmacyRouteMapWidget({
    super.key,
    required this.pharmacy,
    this.distanceKm = 1.2,
    this.userLat = 15.3300,
    this.userLng = 44.1900,
  });

  Future<void> _openGoogleMapsRoute() async {
    final destLat = pharmacy.latitude ?? 15.32685;
    final destLng = pharmacy.longitude ?? 44.19512;
    
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$destLat,$destLng&travelmode=driving',
    );

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final drivingMinutes = (distanceKm * 3.5).clamp(2, 60).ceil();
    final walkingMinutes = (distanceKm * 12).clamp(5, 180).ceil();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الخريطة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PharmaTheme.mintAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.map_outlined, color: PharmaTheme.primaryGreenDark, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خريطة المسار المباشر',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'من موقعك الحالي إلى الصيدلية',
                          style: TextStyle(color: PharmaTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PharmaTheme.mintBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PharmaTheme.mintAccent),
                  ),
                  child: Text(
                    '$distanceKm كم',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: PharmaTheme.primaryGreenDark, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // لوحة رسم الخريطة التفاعلية مع المسار
          Container(
            height: 170,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Stack(
              children: [
                // رسم الطرق والمسار المنحني
                CustomPaint(
                  size: const Size(double.infinity, 170),
                  painter: _RouteMapPainter(),
                ),

                // نقطة موقع المريض الحالي
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: const Text('موقعك الحالي', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // بطاقة وقت الوصول في منتصف المسار
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PharmaTheme.primaryGreen),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_car, size: 16, color: PharmaTheme.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          '~ $drivingMinutes دقائق بالسيارة',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: PharmaTheme.primaryGreenDark),
                        ),
                      ],
                    ),
                  ),
                ),

                // نقطة موقع الصيدلية
                Positioned(
                  top: 20,
                  left: 24,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PharmaTheme.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PharmaTheme.primaryGreen.withAlpha(80),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 18),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PharmaTheme.primaryGreen),
                        ),
                        child: Text(
                          pharmacy.name,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PharmaTheme.primaryGreenDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // تفاصيل المسار والتقديرات
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickMetric(Icons.directions_car, '$drivingMinutes دقائق', 'بالسيارة'),
                    _buildQuickMetric(Icons.directions_walk, '$walkingMinutes دقيقة', 'مشياً'),
                    _buildQuickMetric(Icons.straighten, '$distanceKm كم', 'المسافة المباشرة'),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openGoogleMapsRoute,
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text('فتح المسار والملاحة الحية (Google Maps)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: PharmaTheme.textMuted),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: PharmaTheme.textMain)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: PharmaTheme.textMuted)),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    // خطوط الشبكة والشوارع
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // الشارع الرئيسي
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width - 50, size.height - 50);
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.8,
      60,
      40,
    );
    canvas.drawPath(path, roadPaint);

    // خط المسار الأخضر المباشر (Medical Route)
    final routePaint = Paint()
      ..color = PharmaTheme.primaryGreen
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
