import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/inventory_controller.dart';

/// Manual stock correction dialog. A reason is required so every
/// adjustment is auditable in the movement log.
class StockAdjustmentDialog extends StatefulWidget {
  const StockAdjustmentDialog({super.key, required this.product});

  final ProductModel product;

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  AdjustmentReason _reason = AdjustmentReason.stockCount;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '${widget.product.stock}');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final newQuantity = int.parse(_quantityController.text.trim());
    Get.find<InventoryController>().adjustStock(
      product: widget.product,
      newQuantity: newQuantity,
      reason: _reason,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تعديل رصيد المخزون',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الكمية الحالية', style: TextStyle(fontFamily: 'Cairo')),
                      Text('${widget.product.stock}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: InputDecoration(
                    labelText: 'الكمية الجديدة',
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
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 0) return 'كمية غير صالحة';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<AdjustmentReason>(
                  initialValue: _reason,
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'سبب التعديل',
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
                  ),
                  items: AdjustmentReason.values
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _reason = value);
                  },
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
                        child: const Text('حفظ التعديل', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
