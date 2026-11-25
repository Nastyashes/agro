import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/text/read_text.dart';

import '../generated/assets.dart';
import '../ui/buttons/b_transparent_scalable_button.dart';
import '../ui/text_field/text_field.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'components/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthController controller = Get.find();
  late final Worker _rejectedWorker;

  @override
  void initState() {
    super.initState();
    _rejectedWorker = ever(controller.rejected, (_) {
      if (mounted) {
        notification(text: context.l.numberNoRegistered, type: SnackType.error);
      }
    });
  }

  @override
  void dispose() {
    _rejectedWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.backgroundGradient1,
            body: Stack(children: [
              const AppBackground(),
              SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).padding.bottom),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 120, bottom: 120),
                              child: Center(
                                  child: Image.asset(Assets.pictureLogo,
                                      width:
                                          MediaQuery.of(c).size.width / 1.2))),
                          Obx(() => TextFieldWidget(
                              colorBg: AppColors.backgroundGradient1,
                              border: Border.all(
                                  width: 1.5, color: AppColors.mainGreen),
                              borderRadius: BorderRadius.circular(16),
                              textStyle: AppFonts.body1medium.white,
                              headerColor: AppColors.white,
                              hintStyle: AppFonts.body1medium.grey3,
                              padding: const EdgeInsets.only(top: 15),
                              text: context.l.enterPhoneNumber,
                              header: context.l.phoneNumber,
                              prefixText: '+ ',
                              openKeyboardAuto: true,
                              error: controller.errorNumber.value,
                              keyboardType: TextInputType.number,
                              inputFormatters: controller.maskFormatterNumber,
                              controller: controller.numberController,
                              onChanged: controller.onPhoneChanged)),
                          Obx(() => bStyle(
                              key: UniqueKey(),
                              padding: const EdgeInsets.only(top: 35),
                              text: context.l.getCode,
                              c: c,
                              vertical: 18,
                              active: controller.canSubmit,
                              onPressed: controller.onLogin)),
                          const Spacer(),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BTransparentScalableButton(
                                    onPressed: controller.onContactTelegram,
                                    scale: ScaleFormat.small,
                                    child: SvgPicture.asset(Assets.authTelegram,
                                        width: 50)),
                                const SizedBox(width: 20),
                                BTransparentScalableButton(
                                    onPressed: controller.onContactViber,
                                    scale: ScaleFormat.small,
                                    child: SvgPicture.asset(Assets.authViber,
                                        width: 55))
                              ]),
                          Center(
                              child: readText(
                                  text: context.l.needHelpSupport,
                                  style: AppFonts.body2medium.grey3,
                                  padding: const EdgeInsets.only(
                                      bottom: 30, top: 15),
                                  align: TextAlign.center))
                        ]),
                  )),
            ])));
  }
}
