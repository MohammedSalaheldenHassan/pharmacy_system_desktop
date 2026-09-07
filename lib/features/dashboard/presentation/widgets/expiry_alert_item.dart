import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/expiry_alerts_controller.dart';

class ExpiryAlertItem extends StatelessWidget {
  const ExpiryAlertItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpiryAlertsController controller = Get.find<ExpiryAlertsController>();

    return Obx(() {
      final alerts = controller.alerts;

      if (alerts.isEmpty) {
        return const _EmptyAlerts();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _AlertRow(product: alerts[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: alerts.length,
      );
    });
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.product});

  final ProductModel product;

  String get _formattedExpiry =>
      '${product.expiryDate.year}-${product.expiryDate.month.toString().padLeft(2, '0')}-${product.expiryDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpiryAlertsController>();
    final days = controller.daysRemaining(product);
    final isExpired = controller.tierOf(product) == ExpiryTier.expired;
    final color = isExpired ? const Color(0xff9E1B1B) : const Color(0xffB8860B);

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
          Expanded(flex: 1, child: Center(child: Text('${product.stock}', style: const TextStyle(fontFamily: 'Cairo')))),
          Expanded(flex: 1, child: Center(child: Text(_formattedExpiry, style: const TextStyle(fontFamily: 'Cairo')))),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isExpired ? 'منتهية منذ ${-days} يوم' : 'تنتهي خلال $days يوم',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton.icon(
                onPressed: () => controller.dismiss(product.id),
                icon: const Icon(Icons.visibility_off_outlined, size: 16, color: Colors.grey),
                label: const Text('إخفاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا توجد تنبيهات صلاحية حالياً',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'كل المنتجات ضمن فترة الصلاحية الآمنة',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
