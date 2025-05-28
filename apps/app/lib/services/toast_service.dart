import 'package:app_logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:frappify/services/app_global_context.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static final Set<String> _activeToasts = {};

  static void _safeShowToast({
    required BuildContext? context,
    required void Function(BuildContext ctx) showFunction,
    required String message,
  }) {
    // Check if this message is already being shown
    if (_activeToasts.contains(message)) {
      return;
    }

    final ctx = context ?? AppGlobalContext.context;
    if (ctx != null) {
      try {
        _activeToasts.add(message);
        // Schedule the toast to be shown after the current frame is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showFunction(ctx);
          // Remove the message from active toasts after the duration
          Future.delayed(const Duration(seconds: 3), () {
            _activeToasts.remove(message);
          });
        });
      } catch (e, s) {
        AppLogger.reportError(e, s, 'ToastService._safeShowToast');
        _activeToasts.remove(message);
      }
    }
  }

  static void showToast({
    required String message,
    required Color color,
    BuildContext? context,
    Color? backgroundColor,
    Color? textColor,
    ToastificationType type = ToastificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 5,
          ),
          title: Text(
            message,
            style: const TextStyle(fontSize: 12),
          ),
          primaryColor: color,
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: true,
          showIcon: true,
          autoCloseDuration: duration,
        );
      },
    );
  }

  static void showErrorToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 4),
    Alignment alignment = Alignment.bottomRight,
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          title: Text(message, style: const TextStyle(fontSize: 12)),
          primaryColor: Colors.red,
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: true,
          icon: const Icon(Icons.error, color: Colors.red),
          showIcon: true,
          autoCloseDuration: duration,
        );
      },
    );
  }

  static void showSuccessToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
    Alignment alignment = Alignment.bottomRight,
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          title: Text(message, style: const TextStyle(fontSize: 12)),
          primaryColor: Colors.green,
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: true,
          icon: const Icon(Icons.check, color: Colors.green),
          showIcon: true,
          autoCloseDuration: duration,
        );
      },
    );
  }

  static void showWarningToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
    Alignment alignment = Alignment.bottomRight,
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          title: Text(message, style: const TextStyle(fontSize: 12)),
          primaryColor: Colors.yellow,
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: true,
          icon: const Icon(Icons.warning, color: Colors.yellow),
          showIcon: true,
          autoCloseDuration: duration,
        );
      },
    );
  }
}
