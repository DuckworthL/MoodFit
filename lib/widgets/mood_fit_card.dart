import 'package:flutter/material.dart';
import 'package:moodfit/utils/design_system.dart';

class MoodFitCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isProminent;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const MoodFitCard({
    Key? key,
    required this.child,
    this.padding,
    this.isProminent = false,
    this.onTap,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: isProminent
            ? MoodFitDesignSystem.prominentCardDecoration(context)
            : MoodFitDesignSystem.cardDecoration(context),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
