import 'package:flutter/material.dart';

int _snackBarToken = 0;

void showTimedSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  final token = ++_snackBarToken;
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(message),
      action: actionLabel == null || onAction == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction),
    ),
  );

  Future<void>.delayed(const Duration(seconds: 2), () {
    if (token == _snackBarToken && messenger.mounted) {
      messenger.hideCurrentSnackBar();
    }
  });
}
