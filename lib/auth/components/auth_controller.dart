import 'dart:developer';

import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agro/server/api/api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/abstract/from_controller.dart';
import '../../../routes/app_pages.dart';
import '../../controllers/app_input_controller.dart';

class AuthController extends FormController {
  late Function(VoidCallback fn) setState;
  late BuildContext c;
  late TextEditingController numberController;
  List<MaskTextInputFormatter> maskFormatterNumber = [
    MaskTextInputFormatter(
        mask: '### ## ###-##-##', filter: {"#": RegExp(r'\d')})
  ];
  String? errorNumber;

  @override
  void onInit() {
    numberController = AppInputController();

    super.onInit();
  }

  void initPage(
      {required BuildContext context,
      required Function(VoidCallback fn) set}) async {
    c = context;
    setState = set;
  }

  void updScreenError(_) => setState(() => errorNumber = null);

  void onContactTelegram() => launchUrl(Uri.parse('https://t.me/uagro_admin'));

  void onContactViber() => launchUrl(
      Uri.parse('viber://chat?number=${Uri.encodeComponent('+380990026222')}'));

  void onLogin(BuildContext context) => loadIfValid(() async {
        ApiAnswer apiAnswer = await Api().auth.loginNumber(
            number: '+${numberController.text.replaceAll(RegExp('\\D'), '')}');

        log('apiAnswer.data: ${apiAnswer.data}');

        final bool success = apiAnswer.data['status'] == true;

        if (success) {
          Get.offAllNamed(Routes.authConfirm);
        } else {
          context.mounted
              ? notification(text: context.l.numberNoRegistered)
              : {};
        }
      }, c: c);
}
