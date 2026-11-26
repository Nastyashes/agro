import 'package:agro/app/new_home_screen/drawer/app_menu_drawer.dart';
import 'package:agro/app/new_home_screen/drawer/menu_item.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/app/new_home_screen/widgets/home_header.dart';
import 'package:agro/app/new_home_screen/widgets/home_tabs.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/components/app_filter_chip.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/product_type.dart';
import 'package:agro/ui/theme/app_theme.dart';
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

/// Contract: «Незабаром» menu items never navigate, only explain; hidden
/// items stay hidden; the header shows the tariff, unread dot and top-up;
/// Fresh chips only for the free tariff; sphere ids map to product types.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('ProductType', () {
    test('maps API sphere ids', () {
      expect(ProductType.fromSphere(15), ProductType.grain);
      expect(ProductType.fromSphere(12), ProductType.fertilizer);
      expect(ProductType.fromSphere(13), ProductType.seeds);
      expect(ProductType.fromSphere(14), ProductType.oil);
      expect(ProductType.fromSphere(null), ProductType.unknown);
      expect(ProductType.fromSphere(99), ProductType.unknown);
    });
  });

  group('AppMenuDrawer', () {
    late List<String> calls;

    Future<void> pump(WidgetTester tester,
        {bool myPrice = true, bool tariffs = true, bool ads = true}) async {
      calls = [];
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(AppMenuDrawer(
        userName: 'Іван',
        phone: '+380',
        tariffLabel: 'Free',
        balance: 29,
        unreadNotifications: 3,
        showMyPrice: myPrice,
        showDeals: myPrice,
        showTariffs: tariffs,
        showDisableAds: ads,
        onComingSoon: (s) => calls.add('soon:${s.description.isNotEmpty}'),
        onMyPrice: () => calls.add('myPrice'),
        onInfoMessages: () => calls.add('messages'),
        onTopUp: () => calls.add('topUp'),
        onTariffs: () => calls.add('tariffs'),
        onLogout: () => calls.add('logout'),
        onDisableAds: () => calls.add('ads'),
      )));
    }

    testWidgets('no delete-profile action unless it is wired', (tester) async {
      await pump(tester);
      expect(find.text('Видалити профіль'), findsNothing);
      expect(find.text('Вийти'), findsOneWidget);
    });

    testWidgets('coming-soon items only call onComingSoon', (tester) async {
      await pump(tester);
      for (final t in ['Прийомка', 'Мої заявки', 'Збережені']) {
        await tester.tap(find.text(t));
      }
      expect(calls, ['soon:true', 'soon:true', 'soon:true']);
      expect(find.text('Незабаром'), findsNWidgets(3));
    });

    testWidgets('real items navigate; unread count is shown', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Моя ціна'));
      await tester.tap(find.text('Повідомлення'));
      await tester.tap(find.text('Поповнити'));
      await tester.tap(find.text('Вийти'));
      expect(calls, ['myPrice', 'messages', 'topUp', 'logout']);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Нове'), findsOneWidget);
    });

    testWidgets('hidden items stay hidden', (tester) async {
      await pump(tester, myPrice: false, tariffs: false, ads: false);
      expect(find.text('Моя ціна'), findsNothing);
      expect(find.text('Угоди'), findsNothing);
      expect(find.text('Тарифи'), findsNothing);
      expect(find.textContaining('Вимкнути рекламу'), findsNothing);
    });

    testWidgets('disable ads shows the price and only calls back',
        (tester) async {
      await pump(tester);
      await tester.tap(find.textContaining('Вимкнути рекламу'));
      expect(calls, ['ads']);
      expect(find.textContaining('150'), findsOneWidget);
    });
  });

  testWidgets('MenuItem soon is muted with a label', (tester) async {
    await tester.pumpWidget(app(const MenuItem(
        icon: Icons.warehouse_outlined,
        title: 'Прийомка',
        mark: MenuItemMark.soon,
        onPressed: null)));
    expect(find.text('Незабаром'), findsOneWidget);
  });

  group('HomeHeader', () {
    late List<String> calls;

    Future<void> pump(WidgetTester tester,
        {int unread = 0, bool search = false, Tariff? tariff}) async {
      calls = [];
      await tester.pumpWidget(app(HomeHeader(
        balance: 29,
        tariff: tariff,
        unreadCount: unread,
        isSearchOpen: search,
        searchController: TextEditingController(),
        onMenu: () => calls.add('menu'),
        onTopUp: () => calls.add('topUp'),
        onToggleSearch: () => calls.add('search'),
        onSearchChanged: (_) {},
      )));
    }

    testWidgets('balance, Free tag and actions', (tester) async {
      await pump(tester, tariff: Tariff.fromJson(const {'is_vip': 'N'}));
      expect(find.text('29 грн'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.byType(UnreadDot), findsNothing);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.tap(find.byIcon(Icons.account_balance_wallet_rounded));
      await tester.tap(find.byIcon(Icons.search_rounded));
      expect(calls, ['menu', 'topUp', 'search']);
    });

    testWidgets('active VIP shows its tag and end date', (tester) async {
      await pump(tester,
          tariff: Tariff.fromJson(const {
            'is_vip': 'Y',
            'balance_end': '31.12.2099',
          }));
      expect(find.text('VIP'), findsOneWidget);
      expect(find.textContaining('до '), findsOneWidget);
    });

    testWidgets('unread messages show a dot', (tester) async {
      await pump(tester, unread: 2);
      expect(find.byType(UnreadDot), findsOneWidget);
    });

    testWidgets('search mode hides the balance and the wallet', (tester) async {
      await pump(tester, search: true);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('29 грн'), findsNothing);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsNothing);
    });
  });

  group('HomeTabs', () {
    testWidgets('paid tariff: title and count, no chips', (tester) async {
      await tester.pumpWidget(app(HomeTabs(
          allCount: 68,
          selectedTab: NewHomeTab.all,
          showFresh: false,
          onChanged: (_) {})));
      expect(find.text('Заявки'), findsOneWidget);
      expect(find.text('68'), findsOneWidget);
      expect(find.byType(AppFilterChip), findsNothing);
    });

    testWidgets('free tariff: chips switch the tab', (tester) async {
      final picked = <NewHomeTab>[];
      await tester.pumpWidget(app(HomeTabs(
          selectedTab: NewHomeTab.all,
          showFresh: true,
          onChanged: picked.add)));
      await tester.tap(find.text('Свіжі'));
      await tester.tap(find.text('Всі'));
      expect(picked, [NewHomeTab.fresh, NewHomeTab.all]);
    });
  });
}
