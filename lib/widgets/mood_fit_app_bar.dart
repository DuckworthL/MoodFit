import 'package:flutter/material.dart';
import 'package:moodfit/utils/design_system.dart';

class MoodFitAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Widget? leading;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const MoodFitAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.leading,
    this.elevation = 0,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: MoodFitDesignSystem.heading3(context).copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ??
          (isDark ? theme.colorScheme.surface : theme.colorScheme.background),
      leading: leading,
      actions: actions,
      elevation: elevation,
      bottom: bottom,
      iconTheme: IconThemeData(
        color: theme.colorScheme.primary,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null
      ? kToolbarHeight + bottom!.preferredSize.height
      : kToolbarHeight);
}
