import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppFeedback {
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Procesando...',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message: message, backgroundColor: Colors.green);
  }

  static void showError(
    BuildContext context,
    Object error, {
    String fallbackMessage = 'Ocurrio un error. Intenta de nuevo.',
  }) {
    final normalized = _normalizeErrorMessage(error);
    _showSnackBar(
      context,
      message: normalized.isEmpty ? fallbackMessage : normalized,
      backgroundColor: Colors.redAccent,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
  }

  static String _normalizeErrorMessage(Object error) {
    if (error is AuthException) {
      return error.message;
    }

    var message = error.toString().trim();
    const prefixes = ['Exception: ', 'PostgrestException(message: '];

    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length);
      }
    }

    if (message.endsWith(')')) {
      message = message.substring(0, message.length - 1);
    }

    return message.trim();
  }
}
