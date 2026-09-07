import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/purchases_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/purchase_status_badge.dart';

class PurchaseOrder extends StatelessWidget {
  const PurchaseOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final PurchasesController controller = Get.find<PurchasesController>();

    return Obx(() {
      final orders = controller.filteredOrders;

      if (orders.isEmpty) {
        return const _EmptyOrders();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _OrderRow(order: orders[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: orders.length,
      );
    });
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final PurchaseOrderModel order;

  String get _formattedDate =>
      '${order.date.year}-${order.date.month.toString().padLeft(2, '0')}-${order.date.day.toString().padLeft(2, '0')}';

  void _showDetails(BuildContext context) {
    final supplierName = Get.find<PurchasesController>().supplierNameFor(order.supplierId);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    PurchaseStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(supplierName, style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13)),
                const Divider(height: 24),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.productName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                        Text('${item.quantity} × ${item.costPrice.toStringAsFixed(2)} ج.س', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600)),
                        Text('${item.lineTotal.toStringAsFixed(2)} ج.س', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    Text('${order.total.toStringAsFixed(2)} ج.س', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xff0e4a35))),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supplierName = Get.find<PurchasesController>().supplierNameFor(order.supplierId);
    final isPending = order.status == PurchaseOrderStatus.pending;

    return InkWell(
      onTap: () => _showDetails(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Center(child: Text(order.id, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)))),
            Expanded(flex: 2, child: Center(child: Text(supplierName, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 1, child: Center(child: Text(_formattedDate, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 1, child: Center(child: Text('${order.itemCount}', style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${order.total.toStringAsFixed(2)} ج.س',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(flex: 1, child: Center(child: PurchaseStatusBadge(status: order.status))),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPending) ...[
                    IconButton(
                      onPressed: () => Get.find<PurchasesController>().markReceived(order.id),
                      icon: const Icon(Icons.check_circle_outline, color: Color(0xff2E7D32), size: 20),
                      tooltip: 'تأكيد الاستلام',
                    ),
                    IconButton(
                      onPressed: () => Get.find<PurchasesController>().cancelOrder(order.id),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                      tooltip: 'إلغاء الأمر',
                    ),
                  ] else
                    Text('-', style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا توجد أوامر شراء مطابقة',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب تعديل الفلاتر أو أنشئ أمر شراء جديد',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
