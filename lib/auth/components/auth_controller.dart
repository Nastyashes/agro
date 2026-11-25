import 'package:agro/controllers/abstract/from_controller.dart';
import 'package:agro/data/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';
import '../../controllers/app_input_controller.dart';

/// Phone step of sign-in. Holds no BuildContext: the screen observes
/// [phone] / [errorNumber] and shows a message on each [rejected] event.
class AuthController extends FormController {
  AuthController({
    AuthRepository? repository,
    void Function(String route)? navigate,
  })  : _repository = repository ?? AuthRepository(),
        _navigate = navigate ?? Get.offAllNamed;

  final AuthRepository _repository;
  final void Function(String route) _navigate;

  late TextEditingController numberController;

  final List<MaskTextInputFormatter> maskFormatterNumber = [
    MaskTextInputFormatter(
        mask: '### ## ###-##-##', filter: {"#": RegExp(r'\d')})
  ];

  final RxString phone = ''.obs;
  final RxnString errorNumber = RxnString();

  /// Incremented when the server does not know the number.
  final RxInt rejected = 0.obs;

  bool get canSubmit => phone.value.length == 16;

  @override
  void onInit() {
    numberController = AppInputController();
    super.onInit();
  }

  void onPhoneChanged(String value) {
    phone.value = value;
    errorNumber.value = null;
  }

  void onContactTelegram() => launchUrl(Uri.parse('https://t.me/uagro_admin'));

  void onContactViber() => launchUrl(
      Uri.parse('viber://chat?number=${Uri.encodeComponent('+380990026222')}'));

  void onLogin() => loadIfValid(submit);

  /// Requests the SMS code for the entered number.
  Future<void> submit() async {
    final digits = numberController.text.replaceAll(RegExp(r'\D'), '');
    if (await _repository.requestCode('+$digits')) {
      _navigate(Routes.authConfirm);
    } else {
      rejected.value++;
    }
  }
}
