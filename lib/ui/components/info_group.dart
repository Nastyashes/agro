import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Small grey heading above a group.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(text,
            style: AppText.overline.copyWith(color: Palette.textTertiary)),
      );
}

/// Rounded card that stacks rows with hairlines between them.
class InfoGroup extends StatelessWidget {
  const InfoGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const Divider(height: 1));
      rows.add(children[i]);
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Palette.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: rows),
      ),
    );
  }
}

/// "Label — value" row; the value is right-aligned and may wrap.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value,
      {super.key, this.valueColor, this.onTap});

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppText.body.copyWith(color: Palette.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(value,
                    textAlign: TextAlign.end,
                    style: AppText.bodyMedium.copyWith(color: valueColor)),
              ),
            ],
          ),
        ),
      );
}

/// Tappable row: icon, title, optional trailing text, chevron. A null
/// [onTap] shows it disabled (e.g. while a request is running).
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.done = false,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  /// Shows a check instead of the chevron.
  final bool done;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(children: [
            Icon(icon,
                size: 22,
                color: enabled || done ? Palette.green : Palette.textTertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: AppText.bodyMedium.copyWith(
                      color: enabled || done
                          ? Palette.textPrimary
                          : Palette.textSecondary)),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(trailing!,
                    style: AppText.label.copyWith(color: Palette.textTertiary)),
              ),
            Icon(
                done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                size: 20,
                color: done ? Palette.green : Palette.textTertiary),
          ]),
        ),
      ),
    );
  }
}
