import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../text/read_text.dart';
import 'b_transparent_scalable_button.dart';


// ============================================================
// CONSTANTS
// ============================================================

const EdgeInsets _defaultButtonPadding = EdgeInsets.only(
  top: 6,
  bottom: 6,
  left: 20,
  right: 20,
);


// ============================================================
// STANDARD BUTTON STYLES
// ============================================================

ButtonStyle _buttonStyle({
  required Color buttonColor,
  required Color textColor,
}) =>
    ButtonStyle(
      padding: WidgetStateProperty.all(_defaultButtonPadding),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (states) => states.contains(WidgetState.disabled)
            ? buttonColor.withValues(alpha: 0.3)
            : buttonColor,
      ),
      textStyle: WidgetStateProperty.all(
        AppFonts.body1bold.copyWith(
          color: textColor,
        ),
      ),
    );

final ButtonStyle greenButtonStyle = _buttonStyle(
  buttonColor: AppColors.mainGreen,
  textColor: AppColors.white,
);

final ButtonStyle lightGreenButtonStyle = _buttonStyle(
  buttonColor: AppColors.buttonLightGreen,
  textColor: AppColors.white,
);

final ButtonStyle yellowButtonStyle = _buttonStyle(
  buttonColor: AppColors.yellow,
  textColor: AppColors.white,
);

final ButtonStyle blueButtonStyle = _buttonStyle(
  buttonColor: AppColors.blue,
  textColor: AppColors.white,
);


// ============================================================
// OUTLINED BUTTON
// ============================================================

ButtonStyle _outlineButtonStyle({
  Color borderColor = AppColors.mainGreen,
  Color textColor = AppColors.mainGreen,
}) =>
    ButtonStyle(
      padding: WidgetStateProperty.all(_defaultButtonPadding),
      shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: states.contains(WidgetState.disabled)
                ? borderColor.withValues(alpha: 0.3)
                : borderColor,
          ),
        ),
      ),
      backgroundColor: WidgetStateProperty.all(
        AppColors.transparent,
      ),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (states) => AppFonts.body2bold.copyWith(
          color: states.contains(WidgetState.disabled)
              ? textColor.withValues(alpha: 0.3)
              : textColor,
        ),
      ),
    );

final ButtonStyle outlineButtonStyle = _outlineButtonStyle();


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
              vertical: vertical ?? 16,
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