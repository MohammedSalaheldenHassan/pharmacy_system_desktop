import 'package:flutter/material.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';

class PurchaseStatusBadge extends StatelessWidget {
  const PurchaseStatusBadge({super.key, required this.status});

  final PurchaseOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      PurchaseOrderStatus.pending => const Color(0xffB8860B),
      PurchaseOrderStatus.received => const Color(0xff2E7D32),
      PurchaseOrderStatus.cancelled => const Color(0xff9E1B1B),
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
      ),
    );
  }
}
