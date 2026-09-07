// Canonical pharmacy settings model. A single instance represents the
// whole system configuration (financial, inventory, and general settings).

class SettingsModel {
  final String pharmacyName;
  final String address;
  final String phone;
  final double taxRatePercent;
  final String currency;
  final int lowStockThreshold;
  final int expiryAlertLeadDays;
  final String language;

  const SettingsModel({
    required this.pharmacyName,
    required this.address,
    required this.phone,
    required this.taxRatePercent,
    required this.currency,
    required this.lowStockThreshold,
    required this.expiryAlertLeadDays,
    required this.language,
  });

  SettingsModel copyWith({
    String? pharmacyName,
    String? address,
    String? phone,
    double? taxRatePercent,
    String? currency,
    int? lowStockThreshold,
    int? expiryAlertLeadDays,
    String? language,
  }) {
    return SettingsModel(
      pharmacyName: pharmacyName ?? this.pharmacyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      taxRatePercent: taxRatePercent ?? this.taxRatePercent,
      currency: currency ?? this.currency,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      expiryAlertLeadDays: expiryAlertLeadDays ?? this.expiryAlertLeadDays,
      language: language ?? this.language,
    );
  }
}
