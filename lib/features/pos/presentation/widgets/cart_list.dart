import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/pos/data/cart_item_model.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';

class CartList extends StatelessWidget {
  const CartList({super.key});

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find<PosController>();

    return Obx(() {
      if (controller.cart.isEmpty) {
        return const _EmptyCart();
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: controller.cart.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final item = controller.cart[index];
          return _CartRow(
            item: item,
            onIncrease: () => controller.increaseQuantity(item),
            onDecrease: () => controller.decreaseQuantity(item),
            onRemove: () => controller.removeFromCart(item),
          );
        },
      );
    });
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.product.price.toStringAsFixed(0)} ج.س',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QtyButton(icon: Icons.remove, onTap: onDecrease),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                  ),
                ),
                _QtyButton(icon: Icons.add, onTap: onIncrease),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.total.toStringAsFixed(0)} ج.س',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Color(0xff0e4a35)),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(icon, size: 14, color: const Color(0xff0e4a35)),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'السلة فارغة',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'أضف منتجات لبدء عملية البيع',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
