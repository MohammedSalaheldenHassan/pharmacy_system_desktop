import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';

/// Shared dialog for both adding a new product and editing an existing one.
/// Pass [existing] to pre-fill the fields in edit mode.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.existing});

  final ProductModel? existing;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _genericName;
  late final TextEditingController _category;
  late final TextEditingController _barcode;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late DateTime _expiryDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _genericName = TextEditingController(text: p?.genericName ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _price = TextEditingController(text: p != null ? p.sellingPrice.toString() : '');
    _stock = TextEditingController(text: p != null ? p.stock.toString() : '');
    _expiryDate = p?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _name.dispose();
    _genericName.dispose();
    _category.dispose();
    _barcode.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = Get.find<ProductsController>();
    final sellingPrice = double.tryParse(_price.text.trim()) ?? 0;
    final stock = int.tryParse(_stock.text.trim()) ?? 0;

    if (_isEditing) {
      controller.updateProduct(
        widget.existing!.copyWith(
          name: _name.text.trim(),
          genericName: _genericName.text.trim(),
          category: _category.text.trim(),
          barcode: _barcode.text.trim(),
          sellingPrice: sellingPrice,
          stock: stock,
          expiryDate: _expiryDate,
        ),
      );
    } else {
      controller.addProduct(
        name: _name.text.trim(),
        genericName: _genericName.text.trim(),
        category: _category.text.trim(),
        barcode: _barcode.text.trim(),
        sellingPrice: sellingPrice,
        stock: stock,
        expiryDate: _expiryDate,
      );
    }
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('اسم المنتج'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _genericName,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('الاسم العلمي'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _category,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: _required,
                          decoration: _decoration('الفئة'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _barcode,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: _required,
                          decoration: _decoration('الباركود'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _price,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (_required(v) != null) return _required(v);
                            return double.tryParse(v!.trim()) == null ? 'رقم غير صالح' : null;
                          },
                          decoration: _decoration('سعر البيع'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stock,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (_required(v) != null) return _required(v);
                            return int.tryParse(v!.trim()) == null ? 'رقم غير صالح' : null;
                          },
                          decoration: _decoration('الكمية'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickExpiryDate,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: _decoration('تاريخ انتهاء الصلاحية'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
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
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0e4a35),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            _isEditing ? 'حفظ التعديلات' : 'إضافة',
                            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
