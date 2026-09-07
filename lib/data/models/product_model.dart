// Canonical product model shared by every feature that needs product data
// (POS, Products management, ...). Keeping one model avoids each feature
// maintaining its own duplicated shape for the same real-world entity.

/// Derived product status, computed from stock and expiry rather than
/// stored separately, so there is a single source of truth.
enum ProductStatus { available, lowStock, outOfStock, expired }

extension ProductStatusLabel on ProductStatus {
  String get label {
    switch (this) {
      case ProductStatus.available:
        return 'متوفر';
      case ProductStatus.lowStock:
        return 'مخزون منخفض';
      case ProductStatus.outOfStock:
        return 'نفذ المخزون';
      case ProductStatus.expired:
        return 'منتهي الصلاحية';
    }
  }
}

/// Fallback used only where a Settings-aware threshold isn't available.
/// Everywhere reachable from a real screen should use [statusFor] with the
/// live `SettingsModel.lowStockThreshold` instead of this constant.
const int defaultLowStockThreshold = 20;

class ProductModel {
  final String id;
  final String name;
  final String genericName;
  final String concentration;
  final String category;
  final String barcode;
  final double sellingPrice;
  final int stock;
  final DateTime expiryDate;

  const ProductModel({
    required this.id,
    required this.name,
    this.genericName = '',
    this.concentration = '',
    required this.category,
    this.barcode = '',
    required this.sellingPrice,
    required this.stock,
    required this.expiryDate,
  });

  /// Alias kept for screens (e.g. POS) that refer to the selling price
  /// simply as "price".
  double get price => sellingPrice;

  /// Status computed against the real, Settings-configurable low-stock
  /// threshold. Every screen showing a live status should call this
  /// (typically via `ProductsController.lowStockThreshold`).
  ProductStatus statusFor(int lowStockThreshold) {
    if (expiryDate.isBefore(DateTime.now())) return ProductStatus.expired;
    if (stock <= 0) return ProductStatus.outOfStock;
    if (stock < lowStockThreshold) return ProductStatus.lowStock;
    return ProductStatus.available;
  }

  /// Convenience getter for contexts with no Settings access (falls back
  /// to [defaultLowStockThreshold]). Prefer [statusFor] where possible.
  ProductStatus get status => statusFor(defaultLowStockThreshold);

  ProductModel copyWith({
    String? name,
    String? genericName,
    String? concentration,
    String? category,
    String? barcode,
    double? sellingPrice,
    int? stock,
    DateTime? expiryDate,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      concentration: concentration ?? this.concentration,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
