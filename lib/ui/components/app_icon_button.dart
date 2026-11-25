import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

enum AppIconButtonStyle { outline, filled, soft }

/// 44×44 icon button: outline (default), filled green or soft green.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.style = AppIconButtonStyle.outline,
    this.size = 44,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final AppIconButtonStyle style;
  final double size;

  /// Drawn over the top-right corner, e.g. an unread dot.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      AppIconButtonStyle.outline => (
          Palette.bg2,
          Palette.textPrimary,
          Palette.line
        ),
      AppIconButtonStyle.filled => (Palette.green, Palette.textInverse, null),
      AppIconButtonStyle.soft => (Palette.greenSoft, Palette.green, null),
    };
    final button = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border == null ? BorderSide.none : BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: size * 0.5, color: fg),
        ),
      ),
    );
    return Tooltip(
      message: tooltip,
      child: badge == null
          ? button
          : Stack(clipBehavior: Clip.none, children: [
              button,
              Positioned(right: -4, top: -4, child: badge!),
            ]),
    );
  }
}

/// Red unread dot with a dark ring, for [AppIconButton.badge].
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Palette.red,
          shape: BoxShape.circle,
          border: Border.all(color: Palette.bg0, width: 2),
        ),
      );
}
