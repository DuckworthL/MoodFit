// lib/utils/design_system.dart - Centralized design system for MoodFit
import 'package:flutter/material.dart';

class MoodFitDesignSystem {
  // Spacing Constants
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Border Radius Constants
  static final BorderRadius radiusSmall = BorderRadius.circular(8.0);
  static final BorderRadius radiusMedium = BorderRadius.circular(16.0);
  static final BorderRadius radiusLarge = BorderRadius.circular(24.0);
  static final BorderRadius radiusExtraLarge = BorderRadius.circular(32.0);
  static final BorderRadius radiusFull = BorderRadius.circular(100.0);

  // Elevations
  static const double elevationNone = 0.0;
  static const double elevationXSmall = 1.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 16.0;

  // Typography Presets
  static TextStyle heading1(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge!.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          );

  static TextStyle heading2(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium!.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          );

  static TextStyle heading3(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          );

  static TextStyle subtitle1(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          );

  static TextStyle subtitle2(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          );

  static TextStyle body1(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 16,
          );

  static TextStyle body2(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 14,
          );

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            fontSize: 12,
          );

  // Only the parts that need fixing
  // Shadow Styles
  static List<BoxShadow> shadowSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> shadowMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> shadowLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.5)
            : Colors.black.withOpacity(0.12),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // Gradient Styles
  static LinearGradient primaryGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary,
        colorScheme.primary.withOpacity(0.8),
      ],
    );
  }

  static LinearGradient secondaryGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.secondary,
        colorScheme.secondary.withOpacity(0.8),
      ],
    );
  }

  // Card Styles
  static BoxDecoration cardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: radiusMedium,
      boxShadow: shadowSmall(context),
      border: isDark
          ? Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            )
          : null,
    );
  }

  static BoxDecoration prominentCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.primary.withOpacity(isDark ? 0.3 : 0.1),
          colorScheme.primary.withOpacity(isDark ? 0.2 : 0.05),
        ],
      ),
      borderRadius: radiusMedium,
      boxShadow: shadowMedium(context),
      border: Border.all(
        color: colorScheme.primary.withOpacity(isDark ? 0.4 : 0.2),
        width: 1,
      ),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.styleFrom(
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
      shape: RoundedRectangleBorder(borderRadius: radiusMedium),
      elevation: elevationSmall,
      textStyle: subtitle2(context),
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
      shape: RoundedRectangleBorder(borderRadius: radiusMedium),
      side: BorderSide(color: colorScheme.primary, width: 1.5),
      textStyle: subtitle2(context),
    );
  }

  static ButtonStyle textButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
      textStyle: subtitle2(context),
    );
  }

  // Input Decoration
  static InputDecoration inputDecoration(BuildContext context,
      {String? labelText,
      String? hintText,
      Widget? prefixIcon,
      Widget? suffixIcon}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing16),
      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: body1(context)
          .copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
      hintStyle: body1(context)
          .copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
    );
  }

  // Background Decorations
  static BoxDecoration backgroundDecoration(BuildContext context,
      {required String assetPath}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(assetPath),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          isDark
              ? Colors.black.withOpacity(0.75)
              : Colors.black.withOpacity(0.5),
          BlendMode.darken,
        ),
      ),
    );
  }

  static BoxDecoration gradientBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF1A1A1A),
                const Color(0xFF121212),
              ]
            : [
                Colors.white,
                const Color(0xFFF5F5F5),
              ],
      ),
    );
  }
}
