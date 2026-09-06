import 'package:flutter/material.dart';
import 'package:pharmacy_system/core/mock/models/product_model.dart';

class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({super.key, required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      ProductStatus.available => const Color(0xff2E7D32),
      ProductStatus.lowStock => const Color(0xffB8860B),
      ProductStatus.outOfStock => const Color(0xff9E1B1B),
      ProductStatus.expired => const Color(0xff616161),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
