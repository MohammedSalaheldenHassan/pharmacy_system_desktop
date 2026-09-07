import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/receipt/receipt_preview_dialog.dart';

/// Collects the payment method and amount paid for the current cart, then
/// completes the sale and opens the receipt preview automatically.
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late String _paymentMethod;
  final PosController _controller = Get.find<PosController>();

  @override
  void initState() {
    super.initState();
    _paymentMethod = PosController.paymentMethods.first;
    _amountController = TextEditingController(text: _controller.grandTotal.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isCash => _paymentMethod == cashPaymentMethod;

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amountPaid = _isCash
        ? (double.tryParse(_amountController.text.trim()) ?? _controller.grandTotal)
        : _controller.grandTotal;

    final sale = await _controller.completeSale(
      paymentMethod: _paymentMethod,
      amountPaid: amountPaid,
    );

    Get.back();
    if (sale != null) {
      Get.dialog(ReceiptPreviewDialog(sale: sale));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'إتمام الدفع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 18),
                Obx(
                  () => _AmountRow(
                    label: 'الإجمالي المطلوب',
                    value: '${_controller.grandTotal.toStringAsFixed(2)} ج.س',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87),
                  decoration: _decoration('طريقة الدفع'),
                  items: PosController.paymentMethods
                      .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _paymentMethod = value;
                      if (!_isCash) {
                        _amountController.text = _controller.grandTotal.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  enabled: _isCash,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: _decoration('المبلغ المدفوع'),
                  validator: (value) {
                    if (!_isCash) return null;
                    final amount = double.tryParse((value ?? '').trim());
                    if (amount == null) return 'رقم غير صالح';
                    if (amount < _controller.grandTotal) return 'المبلغ أقل من الإجمالي';
                    return null;
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
                        onPressed: _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0e4a35),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'تأكيد الدفع',
                          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
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
    );
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
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo')),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Color(0xff0e4a35)),
          ),
        ],
      ),
    );
  }
}
