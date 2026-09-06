import 'package:flutter/material.dart';

class DashboardProductInfo extends StatefulWidget {
  const DashboardProductInfo({super.key});

  @override
  State<DashboardProductInfo> createState() => _DashboardProductInfoState();
}

class _DashboardProductInfoState extends State<DashboardProductInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  color: Colors.black12,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  color: Colors.black12,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  color: Colors.black12,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
