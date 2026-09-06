import 'package:flutter/material.dart';

class DashboardTopBar extends StatefulWidget {
  const DashboardTopBar({super.key});

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 90,
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
        Expanded(
          child: Container(
            height: 90,
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
        Expanded(
          child: Container(
            height: 90,
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
