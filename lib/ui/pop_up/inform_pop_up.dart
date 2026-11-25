import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// A result message with a single acknowledge button.
void showInformPoUp(BuildContext context, String? title, String? description) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title ?? '',
                  style: AppText.title, textAlign: TextAlign.center),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(description,
                    style: AppText.body.copyWith(color: Palette.textSecondary),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 22),
              AppButton(
                label: context.l.ok,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
