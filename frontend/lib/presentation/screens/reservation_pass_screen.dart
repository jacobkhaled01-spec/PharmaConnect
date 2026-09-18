import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reservation_model.dart';
import '../widgets/pharmacy_route_map_widget.dart';

class ReservationPassScreen extends StatefulWidget {
  final ReservationModel reservation;

  const ReservationPassScreen({super.key, required this.reservation});

  @override
  State<ReservationPassScreen> createState() => _ReservationPassScreenState();
}

class _ReservationPassScreenState extends State<ReservationPassScreen> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.reservation.ttlSecondsRemaining;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remainingSeconds <= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? PharmaTheme.darkSurface : Colors.white;
    final borderColor = isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكرة الحجز المؤكد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // بطاقة التذكرة الرئيسية
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 8),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // رمز الاستجابة والشعار
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2))
                          : (isDark ? const Color(0xFF064E3B) : PharmaTheme.mintBackground),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isExpired ? Icons.timer_off : Icons.qr_code_2,
                      size: 70,
                      color: isExpired
                          ? (isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger)
                          : (isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reservation.reservationCode,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أظهر هذا الرمز للصيدلي عند الاستلام',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Divider(height: 36, color: borderColor),

                  // مؤقت العد التنازلي الحي
                  Text(
                    isExpired ? 'انتهت مهلة الحجز' : 'المهلة الزمنية المتبقية (TTL)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2))
                          : (isDark ? const Color(0xFF064E3B).withAlpha(150) : PharmaTheme.mintAccent),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isExpired ? 'ملغي آلياً' : _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isExpired
                            ? (isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger)
                            : (isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreenDark),
                      ),
                    ),
                  ),
                  Divider(height: 36, color: borderColor),

                  // تفاصيل الصيدلية
                  Row(
                    children: [
                      const Icon(Icons.local_pharmacy, color: PharmaTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.reservation.pharmacy.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.reservation.pharmacy.address,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 36, color: borderColor),

                  // تفاصيل الأصناف
                  ...widget.reservation.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.medicineName} × ${item.quantity}')),
                          const SizedBox(width: 8),
                          Text('${item.subtotal.toStringAsFixed(0)} ريال', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المبلغ الإجمالي:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '${widget.reservation.totalAmount.toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: PharmaTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // خريطة المسار المباشر والملاحة للوصول للصيدلية
            PharmacyRouteMapWidget(
              pharmacy: widget.reservation.pharmacy,
              distanceKm: 1.2,
            ),
            const SizedBox(height: 20),

            // زر العودة للرئيسية
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة لشاشة البحث'),
            ),
          ],
        ),
      ),
    );
  }
}
