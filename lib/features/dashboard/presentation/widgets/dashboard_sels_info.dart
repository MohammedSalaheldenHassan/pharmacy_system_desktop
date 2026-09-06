import 'package:flutter/material.dart';

class DashboardSelsInfo extends StatefulWidget {
  const DashboardSelsInfo({super.key});

  @override
  State<DashboardSelsInfo> createState() => _DashboardSelsInfoState();
}

class _DashboardSelsInfoState extends State<DashboardSelsInfo> {
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
        SizedBox(height: 20),
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
