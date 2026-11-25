import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// Universal confirmation: context icon, question, consequence, two equal
/// buttons. Resolves true only on the confirm button; cancel, the scrim or
/// back resolve false. A destructive action is red and named by its verb.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  String? text,
  required String confirmLabel,
  String? cancelLabel,
  IconData? icon,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AppConfirmDialog(
      title: title,
      text: text,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel ?? context.l.cancel,
      icon: icon,
      destructive: destructive,
    ),
  );
  return result == true;
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    this.text,
    this.icon,
    this.destructive = false,
  });

  final String title;
  final String? text;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? Palette.red : Palette.green;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ??
                      (destructive
                          ? Icons.warning_amber_rounded
                          : Icons.help_outline_rounded),
                  size: 26,
                  color: accent,
                ),
              ),
              const SizedBox(height: 14),
              Text(title, style: AppText.title, textAlign: TextAlign.center),
              if (text != null) ...[
                const SizedBox(height: 8),
                Text(text!,
                    style: AppText.body.copyWith(color: Palette.textSecondary),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelLabel,
                      style: AppButtonStyle.secondary,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ConfirmButton(
                      label: confirmLabel,
                      destructive: destructive,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton(
      {required this.label,
      required this.destructive,
      required this.onPressed});

  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!destructive) return AppButton(label: label, onPressed: onPressed);
    // Solid red with dark text, as in the design.
    return Material(
      color: Palette.red,
      borderRadius: BorderRadius.circular(Radii.button),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 54,
          child: Center(
            child: Text(label,
                style: AppText.button.copyWith(color: Palette.textInverse),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
