import 'package:agro/app/profile/tariffs/tariff_item.dart';
import 'package:agro/app/profile/tariffs/tariffs_controller.dart';
import 'package:agro/app/profile/tariffs/tariffs_screen.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FakeAccount extends AccountRepository {
  @override
  Future<List<ModelTariff>> tariffs() async => [
        ModelTariff(
            name: 'FREE', price: '0', currency: 'грн', advantages: ['a']),
        ModelTariff(
            name: 'Premium',
            price: '3500',
            currency: 'грн',
            disadvantages: ['b']),
      ];
}

class PremiumMain extends MainController {
  @override
  Tariff? get tariff =>
      Tariff.fromJson(const {'is_premium': 'Y', 'balance_end': '31.12.2099'});
}

/// Contract: one card and one dot per tariff from the server; the user's
/// current tariff is marked.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
  });

  testWidgets('dots follow the tariff count; my tariff is marked',
      (tester) async {
    Get.put<TariffsController>(TariffsController(
        repository: FakeAccount(), mainController: PremiumMain()));
    await tester.pumpWidget(GetMaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const TariffsScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('FREE'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(Row).last,
            matching: find.byType(AnimatedContainer)),
        findsNWidgets(2));
    // The badge belongs to the Premium card, never to Free.
    expect(
        find.descendant(
            of: find.widgetWithText(TariffItem, 'FREE'),
            matching: find.text('Мій тариф')),
        findsNothing);

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Premium'), findsOneWidget);
    expect(
        find.descendant(
            of: find.widgetWithText(TariffItem, 'Premium'),
            matching: find.text('Мій тариф')),
        findsOneWidget);
    Get.reset();
  });
}
