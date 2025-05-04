// lib/config/theme.dart - Theme configuration for the app

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// App colors
const primaryColor = Color(0xFF4A90E2);
const accentColor = Color(0xFF50C878);
const backgroundColor = Color(0xFFF5F7FA);
const textColor = Color(0xFF2C3E50);
const errorColor = Color(0xFFE74C3C);

// App theme
final appTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    secondary: accentColor,
    background: backgroundColor,
    error: errorColor,
  ),
  scaffoldBackgroundColor: backgroundColor,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    bodyLarge: TextStyle(fontSize: 16.0, color: textColor),
    bodyMedium: TextStyle(fontSize: 14.0, color: textColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: primaryColor, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: errorColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 14.0,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
);

// Mood specific color mapping
final moodColors = {
  'energetic': const Color(0xFFFF5733),
  'happy': const Color(0xFFFFC300),
  'calm': const Color(0xFF4CAF50),
  'tired': const Color(0xFF9E9E9E),
  'stressed': const Color(0xFFF44336),
  'focused': const Color(0xFF2196F3),
};
