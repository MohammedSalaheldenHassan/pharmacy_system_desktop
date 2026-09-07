import 'package:pharmacy_system/data/models/settings_model.dart';

/// Languages the settings screen can offer. Only Arabic is wired up today;
/// the list stays open so another language can be added later without
/// restructuring the screen.
const List<String> availableLanguages = ['العربية'];

/// The app's default configuration, written once to `app_settings` the
/// first time it's opened. Not sample/mock business data — a fresh
/// install genuinely needs some starting tax rate, thresholds, etc. to
/// function, the same way it needs one starting admin account.
final SettingsModel defaultSettings = SettingsModel(
  pharmacyName: 'صيدلية الشفاء',
  address: 'الخرطوم، السودان',
  phone: '0912345678',
  taxRatePercent: 15,
  currency: 'SDG',
  lowStockThreshold: 20,
  expiryAlertLeadDays: 90,
  language: availableLanguages.first,
);
