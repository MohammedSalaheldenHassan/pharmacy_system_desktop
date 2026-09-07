/// Snapshot of a single cart line at the moment the sale was completed.
/// A plain snapshot (not a live [CartItemModel]) so a printed/previewed
/// receipt never changes after the cart is cleared or reused.
class SaleItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const SaleItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * quantity;
}

/// A completed POS sale, generated from the real cart/checkout data at the
/// moment "Complete Sale" succeeds. Used to render the receipt.
class SaleModel {
  final String invoiceNumber;
  final DateTime dateTime;
  final String cashierName;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;
  final double amountPaid;

  const SaleModel({
    required this.invoiceNumber,
    required this.dateTime,
    required this.cashierName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
  });

  double get change => amountPaid - total;
}
