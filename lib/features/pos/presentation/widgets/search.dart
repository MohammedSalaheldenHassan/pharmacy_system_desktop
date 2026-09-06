import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find<PosController>();
    return SizedBox(
      height: 44,
      child: TextFormField(
        onChanged: controller.updateSearchQuery,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xff386641)),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'ابحث باسم المنتج او التركيز',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
