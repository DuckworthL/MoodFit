// lib/core/utils/helpers.dart - Helper utilities

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format DateTime to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format DateTime to time string
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  // Format DateTime to date and time string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - h:mm a').format(dateTime);
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get workout intensity level from string
  static String getIntensityText(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return 'Low Intensity';
      case 'medium':
        return 'Medium Intensity';
      case 'high':
        return 'High Intensity';
      default:
        return 'Medium Intensity';
    }
  }

  // Get color for workout intensity
  static Color getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Calculate estimated calories burned (very simple estimation)
  static int calculateCaloriesBurned(int durationMinutes, String intensity) {
    // Rough calorie burn approximations based on intensity
    final multiplier =
        intensity.toLowerCase() == 'high'
            ? 10
            : intensity.toLowerCase() == 'medium'
            ? 7
            : 4;

    return durationMinutes * multiplier;
  }

  // Generate a unique ID (simple implementation)
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
