import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reservation_model.dart';
import 'reservation_pass_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    final results = await ApiService().getMyReservations();

    if (mounted) {
      setState(() {
        _reservations = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي وطلباتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        color: PharmaTheme.primaryGreen,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: PharmaTheme.primaryGreen),
              )
            : _reservations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد لديك طلبات حجز حالياً',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'عند حجز أي دواء من الصيدليات المتاحة سيظهر طلبك هنا مباشرة لمتابعة الاستلام والمهلة الزمنية.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF94A3B8)
                                  : PharmaTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final item = _reservations[index];
                      return _buildReservationCard(item);
                    },
                  ),
      ),
    );
  }

  Widget _buildReservationCard(ReservationModel item) {
    final isPending = item.status == 'pending' && !item.isExpired;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: isDark ? PharmaTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationPassScreen(reservation: item),
            ),
          ).then((_) => _loadReservations());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPending
                                ? (isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isPending ? Icons.timer_outlined : Icons.check_circle_outline,
                            color: isPending
                                ? (isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreenDark)
                                : (isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.reservationCode,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                item.pharmacy.name,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(item.status, isDark),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(item.status),
                      style: TextStyle(
                        color: _getStatusTextColor(item.status, isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 20, color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0)),
              ...item.items.map(
                (med) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${med.medicineName} (× ${med.quantity})',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${med.subtotal.toStringAsFixed(0)} ريال',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 20, color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0)),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                spacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الإجمالي: ',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${item.totalAmount.toStringAsFixed(0)} ريال',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreen,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationPassScreen(reservation: item),
                        ),
                      ).then((_) => _loadReservations());
                    },
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text('عرض التذكرة والباركود'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBgColor(String status, bool isDark) {
    switch (status) {
      case 'pending':
        return isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent;
      case 'completed':
        return isDark ? const Color(0xFF064E3B).withAlpha(120) : const Color(0xFFDCFCE7);
      case 'expired':
      case 'cancelled':
        return isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      default:
        return isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status, bool isDark) {
    switch (status) {
      case 'pending':
        return isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreenDark;
      case 'completed':
        return isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
      case 'expired':
      case 'cancelled':
        return isDark ? const Color(0xFFF87171) : PharmaTheme.statusDanger;
      default:
        return isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار (حجز نشط)';
      case 'completed':
        return 'تم الاستلام بنجاح';
      case 'expired':
        return 'منتهي الصلاحية';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
