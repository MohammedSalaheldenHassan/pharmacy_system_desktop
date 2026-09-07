import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/expiry_alerts_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/expiry_alert_item.dart';

const Color _brandColor = Color(0xff0e4a35);

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpiryAlertsController controller = Get.put(ExpiryAlertsController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "تنبيهات انتهاء الصلاحية",
              style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
            ),
            Obx(
              () => Text(
                'خلال ${controller.leadDays} يوم القادمة',
                style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 20),
            _SummaryRow(controller: controller),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 800;
                final search = _SearchField(controller: controller);
                final filter = _TierFilter(controller: controller);
                if (isNarrow) {
                  return Column(children: [search, const SizedBox(height: 12), filter]);
                }
                return Row(children: [Expanded(child: search), const SizedBox(width: 16), filter]);
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xffF3F6FB),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 3, child: Center(child: _HeaderText("المنتج"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الكمية"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("تاريخ الانتهاء"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("الحالة"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("إجراء"))),
                          ],
                        ),
                      ),
                      const Expanded(child: ExpiryAlertItem()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.controller});
  final ExpiryAlertsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.error_outline,
              label: 'منتجات منتهية الصلاحية',
              value: '${controller.expiredCount}',
              color: const Color(0xff9E1B1B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_outlined,
              label: 'تنتهي قريباً',
              value: '${controller.expiringSoonCount}',
              color: const Color(0xffB8860B),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final ExpiryAlertsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        onChanged: controller.updateSearchQuery,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _brandColor)),
          hintText: "ابحث عن منتج",
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _TierFilter extends StatelessWidget {
  const _TierFilter({required this.controller});
  final ExpiryAlertsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedTier.value,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
            style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87, fontSize: 13),
            items: controller.tierOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (value) {
              if (value != null) controller.selectTier(value);
            },
          ),
        ),
      ),
    );
  }
}
