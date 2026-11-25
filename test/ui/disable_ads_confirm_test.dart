import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contract: paying to disable ads never happens on a single tap. The user
/// first sees the amount and must confirm; cancel or close charges nothing.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late int charges;

  Future<void> pumpButton(WidgetTester tester) async {
    charges = 0;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDisableAdsConfirm(
            context,
            amount: '150',
            onConfirm: () async => charges++,
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the amount before charging', (tester) async {
    await pumpButton(tester);

    expect(find.text('Вимкнути рекламу?'), findsOneWidget);
    expect(find.text('Буде списано 150 грн. Оплата не повертається.'),
        findsOneWidget);
    expect(charges, 0);
  });

  testWidgets('cancel charges nothing', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();

    expect(charges, 0);
    expect(find.text('Вимкнути рекламу?'), findsNothing);
  });

  testWidgets('tapping outside the dialog charges nothing', (tester) async {
    await pumpButton(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(charges, 0);
  });

  testWidgets('confirm charges exactly once', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.text('Підтвердити'));
    await tester.pumpAndSettle();

    expect(charges, 1);
    expect(find.text('Вимкнути рекламу?'), findsNothing);
  });
}
