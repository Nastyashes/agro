import 'package:agro/auth/auth_screen.dart';
import 'package:agro/auth/components/auth_controller.dart';
import 'package:agro/auth/components/auth_layout.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget app(Widget child) => GetMaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );

/// Contract: "Отримати код" works only with a full number; support
/// messengers are reachable from the login screens.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
  });
  tearDown(Get.reset);

  testWidgets('get-code is disabled until the number is complete',
      (tester) async {
    Get.put(AuthController());
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const AuthScreen()));
    await tester.pump();

    AppButton button() => tester
        .widget<AppButton>(find.widgetWithText(AppButton, 'Отримати код'));
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '380501234567');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('layout shows support messengers and calls back', (tester) async {
    var telegram = 0;
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(AuthLayout(
      onTelegram: () => telegram++,
      onViber: () {},
      children: const [Text('form')],
    )));
    expect(find.text('form'), findsOneWidget);
    expect(find.textContaining('Потрібна допомога'), findsOneWidget);
    await tester.tap(find.byType(SvgPicture).first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(telegram, 1);
  });

  // BUG-042: the code screen has a LayoutBuilder; the frame must lay it out
  // on any screen height and with the keyboard up, without intrinsics.
  for (final size in const [Size(400, 900), Size(320, 480)]) {
    testWidgets('frame lays out a LayoutBuilder child at $size',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(AuthLayout(
        onTelegram: () {},
        children: [
          LayoutBuilder(
              builder: (_, box) => SizedBox(height: 56, width: box.maxWidth)),
          const SizedBox(height: 300),
        ],
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Keyboard up: the visible area shrinks.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Потрібна допомога'), findsOneWidget);
    });
  }
}
