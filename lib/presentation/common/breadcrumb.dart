// lib/presentation/common/breadcrumb.dart
import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.isActive = false,
  });
}

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final double fontSize;
  final double spacing;
  final double dividerSize;
  final Color activeColor;
  final Color inactiveColor;

  const Breadcrumb({
    super.key,
    required this.items,
    this.fontSize = 14,
    this.spacing = 4,
    this.dividerSize = 16,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length * 2 - 1, (index) {
          // Divider
          if (index.isOdd) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Icon(
                Icons.chevron_right,
                size: dividerSize,
                color: inactiveColor,
              ),
            );
          }

          // Item
          final itemIndex = index ~/ 2;
          final item = items[itemIndex];
          final isLastItem = itemIndex == items.length - 1;

          return InkWell(
            onTap: item.onTap,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: item.isActive ? FontWeight.bold : FontWeight.normal,
                color:
                    item.isActive || isLastItem ? activeColor : inactiveColor,
              ),
            ),
          );
        }),
      ),
    );
  }
}
