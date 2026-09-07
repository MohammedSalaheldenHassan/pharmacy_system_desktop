import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/purchases_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';

/// Dialog to create a new purchase order: pick a supplier, add line items
/// (product + quantity + cost price), and submit. The total is computed
/// automatically from the added items.
class PurchaseOrderFormDialog extends StatefulWidget {
  const PurchaseOrderFormDialog({super.key});

  @override
  State<PurchaseOrderFormDialog> createState() => _PurchaseOrderFormDialogState();
}

class _PurchaseOrderFormDialogState extends State<PurchaseOrderFormDialog> {
  final _lineFormKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costPriceController = TextEditingController();

  String? _supplierId;
  String? _selectedProductId;
  final List<PurchaseOrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    final suppliers = Get.find<SuppliersController>().suppliers;
    if (suppliers.isNotEmpty) _supplierId = suppliers.first.id;

    final products = Get.find<ProductsController>().products;
    if (products.isNotEmpty) _selectedProductId = products.first.id;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  double get _total => _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  void _addLine() {
    if (!(_lineFormKey.currentState?.validate() ?? false)) return;
    final quantity = int.tryParse(_quantityController.text.trim());
    final costPrice = double.tryParse(_costPriceController.text.trim());
    if (quantity == null || costPrice == null || _selectedProductId == null) return;

    final product = Get.find<ProductsController>().products.firstWhereOrNull((p) => p.id == _selectedProductId);
    if (product == null) return;

    setState(() {
      _items.add(
        PurchaseOrderItem(
          productId: product.id,
          productName: product.name,
          quantity: quantity,
          costPrice: costPrice,
        ),
      );
      _quantityController.clear();
      _costPriceController.clear();
    });
  }

  void _removeLine(int index) => setState(() => _items.removeAt(index));

  void _submit() {
    if (_supplierId == null || _items.isEmpty) return;
    Get.find<PurchasesController>().createOrder(supplierId: _supplierId!, items: _items);
    Get.back();
  }

  InputDecoration _decoration(String label) {
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
        borderSide: const BorderSide(color: Color(0xff0e4a35)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = Get.find<SuppliersController>().suppliers;
    final products = Get.find<ProductsController>().products;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إنشاء أمر شراء جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _supplierId,
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87),
                decoration: _decoration('المورد'),
                items: suppliers
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => setState(() => _supplierId = value),
              ),
              const SizedBox(height: 16),
              Text(
                'إضافة صنف',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Form(
                key: _lineFormKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedProductId,
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87, fontSize: 13),
                        decoration: _decoration('المنتج'),
                        items: products
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedProductId = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Cairo'),
                        decoration: _decoration('الكمية'),
                        validator: (v) => int.tryParse((v ?? '').trim()) == null ? 'غير صالح' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontFamily: 'Cairo'),
                        decoration: _decoration('سعر التكلفة'),
                        validator: (v) => double.tryParse((v ?? '').trim()) == null ? 'غير صالح' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addLine,
                      style: IconButton.styleFrom(backgroundColor: const Color(0xff0e4a35)),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_items.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13))),
                            Expanded(child: Text('${item.quantity}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13))),
                            Expanded(
                              child: Text(
                                '${item.lineTotal.toStringAsFixed(2)} ج.س',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeLine(index),
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي', style: TextStyle(fontFamily: 'Cairo')),
                    Text(
                      '${_total.toStringAsFixed(2)} ج.س',
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xff0e4a35)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _items.isEmpty || _supplierId == null ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0e4a35),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('إنشاء الأمر', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
