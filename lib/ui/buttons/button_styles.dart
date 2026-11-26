import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../text/read_text.dart';
import 'b_transparent_scalable_button.dart';

// ============================================================
// CUSTOM BUTTON
// ============================================================

Widget bStyle({
  required String text,
  required BuildContext c,
  required Function() onPressed,
  double? vertical,
  double? circular,
  List<Color>? linear,
  bool active = true,
  String? leftIcon,
  Color? colorIcon,
  String? rightIcon,
  Color? colorButt,
  Color? colorText,
  EdgeInsetsGeometry? padding,
  double? width,
  double? widthIcon,
  UniqueKey? key,
  bool spacerActive = false,
  bool boxShadowActive = false,
  Border? border,
}) =>
    Padding(
      padding: padding ?? EdgeInsets.zero,
      child: BTransparentScalableButton(
        key: key,
        onPressed: active ? onPressed : () {},
        scale: active ? ScaleFormat.small : ScaleFormat.none,
        child: Container(
          width: width ?? MediaQuery.of(c).size.width,
          decoration: BoxDecoration(
            color: colorButt ??
                (active
                    ? AppColors.mainGreen
                    : AppColors.mainGreen.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(circular ?? 100),
            boxShadow: boxShadowActive
                ? const [
                    BoxShadow(
                      color: AppColors.mainGreen,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
            border: border,
            gradient: linear == null
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: linear,
                  ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: vertical ?? 12,
              horizontal: spacerActive ? 20 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leftIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SvgPicture.asset(
                      leftIcon,
                      width: widthIcon ?? 25,
                      colorFilter: ColorFilter.mode(
                        colorIcon ?? AppColors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  if (spacerActive) const Spacer(),
                ],
                readText(
                  text: text,
                  style: AppFonts.body1bold.withColor(
                    colorText ??
                        (active
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.5)),
                  ),
                  align: TextAlign.center,
                ),
                if (rightIcon != null) ...[
                  if (spacerActive) const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SvgPicture.asset(
                      rightIcon,
                      width: widthIcon ?? 25,
                      colorFilter: ColorFilter.mode(
                        colorIcon ?? AppColors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
