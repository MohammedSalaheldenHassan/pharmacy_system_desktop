import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';
import 'package:pharmacy_system/data/models/supplier_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/purchases_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';

class SupplierDetailsDialog extends StatelessWidget {
  const SupplierDetailsDialog({super.key, required this.supplier});

  final SupplierModel supplier;

  @override
  Widget build(BuildContext context) {
    final orderCount = Get.find<SuppliersController>().purchaseOrderCountFor(supplier.id);
    final orders = Get.isRegistered<PurchasesController>()
        ? Get.find<PurchasesController>()
            .orders
            .where((o) => o.supplierId == supplier.id)
            .toList()
        : const <PurchaseOrderModel>[];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                supplier.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 4),
              Text(
                supplier.contactPerson,
                style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13),
              ),
              const Divider(height: 28),
              _DetailRow(label: 'رقم الهاتف', value: supplier.phone),
              _DetailRow(label: 'البريد الإلكتروني', value: supplier.email),
              _DetailRow(label: 'العنوان', value: supplier.address),
              _DetailRow(label: 'عدد أوامر الشراء', value: '$orderCount'),
              const SizedBox(height: 12),
              Text(
                'سجل المشتريات',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              if (orders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'لا توجد أوامر شراء لهذا المورد بعد.',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.id, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 12)),
                            Text(order.status.label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600)),
                            Text('${order.total.toStringAsFixed(2)} ج.س', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
