import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/cart_list.dart';

class CartContainer extends StatelessWidget {
  const CartContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find<PosController>();

    return Expanded(
      flex: 30,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _CartHeader(controller: controller),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Center(child: _HeaderText("المنتج"))),
                          Expanded(flex: 3, child: Center(child: _HeaderText("الكمية"))),
                          Expanded(flex: 2, child: Center(child: _HeaderText("الإجمالي"))),
                          Expanded(flex: 1, child: SizedBox()),
                        ],
                      ),
                    ),
                    const Expanded(child: CartList()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _TotalsCard(controller: controller),
            const SizedBox(height: 10),
            _CheckoutButton(controller: controller),
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
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.controller});
  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_cart_outlined, color: Color(0xff386641)),
            const SizedBox(width: 6),
            const Text(
              'سلة المشتريات',
              style: TextStyle(fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff386641),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.itemCount}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: controller.clearCart,
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          label: const Text('إفراغ السلة', style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.controller});
  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(
        () => Column(
          children: [
            _TotalRow(label: 'المجموع الفرعي', value: controller.subtotal),
            _TotalRow(label: 'الخصم', value: controller.discount),
            _TotalRow(label: 'الضريبة (15%)', value: controller.tax),
            const Divider(height: 16),
            _TotalRow(
              label: 'الإجمالي',
              value: controller.grandTotal,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.isBold = false});

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} ج.س',
            style: TextStyle(
              color: const Color(0xff386641),
              fontSize: isBold ? 17 : 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.controller});
  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEmpty = controller.cart.isEmpty;
      final success = controller.checkoutSuccess.value;
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: isEmpty
              ? null
              : () {
                  controller.checkout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت عملية البيع بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Color(0xff386641),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: success ? Colors.green : const Color(0xff386641),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: Icon(success ? Icons.check_circle : Icons.point_of_sale, color: Colors.white),
          label: Text(
            success ? 'تمت العملية بنجاح' : 'اتمام البيع',
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
        ),
      );
    });
  }
}
