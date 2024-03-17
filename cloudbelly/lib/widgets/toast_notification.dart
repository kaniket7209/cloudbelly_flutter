import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class TOastNotification {
  ToastificationItem showSuccesToast(BuildContext context, String text) {
    return toastification.show(
      backgroundColor: Colors.green,
      context: context,
      title: Text(text),
      foregroundColor: Colors.white,
      primaryColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  ToastificationItem showErrorToast(BuildContext context, String text) {
    return toastification.show(
      backgroundColor: Colors.red,
      context: context,
      title: Text(text),
      foregroundColor: Colors.white,
      primaryColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
