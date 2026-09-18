import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/medicine_search_model.dart';
import 'reservation_pass_screen.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final MedicineSearchItem item;

  const MedicineDetailsScreen({super.key, required this.item});

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  int _quantity = 1;
  bool _isLoading = false;

  void _reserveMedicine() async {
    setState(() {
      _isLoading = true;
    });

    final reservation = await ApiService().createReservation(
      stockId: widget.item.stockId,
      quantity: _quantity,
      ttlMinutes: 30,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationPassScreen(reservation: reservation),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.item.medicine;
    final pharma = widget.item.pharmacy;

    return Scaffold(
      appBar: AppBar(
        title: Text(med.tradeName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة رأس الدواء
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          med.tradeName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: PharmaTheme.textMain),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: PharmaTheme.mintAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'متوفر ${widget.item.availableQuantity} علبة',
                          style: const TextStyle(color: PharmaTheme.primaryGreenDark, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    med.scientificName,
                    style: const TextStyle(fontSize: 15, color: PharmaTheme.textMuted, fontStyle: FontStyle.italic),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('الشكل الصيدلاني والتركيز:', '${med.dosageForm ?? 'أقراص'} - ${med.strength ?? ''}'),
                  if (med.manufacturer != null)
                    _buildDetailRow('الشركة المصنعة:', med.manufacturer!),
                  if (med.category != null)
                    _buildDetailRow('التصنيف الطبي:', med.category!),
                  if (med.isPrescriptionRequired)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: PharmaTheme.statusDanger),
                          SizedBox(width: 6),
                          Text('يتطلب وصفة طبية معتمدة عند الاستلام', style: TextStyle(color: PharmaTheme.statusDanger, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // بطاقة الصيدلية المتوفر لديها
            const Text('الصيدلية المحددة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_pharmacy, color: PharmaTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(pharma.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: PharmaTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(child: Text(pharma.address, style: const TextStyle(color: PharmaTheme.textMuted, fontSize: 13))),
                      if (widget.item.distanceKm != null)
                        Text('${widget.item.distanceKm} كم', style: const TextStyle(fontWeight: FontWeight.bold, color: PharmaTheme.primaryGreen)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // محدد الكمية والسعر
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PharmaTheme.mintBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PharmaTheme.mintAccent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('سعر العبوة الواحدة:', style: TextStyle(fontSize: 12, color: PharmaTheme.textMuted)),
                      Text('${widget.item.price.toStringAsFixed(0)} ريال', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PharmaTheme.primaryGreenDark)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: PharmaTheme.primaryGreen,
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: _quantity < widget.item.availableQuantity ? () => setState(() => _quantity++) : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: PharmaTheme.primaryGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // زر الحجز
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: _isLoading ? null : _reserveMedicine,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('حجز مؤكد الآن (${(_quantity * widget.item.price).toStringAsFixed(0)} ريال)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: PharmaTheme.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
