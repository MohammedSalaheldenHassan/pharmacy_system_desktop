import 'package:flutter/material.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/dashboard_product_info.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/dashboard_sels_info.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/dashboard_top_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 50,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200],
            ),
            child: Icon(Icons.menu),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_outlined),
              ),
              Positioned(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "1",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(Icons.person_2_outlined),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("محمد صلاح", style: TextStyle(fontFamily: 'Cairo')),
                    SizedBox(height: 2.5),
                    Text("مديرالنظام", style: TextStyle(fontFamily: 'Cairo')),
                  ],
                ),
              ],
            ),
          ),
        ],
        elevation: 0,
        shadowColor: Colors.black12,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardTopBar(),
              SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 60, child: DashboardSelsInfo()),
                    SizedBox(width: 20),
                    Expanded(flex: 40, child: DashboardProductInfo()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
