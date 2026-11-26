import 'package:agro/generated/assets.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Login screens frame, close to the original: big centered logo, the
/// form, and Telegram/Viber support at the bottom.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.children,
    this.onTelegram,
    this.onViber,
  });

  final List<Widget> children;
  final VoidCallback? onTelegram;
  final VoidCallback? onViber;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Palette.bg0,
      body: Stack(children: [
        const AppBackground(),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: height * 0.1, bottom: height * 0.08),
                        child: Center(
                          child: Image.asset(Assets.pictureLogo, width: 300),
                        ),
                      ),
                      ...children,
                      const Spacer(),
                      if (onTelegram != null || onViber != null)
                        _Support(onTelegram: onTelegram, onViber: onViber),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Support extends StatelessWidget {
  const _Support({this.onTelegram, this.onViber});

  final VoidCallback? onTelegram;
  final VoidCallback? onViber;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 24),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (onTelegram != null)
              BTransparentScalableButton(
                onPressed: onTelegram!,
                scale: ScaleFormat.small,
                child: SvgPicture.asset(Assets.authTelegram, width: 48),
              ),
            if (onTelegram != null && onViber != null)
              const SizedBox(width: 20),
            if (onViber != null)
              BTransparentScalableButton(
                onPressed: onViber!,
                scale: ScaleFormat.small,
                child: SvgPicture.asset(Assets.authViber, width: 48),
              ),
          ]),
          const SizedBox(height: 14),
          Text(context.l.needHelpSupport,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: Palette.textSecondary)),
        ]),
      );
}
