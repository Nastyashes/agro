import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/ui/components/confirm_dialog.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/pop_up/confirm_pop_up.dart';
import 'package:agro/ui/pop_up/inform_pop_up.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget app(Widget child) => MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: Center(child: child)),
    );

/// Contract: shared «Чорнозем» components. A button cannot fire while
/// disabled or loading; confirm resolves true only on its confirm button;
/// empty state shows an action only when it has one to run.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('AppButton', () {
    testWidgets('taps run onPressed', (tester) async {
      var taps = 0;
      await tester
          .pumpWidget(app(AppButton(label: 'Так', onPressed: () => taps++)));
      await tester.tap(find.text('Так'));
      expect(taps, 1);
    });

    testWidgets('loading shows a spinner and ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
          app(AppButton(label: 'Так', loading: true, onPressed: () => taps++)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(taps, 0);
    });

    testWidgets('null onPressed is disabled', (tester) async {
      await tester
          .pumpWidget(app(const AppButton(label: 'Так', onPressed: null)));
      final ink = tester.widget<InkWell>(find.byType(InkWell));
      expect(ink.onTap, isNull);
    });

    testWidgets('does not grow to fill unbounded height', (tester) async {
      await tester.pumpWidget(app(Column(children: [
        Flexible(child: AppButton(label: 'Так', onPressed: () {})),
      ])));
      // Flexible gives it a loose max height; it must stay about 54.
      final size = tester.getSize(find.byType(InkWell));
      expect(size.height, lessThan(80));
    });

    testWidgets('large button is at least 54 tall, small at least 40',
        (tester) async {
      await tester
          .pumpWidget(app(Column(mainAxisSize: MainAxisSize.min, children: [
        AppButton(label: 'L', onPressed: () {}),
        AppButton(label: 'S', onPressed: () {}, size: AppButtonSize.small),
      ])));
      expect(tester.getSize(find.byType(AppButton).first).height,
          greaterThanOrEqualTo(54));
      expect(tester.getSize(find.byType(AppButton).last).height,
          greaterThanOrEqualTo(40));
    });
  });

  group('EmptyState', () {
    testWidgets('no action without a callback', (tester) async {
      await tester.pumpWidget(
          app(const EmptyState(title: 'Порожньо', actionLabel: 'Оновити')));
      expect(find.text('Порожньо'), findsOneWidget);
      expect(find.text('Оновити'), findsNothing);
    });

    testWidgets('action runs its callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(app(EmptyState(
          title: 'Порожньо',
          text: 'Тут будуть угоди',
          actionLabel: 'Оновити',
          onAction: () => taps++)));
      expect(find.text('Тут будуть угоди'), findsOneWidget);
      await tester.tap(find.text('Оновити'));
      expect(taps, 1);
    });
  });

  group('showAppConfirm', () {
    late bool? result;

    Future<void> open(WidgetTester tester, {bool destructive = false}) async {
      result = null;
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showAppConfirm(context,
              title: 'Вийти з профілю?',
              text: 'Дані буде видалено.',
              confirmLabel: 'Вийти',
              destructive: destructive),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('confirm resolves true', (tester) async {
      await open(tester);
      await tester.tap(find.text('Вийти'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('cancel resolves false', (tester) async {
      await open(tester);
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('scrim tap resolves false', (tester) async {
      await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('destructive confirm is red', (tester) async {
      await open(tester, destructive: true);
      final material = tester.widget<Material>(find
          .ancestor(of: find.text('Вийти'), matching: find.byType(Material))
          .first);
      expect(material.color, Palette.red);
    });
  });

  group('AppSnack', () {
    testWidgets('error type uses the red icon', (tester) async {
      await tester.pumpWidget(
          app(const AppSnack(text: 'Немає з\'єднання', type: SnackType.error)));
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_rounded));
      expect(icon.color, Palette.red);
    });

    testWidgets('action runs only when given', (tester) async {
      var taps = 0;
      await tester.pumpWidget(app(AppSnack(
          text: 'Не вдалося',
          actionLabel: 'Повторити',
          onAction: () => taps++)));
      await tester.tap(find.text('Повторити'));
      expect(taps, 1);
    });
  });

  group('showConfirmPoUp', () {
    late int runs;

    Future<void> open(WidgetTester tester) async {
      runs = 0;
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () => showConfirmPoUp(context, 'Видалити профіль?',
              'Дані буде видалено.', () async => runs++,
              confirmLabel: 'Видалити', destructive: true),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('a double tap on confirm runs the action once', (tester) async {
      await open(tester);
      await tester.tap(find.text('Видалити'));
      await tester.tap(find.text('Видалити'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(runs, 1);
    });

    testWidgets('back button runs nothing', (tester) async {
      await open(tester);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();
      expect(runs, 0);
      expect(find.text('Видалити профіль?'), findsNothing);
    });
  });

  testWidgets('showInformPoUp shows the text and closes on OK', (tester) async {
    await tester.pumpWidget(app(Builder(
      builder: (context) => TextButton(
        onPressed: () => showInformPoUp(context, 'Готово', 'Замовлено'),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Замовлено'), findsOneWidget);
    await tester.tap(find.text('Ок'));
    await tester.pumpAndSettle();
    expect(find.text('Готово'), findsNothing);
  });

  testWidgets('showAppSnackbar: a new message replaces the shown one',
      (tester) async {
    Get.testMode = true;
    await tester.pumpWidget(GetMaterialApp(
      theme: buildAppTheme(),
      home: const Scaffold(body: SizedBox()),
    ));
    showAppSnackbar('Перше');
    await tester.pump(const Duration(milliseconds: 500));
    showAppSnackbar('Друге', type: SnackType.success);
    // The first one animates out, then the second one shows; no queue.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Друге'), findsOneWidget);
    expect(find.text('Перше'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Друге'), findsNothing);
  });
}
