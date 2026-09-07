// Canonical historical sale record used for reporting/analytics (Profit &
// Loss, Reports). Distinct from the POS feature's own SaleModel, which
// represents a single in-progress checkout/receipt — this is the
// already-completed, persisted sales ledger those screens read from.

class SaleRecordItem {
  /// Real foreign key into `products.id` (null only for historical/mock
  /// rows that predate this field).
  final String? productId;
  final String productName;
  final String category;
  final int quantity;
  final double unitPrice;
  final double costPrice;

  const SaleRecordItem({
    this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
  });

  double get revenue => quantity * unitPrice;
  double get cost => quantity * costPrice;
  double get profit => revenue - cost;
}

class SaleRecordModel {
  final String id;
  final DateTime date;
  final String cashierName;
  final List<SaleRecordItem> items;

  const SaleRecordModel({
    required this.id,
    required this.date,
    required this.cashierName,
    required this.items,
  });

  double get totalRevenue => items.fold(0.0, (sum, i) => sum + i.revenue);
  double get totalCost => items.fold(0.0, (sum, i) => sum + i.cost);
  double get totalProfit => items.fold(0.0, (sum, i) => sum + i.profit);
}
