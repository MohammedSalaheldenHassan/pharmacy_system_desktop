import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/expiry_alerts_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/inventory_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_status_badge.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/stock_adjustment_dialog.dart';

/// A product's row in the current-stock table, with an "adjust" action.
/// Reads its data live from [ProductsController] via [InventoryController]
/// — no separate mock stock list.
class InventoryItem extends StatelessWidget {
  const InventoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.find<InventoryController>();

    return Obx(() {
      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return const _EmptyInventory();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _InventoryRow(product: products[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: products.length,
      );
    });
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final threshold = Get.find<InventoryController>().lowStockThreshold;
    final leadDays = Get.isRegistered<ExpiryAlertsController>()
        ? Get.find<ExpiryAlertsController>().leadDays
        : Get.put(ExpiryAlertsController()).leadDays;
    final status = product.statusFor(threshold);
    final daysToExpiry = product.expiryDate.difference(DateTime.now()).inDays;
    final expiringSoon = daysToExpiry >= 0 && daysToExpiry <= leadDays && status != ProductStatus.expired;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                Text(product.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Expanded(flex: 1, child: Center(child: Text('${product.stock}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)))),
          Expanded(flex: 1, child: Center(child: Text('$threshold', style: const TextStyle(fontFamily: 'Cairo')))),
          Expanded(
            flex: 2,
            child: Center(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  ProductStatusBadge(status: status),
                  if (expiringSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'ينتهي قريباً',
                        style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton.icon(
                onPressed: () => Get.dialog(StockAdjustmentDialog(product: product)),
                icon: const Icon(Icons.tune, size: 16, color: Color(0xff0e4a35)),
                label: const Text('تعديل', style: TextStyle(fontFamily: 'Cairo', color: Color(0xff0e4a35), fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا توجد منتجات مطابقة',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب تعديل كلمة البحث أو الفلاتر',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
