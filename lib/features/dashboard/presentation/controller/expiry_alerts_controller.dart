import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/settings_controller.dart';

enum ExpiryTier { expired, expiringSoon }

/// Reads product/expiry data from the existing [ProductsController] (no
/// duplicated product list) and the alert window from [SettingsController]
/// (falls back to 90 days if Settings hasn't been visited yet), so
/// changing the setting immediately changes what shows up here.
class ExpiryAlertsController extends GetxController {
  static const String allTiersLabel = 'الكل';

  final RxString searchQuery = ''.obs;
  final RxString selectedTier = allTiersLabel.obs;

  /// Products the cashier/manager dismissed ("marked as seen"). Kept as
  /// local UI state only, as the spec asks — not persisted anywhere yet.
  final RxSet<String> dismissedProductIds = <String>{}.obs;

  ProductsController get _products => Get.isRegistered<ProductsController>()
      ? Get.find<ProductsController>()
      : Get.put(ProductsController());

  /// Settings is built after Expiry Alerts in the sidebar's IndexedStack,
  /// so it may not be registered yet on first use — force-create it (like
  /// [_products] above) so `.value` is always read here and future Settings
  /// changes stay reactive instead of silently falling back forever.
  SettingsController get _settings => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  int get leadDays => _settings.settings.value.expiryAlertLeadDays;

  int daysRemaining(ProductModel product) =>
      product.expiryDate.difference(DateTime.now()).inDays;

  ExpiryTier tierOf(ProductModel product) =>
      daysRemaining(product) < 0 ? ExpiryTier.expired : ExpiryTier.expiringSoon;

  List<String> get tierOptions => [allTiersLabel, 'منتهية الصلاحية', 'تنتهي قريباً'];

  List<ProductModel> get _withinWindow {
    return _products.products.where((p) {
      if (dismissedProductIds.contains(p.id)) return false;
      return daysRemaining(p) <= leadDays;
    }).toList();
  }

  List<ProductModel> get alerts {
    final query = searchQuery.value.trim();
    return _withinWindow.where((product) {
      final matchesSearch = query.isEmpty || product.name.contains(query);
      final matchesTier = switch (selectedTier.value) {
        'منتهية الصلاحية' => tierOf(product) == ExpiryTier.expired,
        'تنتهي قريباً' => tierOf(product) == ExpiryTier.expiringSoon,
        _ => true,
      };
      return matchesSearch && matchesTier;
    }).toList()
      ..sort((a, b) => daysRemaining(a).compareTo(daysRemaining(b)));
  }

  int get expiredCount =>
      _withinWindow.where((p) => tierOf(p) == ExpiryTier.expired).length;

  int get expiringSoonCount =>
      _withinWindow.where((p) => tierOf(p) == ExpiryTier.expiringSoon).length;

  void updateSearchQuery(String value) => searchQuery.value = value;

  void selectTier(String tier) => selectedTier.value = tier;

  void dismiss(String productId) => dismissedProductIds.add(productId);
}
