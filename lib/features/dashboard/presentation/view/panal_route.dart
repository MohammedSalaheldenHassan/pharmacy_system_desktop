import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/view/login_view.dart';

class PanalRoute extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  const PanalRoute({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  State<PanalRoute> createState() => _PanalRouteState();
}

class _PanalRouteState extends State<PanalRoute> {
  static const List<Map<String, dynamic>> _menuItems = [
    {"title": "الرئيسية", "icon": Icons.home_outlined},
    {"title": "المنتجات", "icon": Icons.inventory_2_outlined},
    {"title": "المبيعات", "icon": Icons.bar_chart_rounded},
    {"title": "المخزون", "icon": Icons.assignment_outlined},
    {"title": "تنبيهات الصلاحية", "icon": Icons.notifications_none_rounded},
    {"title": "الموردين", "icon": Icons.local_shipping_outlined},
    {"title": "المشتريات", "icon": Icons.shopping_cart_outlined},
    {"title": "الأرباح والخسائر", "icon": Icons.trending_up_outlined},
    {"title": "الموظفين", "icon": Icons.badge_outlined},
    {"title": "التقارير", "icon": Icons.description_outlined},
    {"title": "الاعدادات", "icon": Icons.settings_outlined},

    // {'title': "الرئيسية", 'icon': "Icons.home_outlined"},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: Color(0xff072318),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 4.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 34,
                  color: Colors.white,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "صيدلية الشفاء",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "لوحة التحكم",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = widget.selectedIndex == index;
                return InkWell(
                  onTap: () => widget.onItemSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  hoverColor: Colors.white.withValues(alpha: 0.05),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xff0f3e2b)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item["icon"] as IconData,
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 4),
              itemCount: _menuItems.length,
            ),
          ),
          InkWell(
            onTap: () {
              Get.offAll(() => LoginView());
            },
            borderRadius: BorderRadius.circular(10),
            hoverColor: Colors.redAccent.withValues(alpha: 0.1),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                  SizedBox(width: 12),
                  Text(
                    "تسجيل الخروج",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
