import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Empty list or screen: an icon in a circle, a title, an optional
/// explanation of what will appear here, and an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.icon = Icons.inbox_rounded,
    this.text,
    this.actionLabel,
    this.onAction,
    this.primaryAction = false,
  });

  final String title;
  final IconData icon;
  final String? text;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Green main button instead of the quiet secondary one.
  final bool primaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Palette.bg2,
              shape: BoxShape.circle,
              border: Border.all(color: Palette.line),
            ),
            child: Icon(icon, size: 32, color: Palette.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppText.headline, textAlign: TextAlign.center),
          if (text != null) ...[
            const SizedBox(height: 8),
            Text(text!,
                style: AppText.body.copyWith(color: Palette.textSecondary),
                textAlign: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: AppButton(
                label: actionLabel!,
                onPressed: onAction,
                style: primaryAction
                    ? AppButtonStyle.primary
                    : AppButtonStyle.secondary,
                size: AppButtonSize.small,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
