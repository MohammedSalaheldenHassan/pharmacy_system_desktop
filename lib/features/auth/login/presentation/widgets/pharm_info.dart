import 'package:flutter/material.dart';

/// Branding block: pharmacy logo, name and a short tagline.
/// [compact] renders a smaller variant used on narrow screens.
class PharmInfo extends StatelessWidget {
  const PharmInfo({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final double logoSize = compact ? 64 : 92;
    final Color titleColor = light ? Colors.white : const Color(0xff1B4332);
    final Color subtitleColor = light ? Colors.white70 : Colors.grey.shade600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: light ? Colors.white.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: light
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xff0e4a35).withValues(alpha: 0.18),
                      offset: const Offset(0, 6),
                      blurRadius: 20,
                    ),
                  ],
          ),
          child: Icon(
            Icons.local_hospital_rounded,
            color: light ? Colors.white : const Color(0xff0e4a35),
            size: logoSize * 0.55,
          ),
        ),
        SizedBox(height: compact ? 12 : 18),
        Text(
          'صيدلـية الشفاء',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 20 : 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'نظام إدارة الصيدليات',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 13 : 15,
            fontFamily: 'Cairo',
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}
