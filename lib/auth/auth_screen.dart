import 'package:agro/auth/components/auth_layout.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  Widget build(BuildContext context) {
    final l = context.l;
    return AuthLayout(
      onTelegram: controller.onContactTelegram,
      onViber: controller.onContactViber,
      children: [
        Text(l.phoneNumber, style: AppText.bodyMedium),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller.numberController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: controller.maskFormatterNumber,
              onChanged: controller.onPhoneChanged,
              style: AppText.bodyMedium,
              decoration: InputDecoration(
                hintText: l.enterPhoneNumber,
                prefixText: '+ ',
                prefixStyle:
                    AppText.bodyMedium.copyWith(color: Palette.textSecondary),
                errorText: controller.errorNumber.value,
                fillColor: Palette.bg1,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Palette.green, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Palette.green, width: 2),
                ),
              ),
            )),
        const SizedBox(height: 28),
        Obx(() => AppButton(
              label: l.getCode,
              pill: true,
              onPressed: controller.canSubmit ? controller.onLogin : null,
            )),
      ],
    );
  }
}
