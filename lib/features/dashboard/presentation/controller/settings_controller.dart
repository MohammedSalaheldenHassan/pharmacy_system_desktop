import 'package:get/get.dart';
import 'package:pharmacy_system/core/constant/default_settings.dart';
import 'package:pharmacy_system/data/models/settings_model.dart';
import 'package:pharmacy_system/data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  final SettingsRepository _repository = Get.find<SettingsRepository>();

  /// Starts with the old mock defaults so every screen reading Settings
  /// synchronously (many self-heal it during their own first build) has a
  /// sensible value immediately; overwritten once the real row loads.
  final Rx<SettingsModel> settings = defaultSettings.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final stored = await _repository.get();
    if (stored == null) {
      await _repository.save(defaultSettings);
    } else {
      settings.value = stored;
    }
  }

  void updatePharmacyInfo({
    required String name,
    required String address,
    required String phone,
  }) {
    settings.value = settings.value.copyWith(
      pharmacyName: name,
      address: address,
      phone: phone,
    );
    _repository.save(settings.value);
  }

  void updateFinancialSettings({
    required double taxRatePercent,
    required String currency,
  }) {
    settings.value = settings.value.copyWith(
      taxRatePercent: taxRatePercent,
      currency: currency,
    );
    _repository.save(settings.value);
  }

  void updateInventorySettings({
    required int lowStockThreshold,
    required int expiryAlertLeadDays,
  }) {
    settings.value = settings.value.copyWith(
      lowStockThreshold: lowStockThreshold,
      expiryAlertLeadDays: expiryAlertLeadDays,
    );
    _repository.save(settings.value);
  }

  void updateLanguage(String language) {
    settings.value = settings.value.copyWith(language: language);
    _repository.save(settings.value);
  }
}
