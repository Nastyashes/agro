import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

enum MenuItemMark { none, isNew, soon }

/// Drawer row: icon, title, optional mark or unread count, chevron.
/// A [MenuItemMark.soon] row is muted; its tap only explains it is coming.
class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.mark = MenuItemMark.none,
    this.badge = 0,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onPressed;
  final MenuItemMark mark;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final soon = mark == MenuItemMark.soon;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(children: [
          Icon(icon,
              size: 24, color: soon ? Palette.textTertiary : Palette.green),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppText.bodyMedium.copyWith(
                  color: soon ? Palette.textSecondary : Palette.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (mark == MenuItemMark.isNew)
            _Pill(context.l.newBadge, bg: Palette.greenSoft, fg: Palette.green),
          if (soon)
            _Pill(context.l.comingSoon,
                bg: Palette.bg3, fg: Palette.textSecondary),
          if (badge > 0)
            _Pill(badge > 99 ? '99+' : '$badge',
                bg: Palette.red, fg: Palette.textPrimary, round: true),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: Palette.textTertiary),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text,
      {required this.bg, required this.fg, this.round = false});

  final String text;
  final Color bg, fg;
  final bool round;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(round ? 100 : Radii.tag),
        ),
        child: Text(text, style: AppText.tag.copyWith(color: fg)),
      );
}
