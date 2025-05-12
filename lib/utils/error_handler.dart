import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void logError(String context, dynamic error) {
    // In production, you might want to send this to a logging service
    if (kDebugMode) {
      print('[$context] Error: $error');
    }
  }

  static Widget errorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red)),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
