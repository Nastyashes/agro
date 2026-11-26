import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// A section that is not built yet: what it will be, so «Незабаром»
/// is not a dead end.
class ComingSoon {
  const ComingSoon(
      {required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}

void showComingSoonSheet(BuildContext context, ComingSoon section) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Palette.greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(section.icon, size: 28, color: Palette.green),
            ),
            const SizedBox(height: 12),
            Text(section.title,
                textAlign: TextAlign.center, style: AppText.headline),
            const SizedBox(height: 4),
            Text(context.l.comingSoonHint,
                textAlign: TextAlign.center,
                style: AppText.label.copyWith(color: Palette.green)),
            const SizedBox(height: 10),
            Text(section.description,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: Palette.textSecondary)),
            const SizedBox(height: 20),
            AppButton(
              label: context.l.ok,
              style: AppButtonStyle.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
