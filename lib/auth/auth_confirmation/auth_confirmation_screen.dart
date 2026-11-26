import 'package:agro/auth/components/auth_layout.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import 'components/auth_confirmation_controller.dart';

class AuthConfirmScreen extends StatefulWidget {
  const AuthConfirmScreen({super.key});

  @override
  State<AuthConfirmScreen> createState() => _AuthConfirmScreenState();
}

class _AuthConfirmScreenState extends State<AuthConfirmScreen> {
  final AuthConfirmationController controller = Get.find();

  PinTheme _pin({required bool focused, required double size}) => PinTheme(
        width: size,
        height: size,
        textStyle: AppText.numL,
        decoration: BoxDecoration(
          color: Palette.bg1,
          borderRadius: BorderRadius.circular(Radii.button),
          border: Border.all(
            color: focused ? Palette.green : Palette.lineStrong,
            width: focused ? 1.5 : 1,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AuthLayout(
      onTelegram: controller.onContactTelegram,
      onViber: controller.onContactViber,
      children: [
        Text(l.enterCode, style: AppText.title),
        const SizedBox(height: 6),
        Text(l.codeWasSent,
            style: AppText.body.copyWith(color: Palette.textSecondary)),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, box) {
          // Four cells and three 12 px gaps, at most 64 px each (fits 320 px).
          final size = ((box.maxWidth - 36) / 4).clamp(44.0, 64.0);
          return Center(
            child: Pinput(
              controller: controller.codeController,
              length: 4,
              autofocus: true,
              showCursor: true,
              defaultPinTheme: _pin(focused: false, size: size),
              focusedPinTheme: _pin(focused: true, size: size),
              submittedPinTheme: _pin(focused: false, size: size),
              separator: const SizedBox(width: 12),
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              onChanged: controller.onCodeChanged,
            ),
          );
        }),
        Obx(() => controller.errorCode.value == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(controller.errorCode.value!,
                    textAlign: TextAlign.center,
                    style: AppText.label.copyWith(color: Palette.red)),
              )),
        const SizedBox(height: 28),
        Obx(() => AppButton(
              label: l.continue_,
              pill: true,
              onPressed: controller.canSubmit ? controller.onLogin : null,
            )),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: controller.onAuth,
            child: Text(l.changeNumber,
                style:
                    AppText.bodyMedium.copyWith(color: Palette.textSecondary)),
          ),
        ),
      ],
    );
  }
}
