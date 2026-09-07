import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';

class SaleDetailsDialog extends StatelessWidget {
  const SaleDetailsDialog({super.key, required this.sale});

  final SaleRecordModel sale;

  String get _formattedDate =>
      '${sale.date.year}-${sale.date.month.toString().padLeft(2, '0')}-${sale.date.day.toString().padLeft(2, '0')} '
      '${sale.date.hour.toString().padLeft(2, '0')}:${sale.date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sale.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  Text(_formattedDate, style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text('الكاشير: ${sale.cashierName}', style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13)),
              const Divider(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sale.items.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final item = sale.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(item.productName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                          ),
                          Expanded(
                            child: Text(
                              '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${item.revenue.toStringAsFixed(2)} ج.س',
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  Text(
                    '${sale.totalRevenue.toStringAsFixed(2)} ج.س',
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xff0e4a35)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
