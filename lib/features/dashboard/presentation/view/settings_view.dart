import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/constant/default_settings.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/settings_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/employees_view.dart';

const Color _brandColor = Color(0xff0e4a35);

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "الإعدادات",
              style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "إدارة بيانات الصيدلية والإعدادات المالية والمخزنية",
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            _PharmacyInfoCard(),
            SizedBox(height: 16),
            _FinancialSettingsCard(),
            SizedBox(height: 16),
            _InventorySettingsCard(),
            SizedBox(height: 16),
            _RolesShortcutCard(),
            SizedBox(height: 16),
            _BackupCard(),
            SizedBox(height: 16),
            _LanguageCard(),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _brandColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _brandColor),
    ),
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
        label: const Text('حفظ', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
      ),
    );
  }
}

void _showSavedSnackbar() {
  Get.snackbar(
    'تم الحفظ',
    'تم حفظ التغييرات بنجاح',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: _brandColor,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}

class _PharmacyInfoCard extends StatefulWidget {
  const _PharmacyInfoCard();

  @override
  State<_PharmacyInfoCard> createState() => _PharmacyInfoCardState();
}

class _PharmacyInfoCardState extends State<_PharmacyInfoCard> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final s = Get.find<SettingsController>().settings.value;
    _name = TextEditingController(text: s.pharmacyName);
    _address = TextEditingController(text: s.address);
    _phone = TextEditingController(text: s.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'بيانات الصيدلية',
      icon: Icons.local_hospital_outlined,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _brandColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_outlined, color: _brandColor),
            ),
            const SizedBox(width: 12),
            Text(
              'شعار الصيدلية (قريباً)',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _name,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: _fieldDecoration('اسم الصيدلية'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _address,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: _fieldDecoration('العنوان'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phone,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: _fieldDecoration('رقم الهاتف'),
        ),
        const SizedBox(height: 14),
        _SaveButton(
          onPressed: () {
            Get.find<SettingsController>().updatePharmacyInfo(
              name: _name.text.trim(),
              address: _address.text.trim(),
              phone: _phone.text.trim(),
            );
            _showSavedSnackbar();
          },
        ),
      ],
    );
  }
}

class _FinancialSettingsCard extends StatefulWidget {
  const _FinancialSettingsCard();

  @override
  State<_FinancialSettingsCard> createState() => _FinancialSettingsCardState();
}

class _FinancialSettingsCardState extends State<_FinancialSettingsCard> {
  late final TextEditingController _taxRate;
  late String _currency;

  @override
  void initState() {
    super.initState();
    final s = Get.find<SettingsController>().settings.value;
    _taxRate = TextEditingController(text: s.taxRatePercent.toString());
    _currency = s.currency;
  }

  @override
  void dispose() {
    _taxRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'الإعدادات المالية',
      icon: Icons.attach_money_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _taxRate,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: _fieldDecoration('نسبة الضريبة (%)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _currency,
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87),
                decoration: _fieldDecoration('العملة'),
                items: const [
                  DropdownMenuItem(value: 'SDG', child: Text('جنيه سوداني (SDG)')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _currency = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SaveButton(
          onPressed: () {
            final rate = double.tryParse(_taxRate.text.trim());
            if (rate == null) {
              Get.snackbar(
                'خطأ',
                'نسبة الضريبة غير صالحة',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
              return;
            }
            Get.find<SettingsController>().updateFinancialSettings(
              taxRatePercent: rate,
              currency: _currency,
            );
            _showSavedSnackbar();
          },
        ),
      ],
    );
  }
}

class _InventorySettingsCard extends StatefulWidget {
  const _InventorySettingsCard();

  @override
  State<_InventorySettingsCard> createState() => _InventorySettingsCardState();
}

class _InventorySettingsCardState extends State<_InventorySettingsCard> {
  late final TextEditingController _lowStock;
  late final TextEditingController _expiryDays;

  @override
  void initState() {
    super.initState();
    final s = Get.find<SettingsController>().settings.value;
    _lowStock = TextEditingController(text: s.lowStockThreshold.toString());
    _expiryDays = TextEditingController(text: s.expiryAlertLeadDays.toString());
  }

  @override
  void dispose() {
    _lowStock.dispose();
    _expiryDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'إعدادات المخزون',
      icon: Icons.inventory_2_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _lowStock,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: _fieldDecoration('الحد الأدنى للمخزون'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _expiryDays,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: _fieldDecoration('مدة تنبيه انتهاء الصلاحية (أيام)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SaveButton(
          onPressed: () {
            final threshold = int.tryParse(_lowStock.text.trim());
            final days = int.tryParse(_expiryDays.text.trim());
            if (threshold == null || days == null) {
              Get.snackbar(
                'خطأ',
                'القيم المدخلة غير صالحة',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
              return;
            }
            Get.find<SettingsController>().updateInventorySettings(
              lowStockThreshold: threshold,
              expiryAlertLeadDays: days,
            );
            _showSavedSnackbar();
          },
        ),
      ],
    );
  }
}

class _RolesShortcutCard extends StatelessWidget {
  const _RolesShortcutCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'المستخدمون والصلاحيات',
      icon: Icons.admin_panel_settings_outlined,
      children: [
        Text(
          'إدارة بيانات الموظفين وأدوارهم (مدير / كاشير) تتم من شاشة الموظفين.',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => Get.to(() => const EmployeesView()),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: _brandColor),
            ),
            icon: const Icon(Icons.people_outline, color: _brandColor, size: 18),
            label: const Text('الانتقال إلى إدارة الموظفين', style: TextStyle(color: _brandColor, fontFamily: 'Cairo')),
          ),
        ),
      ],
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'النسخ الاحتياطي',
      icon: Icons.backup_outlined,
      children: [
        Text(
          'هذا القسم واجهة فقط حالياً وسيتم ربطه بقاعدة بيانات حقيقية لاحقاً.',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                // TODO: wire to a real backup once the SQLite layer exists.
                onPressed: () => Get.snackbar(
                  'غير متاح بعد',
                  'سيتم تفعيل النسخ الاحتياطي عند ربط قاعدة البيانات',
                  backgroundColor: Colors.grey.shade800,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text('نسخ احتياطي', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                // TODO: wire to a real restore once the SQLite layer exists.
                onPressed: () => Get.snackbar(
                  'غير متاح بعد',
                  'سيتم تفعيل الاسترجاع عند ربط قاعدة البيانات',
                  backgroundColor: Colors.grey.shade800,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('استرجاع نسخة', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();
    return _SettingsCard(
      title: 'اللغة',
      icon: Icons.language_outlined,
      children: [
        Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.settings.value.language,
            style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87),
            decoration: _fieldDecoration('لغة الواجهة'),
            items: availableLanguages
                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: (value) {
              if (value != null) controller.updateLanguage(value);
            },
          ),
        ),
      ],
    );
  }
}
