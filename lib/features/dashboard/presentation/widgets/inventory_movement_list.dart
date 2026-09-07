import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/inventory_controller.dart';

/// Stock-movement log: every sale, purchase, and manual adjustment,
/// mirroring the shape of the future `inventory_movements` table.
class InventoryMovementList extends StatelessWidget {
  const InventoryMovementList({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.find<InventoryController>();

    return Obx(() {
      final movements = controller.movements;

      if (movements.isEmpty) {
        return const _EmptyMovements();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _MovementRow(movement: movements[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: movements.length,
      );
    });
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final InventoryMovementModel movement;

  String get _formattedDate =>
      '${movement.date.year}-${movement.date.month.toString().padLeft(2, '0')}-${movement.date.day.toString().padLeft(2, '0')}';

  Color get _typeColor => switch (movement.type) {
        MovementType.sale => const Color(0xff9E1B1B),
        MovementType.purchase => const Color(0xff2E7D32),
        MovementType.adjustment => const Color(0xff1565C0),
      };

  @override
  Widget build(BuildContext context) {
    final sign = movement.quantity > 0 ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: Center(child: Text(_formattedDate, style: const TextStyle(fontFamily: 'Cairo')))),
          Expanded(flex: 2, child: Center(child: Text(movement.productName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)))),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  movement.type.label,
                  style: TextStyle(color: _typeColor, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '$sign${movement.quantity}',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: _typeColor),
              ),
            ),
          ),
          Expanded(flex: 1, child: Center(child: Text(movement.reference, style: const TextStyle(fontFamily: 'Cairo')))),
        ],
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا توجد حركات مخزون بعد',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
