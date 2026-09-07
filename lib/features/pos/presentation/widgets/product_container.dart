import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/product_list.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/search.dart';

class ProductContainer extends StatelessWidget {
  const ProductContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 70,
      child: Column(
        children: [
          const Search(),
          const SizedBox(height: 10),
          const _CategoryFilter(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(child: _HeaderText("اسم المنتج")),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: _HeaderText("التركيز")),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: _HeaderText("الكمية المتوفرة")),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: _HeaderText("السعر")),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(child: _HeaderText("إضافة")),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: ProductList()),
                ],
              ),
            ),
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
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter();

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find<PosController>();

    final categories = controller.categories;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => controller.selectCategory(category),
              selectedColor: const Color(0xff0e4a35),
              backgroundColor: Colors.white,
              side: BorderSide(color: isSelected ? const Color(0xff0e4a35) : Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          });
        },
      ),
    );
  }
}
