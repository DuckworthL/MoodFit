import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  // Add semantic labels to icons
  static Widget labeledIcon(IconData icon, String label,
      {Color? color, double? size}) {
    return Semantics(
      label: label,
      child: Icon(
        icon,
        color: color,
        size: size,
        semanticLabel: label,
      ),
    );
  }

  // Make buttons more accessible
  static Widget accessibleButton({
    required VoidCallback onPressed,
    required Widget child,
    String? semanticLabel,
    ButtonStyle? style,
    bool isToggled = false,
  }) {
    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel,
      toggled: isToggled,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }

  // Add large tap targets for buttons
  static Widget largeTapTarget({
    required Widget child,
    required VoidCallback onTap,
    String? semanticLabel,
    double minSize = 48.0, // Recommended by WCAG
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  // Helper to get high contrast colors
  static Color getAccessibleTextColor(Color backgroundColor) {
    // Calculate relative luminance
    double luminance = backgroundColor.computeLuminance();
    // Use white text on dark backgrounds, black text on light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Create accessible text with proper contrast
  static Widget accessibleText(
    String text, {
    TextStyle? style,
    Color? backgroundColor,
    TextAlign? textAlign,
  }) {
    if (backgroundColor != null) {
      final Color textColor = getAccessibleTextColor(backgroundColor);
      final TextStyle newStyle = (style ?? const TextStyle()).copyWith(
        color: textColor,
      );

      return Text(
        text,
        style: newStyle,
        textAlign: textAlign,
      );
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }

  // Add screen reader announcement
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
}
