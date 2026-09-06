import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/mock/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_details_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_form_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_status_badge.dart';

class Product extends StatelessWidget {
  const Product({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find<ProductsController>();

    return Obx(() {
      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return const _EmptyProducts();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _ProductRow(product: products[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: products.length,
      );
    });
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final ProductModel product;

  String get _formattedExpiry =>
      '${product.expiryDate.year}-${product.expiryDate.month.toString().padLeft(2, '0')}-${product.expiryDate.day.toString().padLeft(2, '0')}';

  void _showDetails() => Get.dialog(ProductDetailsDialog(product: product));

  void _showEditDialog() => Get.dialog(ProductFormDialog(existing: product));

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('حذف المنتج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من حذف "${product.name}"؟ لا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Get.find<ProductsController>().deleteProduct(product.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDetails,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                  Text(
                    product.genericName,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Center(child: Text(product.category, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 2, child: Center(child: Text(product.barcode, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 1, child: Center(child: Text(_formattedExpiry, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 1, child: Center(child: Text('${product.stock}', style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${product.sellingPrice.toStringAsFixed(2)} ج.س',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(flex: 1, child: Center(child: ProductStatusBadge(status: product.status))),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit_outlined, color: Color(0xff0e4a35), size: 20),
                  ),
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          Icon(Icons.inventory_2_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا توجد منتجات مطابقة',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب تعديل كلمة البحث أو الفلاتر',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
