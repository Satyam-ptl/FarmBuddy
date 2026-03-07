import 'package:flutter/material.dart';

import 'auth_service.dart';
import '../screens/login_screen.dart';

class AuthUiService {
  static bool isUnauthorizedError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('401') ||
        message.contains('unauthorized') ||
        message.contains('forbidden');
  }

  static Future<void> forceLogout(
    BuildContext context, {
    String? message,
  }) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    await AuthService.logout();
    if (!context.mounted) return;

    if (message != null && message.isNotEmpty) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  static Future<bool> handleAuthError(
    BuildContext context,
    Object error, {
    String? message,
  }) async {
    if (!isUnauthorizedError(error)) return false;
    await forceLogout(
      context,
      message: message ?? 'Session expired. Please sign in again.',
    );
    return true;
  }

  static Future<void> confirmAndLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();
    if (!context.mounted) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
