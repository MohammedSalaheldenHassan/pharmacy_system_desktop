import 'package:flutter/material.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/alerts_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/employees_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/inventory_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/panal_route.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/products_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/profits_loss_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/purchases_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/reports_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/sels_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/settings_view.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/suppliers_view.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    DashboardView(),
    ProductsView(),
    SelsView(),
    InventoryView(),
    AlertsView(),
    SuppliersView(),
    PurchasesView(),
    ProfitsLossView(),
    EmployeesView(),
    ReportsView(),
    SettingsView()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8fafc),
      body: Row(
        children: [
          PanalRoute(
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedIndex: _currentIndex,
          ),
          Expanded(child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ))
        ],
      ),
    );
  }
}
