import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Feed filter chip with a leading icon. [solid] is the brand-green
/// selected style ("All"); otherwise selected is a green tint and border.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.solid = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool solid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final solidOn = selected && solid;
    final bg = !selected
        ? Palette.bg1
        : solid
            ? Palette.green
            : Palette.greenSoft;
    final border = selected ? Palette.green : Palette.line;
    final text = solidOn
        ? Palette.textInverse
        : selected
            ? Palette.textPrimary
            : Palette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: StadiumBorder(
            side: BorderSide(color: border, width: selected ? 1.5 : 1)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: solidOn ? Colors.transparent : Palette.greenSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 16,
                    color: solidOn ? Palette.textInverse : Palette.green),
              ),
              const SizedBox(width: 6),
              Text(label, style: AppText.label.copyWith(color: text)),
            ]),
          ),
        ),
      ),
    );
  }
}
