import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/ui/pop_up/top_up_balance_popup.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contract: payment starts once, only with an amount of at least 10 UAH,
/// after an explicit tap on "Оплатити"; closing the sheet pays nothing.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late List<int> paid;

  Future<void> open(WidgetTester tester) async {
    paid = [];
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTopUpDialog(context, 29, paid.add),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('default 200, a preset changes the amount', (tester) async {
    await open(tester);
    expect(find.text('Оплатити 200 грн'), findsOneWidget);
    expect(find.text('29 грн'), findsOneWidget);

    await tester.tap(find.text('500'));
    await tester.pump();
    await tester.tap(find.text('Оплатити 500 грн'));
    await tester.pumpAndSettle();

    expect(paid, [500]);
    expect(find.text('Поповнення'), findsNothing);
  });

  testWidgets('a custom amount below 10 is rejected', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    await tester.tap(find.text('Оплатити 5 грн'));
    await tester.pump();

    expect(paid, isEmpty);
    expect(find.text('Мінімальна сума поповнення 10 грн'), findsOneWidget);
  });

  testWidgets('a custom amount pays exactly that, once', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), '350');
    await tester.pump();
    await tester.tap(find.text('Оплатити 350 грн'));
    await tester.tap(find.text('Оплатити 350 грн'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(paid, [350]);
  });

  testWidgets('closing the sheet pays nothing', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(paid, isEmpty);
  });
}
