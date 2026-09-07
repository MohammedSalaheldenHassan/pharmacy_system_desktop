import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/sales_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/sale_details_dialog.dart';

class SaleList extends StatelessWidget {
  const SaleList({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find<SalesController>();

    return Obx(() {
      final sales = controller.filteredSales;

      if (sales.isEmpty) {
        return const _EmptySales();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _SaleRow(sale: sales[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: sales.length,
      );
    });
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale});

  final SaleRecordModel sale;

  String get _formattedDate =>
      '${sale.date.year}-${sale.date.month.toString().padLeft(2, '0')}-${sale.date.day.toString().padLeft(2, '0')} '
      '${sale.date.hour.toString().padLeft(2, '0')}:${sale.date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.dialog(SaleDetailsDialog(sale: sale)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Center(child: Text(sale.id, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)))),
            Expanded(flex: 2, child: Center(child: Text(_formattedDate, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 2, child: Center(child: Text(sale.cashierName, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 1, child: Center(child: Text('${sale.items.length}', style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${sale.totalRevenue.toStringAsFixed(2)} ج.س',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Color(0xff0e4a35)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySales extends StatelessWidget {
  const _EmptySales();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا توجد مبيعات مطابقة',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب تعديل كلمة البحث أو نطاق التاريخ',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
