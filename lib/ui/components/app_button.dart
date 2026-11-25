import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

enum AppButtonStyle { primary, secondary, ghost, danger }

enum AppButtonSize { large, small }

/// «Чорнозем» button. Disabled when [onPressed] is null or while [loading],
/// so an async action cannot be started twice from the button itself.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;

  /// Takes the full width available (the default for large buttons).
  final bool expand;

  bool get enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final large = size == AppButtonSize.large;
    final (bg, fg, border) = switch (style) {
      AppButtonStyle.primary => (Palette.green, Palette.textInverse, null),
      AppButtonStyle.secondary => (Palette.bg3, Palette.textPrimary, null),
      AppButtonStyle.ghost => (Colors.transparent, Palette.green, null),
      AppButtonStyle.danger => (
          Colors.transparent,
          Palette.red,
          Palette.redSoft
        ),
    };
    final color = enabled ? fg : Palette.textTertiary;
    final textStyle =
        AppText.button.copyWith(color: color, fontSize: large ? 16 : 14);

    final child = loading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: large ? 20 : 18, color: color),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(label,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center),
              ),
            ],
          );

    final radius =
        BorderRadius.circular(large ? Radii.button : Radii.buttonSmall);
    final button = Semantics(
      button: true,
      enabled: enabled,
      label: loading ? label : null,
      child: Material(
        color: enabled || style != AppButtonStyle.primary ? bg : Palette.bg3,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: large ? 54 : 40),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: large ? 20 : 14),
              child: Center(widthFactor: 1, child: child),
            ),
          ),
        ),
      ),
    );
    return expand && large
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
