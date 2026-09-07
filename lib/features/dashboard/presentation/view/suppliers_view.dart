import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/utils/arabic_plural.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/supplier.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/supplier_form_dialog.dart';

class SuppliersView extends StatelessWidget {
  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final SuppliersController controller = Get.put(SuppliersController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "الموردون",
                      style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Text(
                        formatArabicCount(
                          controller.suppliers.length,
                          zero: 'لا يوجد موردون',
                          singular: 'مورد واحد',
                          dual: 'موردان',
                          pluralFew: 'موردون',
                          pluralMany: 'مورد',
                        ),
                        style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.dialog(const SupplierFormDialog()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add_business_outlined, color: Colors.white),
                  label: const Text(
                    "إضافة مورد",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: TextFormField(
                onChanged: controller.updateSearchQuery,
                style: const TextStyle(fontFamily: 'Cairo'),
                decoration: InputDecoration(
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
                  hintText: "ابحث عن مورد (الاسم، المسؤول، الهاتف، البريد)",
                  hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xffF3F6FB),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 2, child: Center(child: _HeaderText("المورد"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الهاتف"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("البريد الإلكتروني"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("العنوان"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("أوامر الشراء"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("إجراءات"))),
                          ],
                        ),
                      ),
                      const Expanded(child: Supplier()),
                    ],
                  ),
                ),
              ),
            ),
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
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13),
    );
  }
}
