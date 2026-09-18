import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onPressed;
  final int badge;
  final bool showChevron;
  final bool showDivider;
  final Color iconColor;
  final Color titleColor;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onPressed,
    this.badge = 0,
    this.showChevron = true,
    this.showDivider = true,
    this.iconColor = AppColors.additionalGreen,
    this.titleColor = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppFonts.body2medium.copyWith(color: titleColor);
    final row = Row(
      mainAxisSize: showChevron || showDivider
          ? MainAxisSize.max
          : MainAxisSize.min,
      children: [
        _MenuIcon(icon: icon, color: iconColor, badge: badge),
        const SizedBox(width: 12),
        if (showChevron || showDivider)
          Expanded(child: Text(title, style: titleStyle))
        else
          Text(title, style: titleStyle),
        if (showChevron)
          const Icon(
            Icons.chevron_right,
            color: AppColors.additionalGreen,
            size: 22,
          ),
      ],
    );

    return BTransparentScalableButton(
      onPressed: onPressed ?? () {},
      scale: ScaleFormat.small,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: row,
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.mainGreen,
            ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int badge;

  const _MenuIcon({
    required this.icon,
    required this.color,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 24, color: color);
    if (badge <= 0) return iconWidget;

    return SizedBox(
      width: 28,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            top: -4,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.daysRed,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: AppFonts.caption.copyWith(
                  color: AppColors.white,
                  fontSize: 10,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
