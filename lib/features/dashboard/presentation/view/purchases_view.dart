import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/utils/arabic_plural.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/purchases_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/purchase_order.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/purchase_order_form_dialog.dart';

class PurchasesView extends StatelessWidget {
  const PurchasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final PurchasesController controller = Get.put(PurchasesController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "المشتريات",
                      style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Text(
                        formatArabicCount(
                          controller.orders.length,
                          zero: 'لا توجد أوامر شراء',
                          singular: 'أمر شراء واحد',
                          dual: 'أمرا شراء',
                          pluralFew: 'أوامر شراء',
                          pluralMany: 'أمر شراء',
                        ),
                        style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.dialog(const PurchaseOrderFormDialog()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add_shopping_cart_outlined, color: Colors.white),
                  label: const Text(
                    "أمر شراء جديد",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 800;
                final search = _SearchField(controller: controller);
                final filters = _Filters(controller: controller);
                if (isNarrow) {
                  return Column(children: [search, const SizedBox(height: 12), filters]);
                }
                return Row(children: [Expanded(child: search), const SizedBox(width: 16), filters]);
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
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 2, child: Center(child: _HeaderText("رقم الأمر"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("المورد"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("التاريخ"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("عدد الأصناف"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الإجمالي"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الحالة"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("إجراءات"))),
                          ],
                        ),
                      ),
                      const Expanded(child: PurchaseOrder()),
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
  final PurchasesController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        onChanged: controller.updateSearchQuery,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
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
            borderSide: const BorderSide(color: Color(0xff0e4a35)),
          ),
          hintText: "ابحث برقم الأمر أو اسم المورد",
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

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final PurchasesController controller;

  @override
  Widget build(BuildContext context) {
    final suppliers = Get.find<SuppliersController>().suppliers;
    final supplierOptions = <String, String>{
      PurchasesController.allSuppliersLabel: PurchasesController.allSuppliersLabel,
      for (final s in suppliers) s.id: s.name,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => _FilterDropdown(
            value: controller.selectedStatus.value,
            items: controller.statusOptions,
            onChanged: controller.selectStatus,
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedSupplierId.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87, fontSize: 13),
                items: supplierOptions.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.selectSupplier(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.value, required this.items, required this.onChanged});

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87, fontSize: 13),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }
}
