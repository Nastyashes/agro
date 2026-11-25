import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Small label: neutral by default, or tinted with [color].
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color == null ? Palette.bg3 : color!.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(Radii.tag),
        ),
        child: Text(label,
            style: AppText.tag.copyWith(color: color ?? Palette.textSecondary)),
      );
}
