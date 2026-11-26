import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contract: the search filter in a picker survives the keyboard closing
/// (the sheet rebuilds when the keyboard hides).
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('filter stays after the keyboard hides', (tester) async {
    String? picked;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showMyPricePicker<String>(
              context: context,
              title: 'Культура',
              items: const ['Пшениця', 'Соя', 'Соняшник', 'Кукурудза'],
              label: (s) => s,
              enableSearch: true,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'со');
    await tester.pump();
    expect(find.text('Соя'), findsOneWidget);
    expect(find.text('Пшениця'), findsNothing);

    // Keyboard hides: the sheet rebuilds with new insets.
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    expect(find.text('Пшениця'), findsNothing, reason: 'filter kept');
    expect(find.text('Соняшник'), findsOneWidget);

    await tester.tap(find.text('Соя'));
    await tester.pumpAndSettle();
    expect(picked, 'Соя');
  });
}
