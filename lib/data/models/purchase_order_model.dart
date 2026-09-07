// Canonical purchase order model, linking back to a supplier by id (the
// same relational shape the future SQLite schema will use).

enum PurchaseOrderStatus { pending, received, cancelled }

extension PurchaseOrderStatusLabel on PurchaseOrderStatus {
  String get label {
    switch (this) {
      case PurchaseOrderStatus.pending:
        return 'قيد الانتظار';
      case PurchaseOrderStatus.received:
        return 'تم الاستلام';
      case PurchaseOrderStatus.cancelled:
        return 'ملغي';
    }
  }
}

class PurchaseOrderItem {
  /// Real foreign key into `products.id`, set whenever the line was added
  /// from a known product (i.e. every line added through the UI). Null is
  /// only possible for historical/mock rows that predate this field.
  final String? productId;
  final String productName;
  final int quantity;
  final double costPrice;

  const PurchaseOrderItem({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.costPrice,
  });

  double get lineTotal => quantity * costPrice;
}

class PurchaseOrderModel {
  final String id;
  final String supplierId;
  final DateTime date;
  final List<PurchaseOrderItem> items;
  final PurchaseOrderStatus status;

  const PurchaseOrderModel({
    required this.id,
    required this.supplierId,
    required this.date,
    required this.items,
    this.status = PurchaseOrderStatus.pending,
  });

  double get total => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  int get itemCount => items.length;

  PurchaseOrderModel copyWith({PurchaseOrderStatus? status}) {
    return PurchaseOrderModel(
      id: id,
      supplierId: supplierId,
      date: date,
      items: items,
      status: status ?? this.status,
    );
  }
}
