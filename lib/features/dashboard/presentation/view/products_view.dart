import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_form_dialog.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.put(ProductsController());

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
                      "المنتجـــــات",
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Text(
                        '${controller.products.length} منتج',
                        style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.dialog(const ProductFormDialog()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "إضافة منتج",
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
                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 16),
                    filters,
                  ],
                );
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
                            Expanded(flex: 2, child: Center(child: _HeaderText("اسم المنتج"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("الفئة"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("الباركود"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("انتهاء الصلاحية"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الكمية"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("سعر البيع"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الحالة"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("إجراءات"))),
                          ],
                        ),
                      ),
                      const Expanded(child: Product()),
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
  final ProductsController controller;

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
          hintText: "ابحث عن المنتج (الاسم، الاسم العلمي، الباركود)",
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
  final ProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => _FilterDropdown(
            value: controller.selectedCategory.value,
            items: controller.categories,
            onChanged: controller.selectCategory,
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => _FilterDropdown(
            value: controller.selectedStatus.value,
            items: controller.statusOptions,
            onChanged: controller.selectStatus,
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
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }
}
