import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackType { success, error, info }

/// Snackbar body: type icon, plain-language text, optional action.
class AppSnack extends StatelessWidget {
  const AppSnack({
    super.key,
    required this.text,
    this.type = SnackType.info,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final SnackType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      SnackType.success => (Icons.check_circle_rounded, Palette.green),
      SnackType.error => (Icons.error_rounded, Palette.red),
      SnackType.info => (Icons.info_rounded, Palette.blue),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.bg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.lineStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.bodyMedium)),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!,
                  style: AppText.bodyMedium.copyWith(color: Palette.green)),
            ),
        ],
      ),
    );
  }
}

/// Shows [AppSnack] at the bottom for 4 s (longer when it has an action).
void showAppSnackbar(
  String text, {
  SnackType type = SnackType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  // Close the shown one; GetX queues the new one right after it. Not
  // closeAllSnackbars: it clears the queue after an await and would drop
  // the new message too.
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
  Get.showSnackbar(GetSnackBar(
    messageText: AppSnack(
      text: text,
      type: type,
      actionLabel: actionLabel,
      onAction: onAction == null
          ? null
          : () {
              Get.closeCurrentSnackbar();
              onAction();
            },
    ),
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    snackPosition: SnackPosition.BOTTOM,
    duration: duration ?? Duration(seconds: onAction == null ? 4 : 6),
  ));
}
