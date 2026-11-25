import 'package:agro/auth/auth_confirmation/components/auth_confirmation_controller.dart';
import 'package:agro/auth/components/auth_controller.dart';
import 'package:agro/data/repositories/auth_repository.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeAuthRepository extends AuthRepository {
  bool codeSent = true;
  ConfirmCodeResult confirm = const ConfirmCodeResult.failure('Невірний код');
  final List<String> phones = [];
  final List<String> codes = [];

  @override
  Future<bool> requestCode(String phone) async {
    phones.add(phone);
    return codeSent;
  }

  @override
  Future<ConfirmCodeResult> confirmCode(String code) async {
    codes.add(code);
    return confirm;
  }
}

void main() {
  setUpAll(() => Get.testMode = true);

  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  group('AuthController (phone)', () {
    late List<String> routes;
    late AuthController controller;

    setUp(() {
      routes = [];
      controller = AuthController(repository: repo, navigate: routes.add)
        ..onInit();
    });

    test('submit is enabled only for a full masked number', () {
      controller.onPhoneChanged('99 002-62');
      expect(controller.canSubmit, isFalse);

      controller.onPhoneChanged('380 99 002-62-22');
      expect(controller.canSubmit, isTrue);
    });

    test('typing clears the error', () {
      controller.errorNumber.value = 'bad';

      controller.onPhoneChanged('3');

      expect(controller.errorNumber.value, isNull);
    });

    test('sends +digits and opens the code screen on success', () async {
      controller.numberController.text = '380 99 002-62-22';

      await controller.submit();

      expect(repo.phones, ['+380990026222']);
      expect(routes, [Routes.authConfirm]);
      expect(controller.rejected.value, 0);
    });

    test('unknown number raises a rejected event and stays', () async {
      repo.codeSent = false;
      controller.numberController.text = '380 99 002-62-22';

      await controller.submit();

      expect(routes, isEmpty);
      expect(controller.rejected.value, 1);
    });
  });

  group('AuthConfirmationController (code)', () {
    late List<ConfirmCodeResult> signedIn;
    late AuthConfirmationController controller;

    setUp(() {
      signedIn = [];
      controller = AuthConfirmationController(
        repository: repo,
        onSignedIn: signedIn.add,
      )..onInit();
    });

    test('submit is enabled only for 4 digits', () {
      controller.onCodeChanged('12');
      expect(controller.canSubmit, isFalse);

      controller.onCodeChanged('1234');
      expect(controller.canSubmit, isTrue);
    });

    test('wrong code shows the server message', () async {
      controller.codeController.text = '0000';

      await controller.submit();

      expect(repo.codes, ['0000']);
      expect(controller.errorCode.value, 'Невірний код');
      expect(signedIn, isEmpty);
    });

    test('typing clears the error', () async {
      controller.codeController.text = '0000';
      await controller.submit();

      controller.onCodeChanged('1');

      expect(controller.errorCode.value, isNull);
    });

    test('right code signs in', () async {
      repo.confirm = const ConfirmCodeResult.success(
          user: {'id': '9', 'role': 'distrib'}, token: 'T0K');
      controller.codeController.text = '1234';

      await controller.submit();

      expect(signedIn.single.token, 'T0K');
      expect(controller.errorCode.value, isNull);
    });
  });
}
