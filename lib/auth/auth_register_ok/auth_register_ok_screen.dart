import 'package:agro/auth/components/auth_layout.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/auth_register_ok_controller.dart';

class AuthRegisterOkScreen extends StatelessWidget {
  const AuthRegisterOkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRegisterOkController controller = Get.find();
    return AuthLayout(
      onTelegram: controller.onContactTelegram,
      onViber: controller.onContactViber,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: Palette.greenSoft, shape: BoxShape.circle),
            child:
                const Icon(Icons.check_rounded, size: 36, color: Palette.green),
          ),
        ),
        const SizedBox(height: 16),
        Text(context.l.thanksForRegistration,
            style: AppText.title, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(context.l.managersContactYou,
            style: AppText.body.copyWith(color: Palette.textSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }
}
