import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/supplier_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/supplier_details_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/supplier_form_dialog.dart';

class Supplier extends StatelessWidget {
  const Supplier({super.key});

  @override
  Widget build(BuildContext context) {
    final SuppliersController controller = Get.find<SuppliersController>();

    return Obx(() {
      final suppliers = controller.filteredSuppliers;

      if (suppliers.isEmpty) {
        return const _EmptySuppliers();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _SupplierRow(supplier: suppliers[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: suppliers.length,
      );
    });
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow({required this.supplier});

  final SupplierModel supplier;

  void _showDetails() => Get.dialog(SupplierDetailsDialog(supplier: supplier));

  void _showEditDialog() => Get.dialog(SupplierFormDialog(existing: supplier));

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('حذف المورد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من حذف "${supplier.name}"؟ لا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Get.find<SuppliersController>().deleteSupplier(supplier.id);
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
                  Text(
                    supplier.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                  ),
                  Text(
                    supplier.contactPerson,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Center(child: Text(supplier.phone, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 2, child: Center(child: Text(supplier.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(flex: 2, child: Center(child: Text(supplier.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(
              flex: 1,
              child: Center(
                child: Obx(
                  () => Text(
                    '${Get.find<SuppliersController>().purchaseOrderCountFor(supplier.id)}',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ),
            ),
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

class _EmptySuppliers extends StatelessWidget {
  const _EmptySuppliers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا يوجد موردون مطابقون',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب تعديل كلمة البحث',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
