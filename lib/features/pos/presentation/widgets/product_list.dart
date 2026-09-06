import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/mock/models/product_model.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find<PosController>();

    return Obx(() {
      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return const _EmptyProducts();
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 5),
        itemCount: products.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductRow(product: product, onAdd: () => controller.addToCart(product));
        },
      );
    });
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onAdd});

  final ProductModel product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Text(product.name, style: const TextStyle(fontFamily: 'Cairo')),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(product.concentration, style: const TextStyle(fontFamily: 'Cairo')),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text('${product.stock}', style: const TextStyle(fontFamily: 'Cairo')),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${product.price.toStringAsFixed(0)} ج.س',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Flexible(
            child: Center(
              child: Material(
                color: const Color(0xff386641),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onAdd,
                  child: const SizedBox(
                    width: 40,
                    height: 32,
                    child: Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'لا توجد منتجات مطابقة',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}
