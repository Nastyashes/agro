import 'package:agro/app/inform_messages/inform_message_card.dart';
import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/create_my_price_screen.dart';
import 'package:agro/app/my_price/my_price_deals_screen.dart';
import 'package:agro/app/my_price/my_price_screen.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/components/form_tile.dart';
import 'package:agro/ui/components/segmented.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget app(Widget child) => MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    );

Message msg({required bool read}) => Message.fromJson({
      'id': 1,
      'readed': read ? 1 : 0,
      'title': 'Оновлення тарифів',
      'message': 'З 1 грудня змінюються умови.',
      'created_human': '26.11.2026 10:00',
    });

/// Contract: My price, deals and messages show state correctly and act only
/// on explicit taps; a disabled deal confirm can never confirm.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('combinationProgress', () {
    test('share of the term passed, clamped', () {
      expect(combinationProgress(100, 200, 150), 0.5);
      expect(combinationProgress(100, 200, 50), 0.0);
      expect(combinationProgress(100, 200, 500), 1.0);
    });

    test('unknown or invalid dates give no bar', () {
      expect(combinationProgress(null, 200, 150), isNull);
      expect(combinationProgress(100, null, 150), isNull);
      expect(combinationProgress(200, 100, 150), isNull);
    });
  });

  testWidgets('Segmented shows counts and reports taps', (tester) async {
    final picked = <int>[];
    await tester.pumpWidget(app(Segmented(
      items: const [
        SegmentItem('Комбінації', count: 2),
        SegmentItem('Бронювання', count: 0),
      ],
      selected: 0,
      onChanged: picked.add,
    )));
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Бронювання'));
    expect(picked, [1]);
  });

  group('form tiles', () {
    testWidgets('empty select shows the placeholder; error is red',
        (tester) async {
      await tester.pumpWidget(app(SelectTile(
        icon: Icons.grass_rounded,
        label: 'Культура',
        value: null,
        placeholder: 'Оберіть культуру',
        error: true,
        onTap: () {},
      )));
      expect(find.text('Оберіть культуру'), findsOneWidget);
      final box =
          tester.widget<Ink>(find.byType(Ink)).decoration as BoxDecoration;
      expect((box.border as Border).top.color, Palette.red);
    });

    testWidgets('read-only select has no chevron and ignores taps',
        (tester) async {
      await tester.pumpWidget(app(const SelectTile(
        icon: Icons.grass_rounded,
        label: 'Культура',
        value: 'Пшениця',
        placeholder: '',
        onTap: null,
      )));
      expect(find.text('Пшениця'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more_rounded), findsNothing);
    });

    testWidgets('input writes to its controller and shows the suffix',
        (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(app(InputTile(
        icon: Icons.sell_outlined,
        label: 'Ціна за тонну',
        controller: c,
        suffix: 'грн / т',
        big: true,
      )));
      await tester.enterText(find.byType(TextField), '9200');
      expect(c.text, '9200');
      expect(find.text('грн / т'), findsOneWidget);
    });
  });

  testWidgets('empty combinations offer a green create button', (tester) async {
    var created = 0;
    await tester.pumpWidget(app(EmptyState(
      title: 'Ще немає комбінацій',
      actionLabel: 'Створити комбінацію',
      onAction: () => created++,
      primaryAction: true,
    )));
    await tester.tap(find.text('Створити комбінацію'));
    expect(created, 1);
  });

  group('InformMessageCard', () {
    testWidgets('unread: mark as read calls back once', (tester) async {
      var reads = 0;
      await tester.pumpWidget(app(
          InformMessageCard(message: msg(read: false), onRead: () => reads++)));
      expect(find.text('Оновлення тарифів'), findsOneWidget);
      expect(find.text('26.11.2026 10:00'), findsOneWidget);
      await tester.tap(find.text('Позначити прочитаним'));
      expect(reads, 1);
    });

    testWidgets('read: no action', (tester) async {
      await tester.pumpWidget(
          app(InformMessageCard(message: msg(read: true), onRead: () {})));
      expect(find.text('Позначити прочитаним'), findsNothing);
    });
  });

  group('DealRow', () {
    testWidgets('shows title, region, time and the charge', (tester) async {
      await tester.pumpWidget(app(const DealRow(
          item: MyPriceDealItem(
        orderId: 5,
        orderTitle: 'Пшениця 2 клас',
        regionTitle: 'Київська',
        createdHuman: '14:20',
        chargedAmount: 25,
      ))));
      expect(find.text('Пшениця 2 клас'), findsOneWidget);
      expect(find.text('Київська · 14:20'), findsOneWidget);
      expect(find.text('25 грн'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('without an order it cannot be opened', (tester) async {
      await tester.pumpWidget(
          app(const DealRow(item: MyPriceDealItem(productTitle: 'Соя'))));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });
  });

  group('showMyPriceConfirmDialog', () {
    Future<bool?> open(WidgetTester tester, {required bool enabled}) async {
      bool? result;
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showMyPriceConfirmDialog(
            context: context,
            title: 'Підтвердити угоду?',
            body: 'Буде списано 200 грн.',
            confirmEnabled: enabled,
          ),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Підтвердити'), warnIfMissed: false);
      await tester.pumpAndSettle();
      if (find.text('Скасувати').evaluate().isNotEmpty) {
        await tester.tap(find.text('Скасувати'));
        await tester.pumpAndSettle();
      }
      return result;
    }

    testWidgets('enabled confirm resolves true', (tester) async {
      expect(await open(tester, enabled: true), isTrue);
    });

    testWidgets('disabled confirm cannot confirm', (tester) async {
      expect(await open(tester, enabled: false), isFalse);
    });
  });

  group('CombinationCard', () {
    late List<String> calls;

    Future<void> pump(WidgetTester tester, MyPriceEntry entry,
        {bool reservation = false}) async {
      calls = [];
      await tester.pumpWidget(app(CombinationCard(
        entry: entry,
        productName: 'Пшениця 2 клас',
        regionName: 'Київська',
        paymentName: '1ф',
        reservation: reservation,
        onEdit: () => calls.add('edit'),
        onDelete: () => calls.add('delete'),
      )));
    }

    testWidgets('active: price, progress, edit and delete', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await pump(
          tester,
          MyPriceEntry(
              status: 'active',
              pricePerTon: 9200,
              startsAt: now - 1000,
              endsAt: now + 1000));
      expect(find.text('Активна'), findsOneWidget);
      expect(find.text('Пшениця 2 клас'), findsOneWidget);
      expect(find.text('Київська · 1ф'), findsOneWidget);
      expect(find.textContaining('9200'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Редагувати'));
      await tester.tap(find.text('Видалити'));
      expect(calls, ['edit', 'delete']);
    });

    testWidgets('deleted: dimmed, no actions', (tester) async {
      await pump(tester, const MyPriceEntry(status: 'deleted'));
      expect(find.text('Видалена'), findsOneWidget);
      expect(find.byType(Opacity), findsOneWidget);
      expect(find.text('Редагувати'), findsNothing);
      expect(find.text('Видалити'), findsNothing);
    });

    testWidgets('reservation: queue position, no actions', (tester) async {
      await pump(tester, const MyPriceEntry(status: 'active', queuePosition: 3),
          reservation: true);
      expect(find.text('Позиція в черзі: 3'), findsOneWidget);
      expect(find.text('Редагувати'), findsNothing);
    });

    testWidgets('reservation without a position shows none', (tester) async {
      await pump(tester, const MyPriceEntry(status: 'active'),
          reservation: true);
      expect(find.textContaining('Позиція в черзі'), findsNothing);
    });
  });

  group('missingComboFields', () {
    const labels = (
      product: 'культура',
      region: 'область',
      payment: 'оплата',
      price: 'ціна',
      team: 'особа',
    );

    test('lists empty required fields in form order', () {
      expect(
        missingComboFields(
            product: null,
            region: 1,
            payment: null,
            price: '  ',
            team: 2,
            labels: labels),
        ['культура', 'оплата', 'ціна'],
      );
    });

    test('empty when everything is filled', () {
      expect(
        missingComboFields(
            product: 1,
            region: 1,
            payment: 1,
            price: '9200',
            team: 1,
            labels: labels),
        isEmpty,
      );
    });
  });
}
