import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/mock/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_status_badge.dart';

class ProductDetailsDialog extends StatelessWidget {
  const ProductDetailsDialog({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                  ),
                  ProductStatusBadge(status: product.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.genericName,
                style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13),
              ),
              const Divider(height: 28),
              _DetailRow(label: 'الفئة', value: product.category),
              _DetailRow(label: 'الباركود', value: product.barcode),
              _DetailRow(label: 'سعر البيع', value: '${product.sellingPrice.toStringAsFixed(2)} ج.س'),
              _DetailRow(label: 'الكمية بالمخزون', value: '${product.stock}'),
              _DetailRow(
                label: 'تاريخ انتهاء الصلاحية',
                value:
                    '${product.expiryDate.year}-${product.expiryDate.month.toString().padLeft(2, '0')}-${product.expiryDate.day.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13)),
        ],
      ),
    );
  }
}
