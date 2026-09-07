import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/dashboard_controller.dart';

class DashboardProductInfo extends StatelessWidget {
  const DashboardProductInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Column(
      children: [
        Expanded(
          child: Obx(
            () => _MiniListCard(
              title: 'منتجات منخفضة المخزون',
              icon: Icons.inventory_2_outlined,
              color: const Color(0xffB8860B),
              items: controller.topLowStockProducts,
              emptyText: 'لا توجد منتجات منخفضة المخزون',
              trailingBuilder: (p) => '${p.stock}',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Obx(
            () => _MiniListCard(
              title: 'تنبيهات الصلاحية',
              icon: Icons.warning_amber_outlined,
              color: const Color(0xff9E1B1B),
              items: controller.topExpiryAlerts,
              emptyText: 'لا توجد تنبيهات صلاحية حالياً',
              trailingBuilder: (p) {
                final days = p.expiryDate.difference(DateTime.now()).inDays;
                return days < 0 ? 'منتهية' : '$days يوم';
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniListCard extends StatelessWidget {
  const _MiniListCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.emptyText,
    required this.trailingBuilder,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<ProductModel> items;
  final String emptyText;
  final String Function(ProductModel) trailingBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(emptyText, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500)),
                  )
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => Divider(height: 10, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                            ),
                          ),
                          Text(
                            trailingBuilder(product),
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: color),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
