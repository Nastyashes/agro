import 'package:agro/controllers/abstract/from_controller.dart';
import 'package:agro/data/repositories/auth_repository.dart';
import 'package:agro/model/model_user/struct_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/app_input_controller.dart';
import '../../../routes/app_pages.dart';

/// SMS-code step of sign-in. Holds no BuildContext: the screen observes
/// [code] and [errorCode].
class AuthConfirmationController extends FormController {
  AuthConfirmationController({
    AuthRepository? repository,
    void Function(ConfirmCodeResult result)? onSignedIn,
  })  : _repository = repository ?? AuthRepository(),
        _onSignedIn = onSignedIn ?? _saveSessionAndOpenApp;

  final AuthRepository _repository;
  final void Function(ConfirmCodeResult result) _onSignedIn;

  late TextEditingController codeController;

  final RxString code = ''.obs;

  /// Server text when the code is rejected.
  final RxnString errorCode = RxnString();

  bool get canSubmit => code.value.length == 4;

  @override
  void onInit() {
    codeController = AppInputController();
    super.onInit();
  }

  void onCodeChanged(String value) {
    code.value = value;
    errorCode.value = null;
  }

  void onContactTelegram() => launchUrl(Uri.parse('https://t.me/uagro_admin'));

  void onContactViber() => launchUrl(
      Uri.parse('viber://chat?number=${Uri.encodeComponent('+380990026222')}'));

  void onAuth() => Get.offAllNamed(Routes.auth);

  void onLogin() => loadIfValid(submit);

  /// Confirms the SMS code; on success the session is saved.
  Future<void> submit() async {
    final result = await _repository.confirmCode(codeController.text);
    if (result.isSuccess) {
      _onSignedIn(result);
    } else {
      errorCode.value = result.errorMessage;
    }
  }

  static void _saveSessionAndOpenApp(ConfirmCodeResult result) =>
      structUserData(data: result.user, token: result.token, login: true);
}
