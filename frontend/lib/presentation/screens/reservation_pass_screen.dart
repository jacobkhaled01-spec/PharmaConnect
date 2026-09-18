import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reservation_model.dart';

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
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
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
                      color: isExpired ? const Color(0xFFFEE2E2) : PharmaTheme.mintBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isExpired ? Icons.timer_off : Icons.qr_code_2,
                      size: 70,
                      color: isExpired ? PharmaTheme.statusDanger : PharmaTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reservation.reservationCode,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: PharmaTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أظهر هذا الرمز للصيدلي عند الاستلام',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Divider(height: 36),

                  // مؤقت العد التنازلي الحي
                  Text(
                    isExpired ? 'انتهت مهلة الحجز' : 'المهلة الزمنية المتبقية (TTL)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isExpired ? const Color(0xFFFEE2E2) : PharmaTheme.mintAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isExpired ? 'ملغي آلياً' : _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isExpired ? PharmaTheme.statusDanger : PharmaTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                  const Divider(height: 36),

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
                      const Icon(Icons.location_on, color: PharmaTheme.textMuted, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.reservation.pharmacy.address,
                          style: const TextStyle(color: PharmaTheme.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 36),

                  // تفاصيل الأصناف
                  ...widget.reservation.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.medicineName} × ${item.quantity}'),
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
            const SizedBox(height: 24),

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
