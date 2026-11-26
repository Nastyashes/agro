import 'dart:io';

import 'package:agro/app/my_price/my_price_screen.dart';
import 'package:agro/app/new_home_screen/drawer/app_menu_drawer.dart';
import 'package:agro/app/new_home_screen/drawer/bid_list_item.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/app/new_home_screen/widgets/home_header.dart';
import 'package:agro/app/new_home_screen/widgets/home_tabs.dart';
import 'package:agro/auth/auth_confirmation/auth_confirmation_screen.dart';
import 'package:agro/auth/auth_confirmation/components/auth_confirmation_controller.dart';
import 'package:agro/auth/auth_screen.dart';
import 'package:agro/auth/components/auth_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

/// Contract: the app is drawn 1:1 (no global down-scaling) and follows the
/// system text size up to 1.3, so the main screens must fit a small phone
/// (320 and 360 wide) at text scale 1.0 and 1.3 without overflow.
void main() {
  late Directory dir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('small_screen_test');
    Hive.init(dir.path);
    Hive.registerAdapter(ModelUserAdapter());
    await Hive.openBox('data');
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() {
    Get.reset();
    Get.put<MainController>(MainController());
    Get.put<NewHomeController>(NewHomeController());
  });

  Future<void> pump(WidgetTester tester, Size size, double scale,
      Widget Function(BuildContext) body) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(GetMaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Builder(builder: body),
    ));
    await tester.pump();
  }

  final bid = BidItem(
    orderId: 191114,
    sphereId: 15,
    productTitle: 'Пшениця 2 клас, урожай нового сезону',
    amount: 12000,
    year: 2026,
    regionName: 'Дніпропетровська',
    dayLabel: '8 днів',
    contactPrice: 75,
    opened: 0,
  );

  final screens = <String, Widget Function(BuildContext)>{
    'home header + tabs + bid card': (_) => Scaffold(
          body: SafeArea(
            child: ListView(children: [
              HomeHeader(
                balance: 123456,
                tariff: Tariff.fromJson(const {'is_vip': 'Y'}),
                unreadCount: 3,
                isSearchOpen: false,
                searchController: TextEditingController(),
                onMenu: () {},
                onTopUp: () {},
                onToggleSearch: () {},
                onSearchChanged: (_) {},
              ),
              HomeTabs(
                allCount: 1064,
                selectedTab: NewHomeTab.all,
                showFresh: true,
                onChanged: (_) {},
              ),
              BidListItem(
                isFresh: false,
                bidItem: bid,
                onPressed: ({required model}) {},
              ),
              BidListItem(
                isFresh: true,
                bidItem: bid,
                onPressed: ({required model}) {},
              ),
            ]),
          ),
        ),
    'menu drawer': (context) => Scaffold(
          body: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.85,
            child: Drawer(
              child: AppMenuDrawer(
                userName: 'Олександра Костянтинівна Ярошенко',
                phone: '+380 99 002 62 22',
                tariffLabel: 'Premium',
                balance: 123456,
                unreadNotifications: 12,
                showMyPrice: true,
                showDeals: true,
                showTariffs: true,
                showDisableAds: true,
                adsPrice: '150',
                onComingSoon: (_) {},
              ),
            ),
          ),
        ),
    'my price card': (_) => Scaffold(
          body: ListView(children: [
            CombinationCard(
              entry:
                  const MyPriceEntry(status: 'active', pricePerTon: 12345678.5),
              productName: 'Пшениця 2 клас, урожай нового сезону',
              regionName: 'Дніпропетровська',
              paymentName: '1ф. (по перерахунку)',
              reservation: false,
              onEdit: () {},
              onDelete: () {},
            ),
          ]),
        ),
    'login': (_) {
      Get.put(AuthController());
      return const AuthScreen();
    },
    'code': (_) {
      Get.put(AuthConfirmationController());
      return const AuthConfirmScreen();
    },
  };

  for (final size in const [Size(320, 640), Size(360, 780)]) {
    for (final scale in const [1.0, 1.3]) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} fits ${size.width.toInt()} wide at $scale',
            (tester) async {
          await pump(tester, size, scale, entry.value);
          expect(tester.takeException(), isNull);
          // Keyboard up (BUG-042).
          tester.view.viewInsets = const FakeViewPadding(bottom: 900);
          addTearDown(tester.view.resetViewInsets);
          await tester.pump();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
