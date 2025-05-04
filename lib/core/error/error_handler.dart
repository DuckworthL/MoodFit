// lib/core/error/error_handler.dart - Centralized error handling

import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    // When Firebase is integrated, you can log to Firebase Crashlytics here
    debugPrint('ERROR: $message');
    debugPrint('$error');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }

  // Error catcher for async operations
  static Future<T> handleAsyncError<T>(
    Future<T> Function() operation,
    BuildContext context, {
    String errorMessage = 'An error occurred',
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError(errorMessage, e, stackTrace);
      if (showError) {
        showErrorSnackBar(context, '$errorMessage: ${e.toString()}');
      }
      rethrow;
    }
  }
}
