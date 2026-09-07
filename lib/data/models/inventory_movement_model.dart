// Canonical stock-movement model, mirroring the shape of the future
// `inventory_movements` table: every change to a product's stock (sale,
// purchase, or manual adjustment) is one row.

enum MovementType { sale, purchase, adjustment }

extension MovementTypeLabel on MovementType {
  String get label {
    switch (this) {
      case MovementType.sale:
        return 'بيع';
      case MovementType.purchase:
        return 'شراء';
      case MovementType.adjustment:
        return 'تسوية';
    }
  }
}

/// Reason required when a stock quantity is manually adjusted.
enum AdjustmentReason { damage, stockCount, returnItem }

extension AdjustmentReasonLabel on AdjustmentReason {
  String get label {
    switch (this) {
      case AdjustmentReason.damage:
        return 'تلف';
      case AdjustmentReason.stockCount:
        return 'جرد مخزون';
      case AdjustmentReason.returnItem:
        return 'إرجاع';
    }
  }
}

class InventoryMovementModel {
  final String id;
  final DateTime date;
  /// Real foreign key into `products.id` (null only for historical/mock
  /// rows that predate this field).
  final String? productId;
  final String productName;
  final MovementType type;
  /// Positive when stock increases (purchase, positive adjustment),
  /// negative when it decreases (sale, negative adjustment).
  final int quantity;
  final String reference;

  const InventoryMovementModel({
    required this.id,
    required this.date,
    this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.reference,
  });
}
