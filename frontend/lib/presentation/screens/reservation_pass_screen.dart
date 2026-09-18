import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';
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
  late ReservationModel _reservation;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
    _remainingSeconds = _reservation.currentRemainingSeconds;

    // تشغيل العداد التنازلي الحقيقي فقط إذا كان الحجز نشطاً بانتظار الاستلام
    if (_reservation.status == 'pending' && _remainingSeconds > 0) {
      _startTimer();
    }

    // التحقق التلقائي من حالة الحجز الحية في الخادم
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    final fresh = await ApiService().getReservationDetails(_reservation.reservationCode);
    if (fresh != null && mounted) {
      setState(() {
        _reservation = fresh;
        _remainingSeconds = fresh.currentRemainingSeconds;
      });

      if (_reservation.status != 'pending' || _remainingSeconds <= 0) {
        _timer?.cancel();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _reservation.currentRemainingSeconds;
      setState(() {
        _remainingSeconds = remaining;
      });
      if (remaining <= 0) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? PharmaTheme.darkSurface : Colors.white;
    final borderColor = isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0);

    final status = _reservation.status;
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';
    final isExpired = _reservation.isCurrentlyExpired || (!isCompleted && !isCancelled && _remainingSeconds <= 0);

    // تجهيز أيقونة وألوان الحالة بدقة
    final Color iconBg;
    final Color iconColor;
    final IconData statusIcon;
    final String instructionText;
    final String statusSectionTitle;
    final String statusBadgeText;
    final Color statusBadgeBg;
    final Color statusBadgeTextColor;

    if (isCompleted) {
      iconBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
      iconColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
      statusIcon = Icons.check_circle_rounded;
      instructionText = 'تم استلام الدواء وتأكيد العملية بنجاح من الصيدلية ✓';
      statusSectionTitle = 'حالة الطلب والتسليم';
      statusBadgeText = 'تم التسليم والاستلام بنجاح ✓';
      statusBadgeBg = isDark ? const Color(0xFF064E3B).withAlpha(180) : const Color(0xFFDCFCE7);
      statusBadgeTextColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
    } else if (isCancelled) {
      iconBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      iconColor = isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger;
      statusIcon = Icons.cancel_rounded;
      instructionText = 'تم إلغاء هذا الحجز مسبقاً وفك حجز المخزون';
      statusSectionTitle = 'حالة الحجز';
      statusBadgeText = 'تم إلغاء الحجز';
      statusBadgeBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      statusBadgeTextColor = isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger;
    } else if (isExpired) {
      iconBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      iconColor = isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger;
      statusIcon = Icons.timer_off_rounded;
      instructionText = 'انتهت المهلة المحددة للاستلام وتم فك حجز المخزون آلياً';
      statusSectionTitle = 'انتهت مهلة الحجز';
      statusBadgeText = 'ملغي آلياً (انتهت الصلاحية)';
      statusBadgeBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      statusBadgeTextColor = isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger;
    } else {
      iconBg = isDark ? const Color(0xFF064E3B) : PharmaTheme.mintBackground;
      iconColor = isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreen;
      statusIcon = Icons.qr_code_2_rounded;
      instructionText = 'أظهر هذا الرمز للصيدلي عند الاستلام';
      statusSectionTitle = 'المهلة الزمنية المتبقية للاستلام (TTL)';
      statusBadgeText = _formatTime(_remainingSeconds);
      statusBadgeBg = isDark ? const Color(0xFF064E3B).withAlpha(150) : PharmaTheme.mintAccent;
      statusBadgeTextColor = isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreenDark;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكرة الحجز المؤكد'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث حالة الحجز اللحظية',
            onPressed: _isRefreshing
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _isRefreshing = true);
                    await _checkServerStatus();
                    if (!mounted) return;
                    setState(() => _isRefreshing = false);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          _reservation.status == 'completed'
                              ? 'الحجز مؤكد ومكتمل التسليم بنجاح ✓'
                              : 'تم تحديث حالة الحجز من الخادم المركزي.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
          ),
        ],
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
                      color: iconBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      statusIcon,
                      size: 70,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _reservation.reservationCode,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    instructionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Divider(height: 36, color: borderColor),

                  // مؤقت العد التنازلي أو حالة الحجز المؤكدة
                  Text(
                    statusSectionTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusBadgeBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusBadgeText,
                      style: TextStyle(
                        fontSize: isCompleted || isExpired || isCancelled ? 18 : 24,
                        fontWeight: FontWeight.w900,
                        color: statusBadgeTextColor,
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
                          _reservation.pharmacy.name,
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
                          _reservation.pharmacy.address,
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
                  ..._reservation.items.map(
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
                        '${_reservation.totalAmount.toStringAsFixed(0)} ريال',
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
              pharmacy: _reservation.pharmacy,
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
