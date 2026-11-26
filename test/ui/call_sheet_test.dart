import 'package:agro/app/bid_detail/components/launch_phone.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contract: the call sheet uses the dark design (no white background),
/// shows the phone and offers call, Telegram, Viber and close.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('dark sheet with phone and three ways to reach the seller',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showCallSheet(context, '+380671234567'),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('+380671234567'), findsOneWidget);
    for (final t in ['Подзвонити', 'Telegram', 'Viber', 'Закрити']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    final sheet = tester.widget<Material>(find
        .descendant(
            of: find.byType(BottomSheet), matching: find.byType(Material))
        .first);
    expect(sheet.color, Palette.bg2);
    expect(
        find.byWidgetPredicate(
            (w) => w is Container && w.color == Colors.white),
        findsNothing);

    await tester.tap(find.text('Закрити'));
    await tester.pumpAndSettle();
    expect(find.text('Telegram'), findsNothing);
  });
}
