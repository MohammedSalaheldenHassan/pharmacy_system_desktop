import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/inventory_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/inventory_item.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/inventory_movement_list.dart';

const Color _brandColor = Color(0xff0e4a35);

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InventoryController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F6FB),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "المخزون",
                style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "متابعة الكميات الحالية وسجل حركات المخزون",
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: const TabBar(
                  labelColor: _brandColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: _brandColor,
                  labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                  unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
                  tabs: [
                    Tab(text: 'المخزون الحالي'),
                    Tab(text: 'سجل الحركات'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Expanded(
                child: TabBarView(
                  children: [
                    _StockTab(),
                    _MovementsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockTab extends StatelessWidget {
  const _StockTab();

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.find<InventoryController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 3, child: Center(child: _HeaderText("المنتج"))),
                        Expanded(flex: 1, child: Center(child: _HeaderText("الكمية"))),
                        Expanded(flex: 1, child: Center(child: _HeaderText("الحد الأدنى"))),
                        Expanded(flex: 2, child: Center(child: _HeaderText("الحالة"))),
                        Expanded(flex: 1, child: Center(child: _HeaderText("إجراء"))),
                      ],
                    ),
                  ),
                  const Expanded(child: InventoryItem()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MovementsTab extends StatelessWidget {
  const _MovementsTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  Expanded(flex: 1, child: Center(child: _HeaderText("التاريخ"))),
                  Expanded(flex: 2, child: Center(child: _HeaderText("المنتج"))),
                  Expanded(flex: 1, child: Center(child: _HeaderText("نوع الحركة"))),
                  Expanded(flex: 1, child: Center(child: _HeaderText("الكمية"))),
                  Expanded(flex: 1, child: Center(child: _HeaderText("المرجع"))),
                ],
              ),
            ),
            const Expanded(child: InventoryMovementList()),
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
  final InventoryController controller;

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

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final InventoryController controller;

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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
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
