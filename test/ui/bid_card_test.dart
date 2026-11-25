import 'dart:async';
import 'dart:io';

import 'package:agro/app/bid_detail/bid_controller.dart';
import 'package:agro/data/repositories/bids_repository.dart';

import 'package:agro/app/new_home_screen/drawer/bid_list_item.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/ui/components/app_icon_button.dart';
import 'package:agro/ui/components/product_type.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class GatedBids extends BidsRepository {
  final gate = Completer<void>();
  int opens = 0;

  @override
  Future<OrderView> view(int orderId) async => const OrderView();

  @override
  Future<OpenContactResult> openContact(int orderId) async {
    opens++;
    await gate.future;
    return const OpenContactResult(OpenContactStatus.failed);
  }
}

class PaidMain extends MainController {
  @override
  bool get isFree => false;
}

/// Contract: a closed bid offers one paid action with its price and a way
/// to the details; an opened bid shows the seller and a call button and
/// never offers to pay again; fresh bids are marked.
void main() {
  late Directory dir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('bid_card_test');
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

  late List<int?> pressed;

  Future<void> pump(WidgetTester tester, BidItem item,
      {bool fresh = false, BidItemController? actions}) async {
    pressed = [];
    await tester.pumpWidget(GetMaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SingleChildScrollView(
          child: BidListItem(
            isFresh: fresh,
            bidItem: item,
            onPressed: ({required model}) => pressed.add(model.orderId),
            actions: actions,
          ),
        ),
      ),
    ));
  }

  final closed = BidItem(
    orderId: 191114,
    sphereId: 15,
    productTitle: 'Соя',
    amount: 100,
    year: 2026,
    regionName: 'Житомирська',
    dayLabel: '6 днів',
    contactPrice: 25,
    opened: 0,
  );

  testWidgets('closed bid: type, numbers, paid contact and details',
      (tester) async {
    await pump(tester, closed);

    expect(find.byType(TypeBadge), findsOneWidget);
    expect(find.text('Зерно'), findsOneWidget);
    expect(find.text('№191114 · Житомирська'), findsOneWidget);
    expect(find.text('Соя'), findsOneWidget);
    expect(find.text('урожай 2026'), findsOneWidget);
    expect(find.text('6 днів'), findsOneWidget);
    expect(find.text('Відкрити контакт · 25 ₴'), findsOneWidget);
    expect(find.byIcon(Icons.call_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    expect(pressed, [191114]);
  });

  testWidgets('fresh bid is marked', (tester) async {
    await pump(tester, closed, fresh: true);
    expect(find.text('Свіжа'), findsOneWidget);
    expect(find.text('6 днів'), findsNothing);
  });

  testWidgets('opened bid: seller and call, no paid button', (tester) async {
    await pump(
      tester,
      closed.copyWith(
        opened: 1,
        fermerName: 'Петренко Іван',
        fermerCompany: 'ФГ «Колос»',
        contacts: BidContacts(phone: '+380671234567'),
      ),
    );

    expect(find.text('Петренко Іван · ФГ «Колос»'), findsOneWidget);
    expect(find.text('+380671234567'), findsOneWidget);
    expect(
        find.widgetWithIcon(AppIconButton, Icons.call_rounded), findsOneWidget);
    expect(find.textContaining('Відкрити контакт'), findsNothing);
  });

  testWidgets('a double tap on the paid contact sends one request',
      (tester) async {
    final bids = GatedBids();
    await pump(tester, closed,
        actions: BidItemController(bids: bids, mainController: PaidMain()));

    await tester.tap(find.text('Відкрити контакт · 25 ₴'));
    await tester.pump();
    // Now loading: the label is replaced by a spinner and taps are ignored.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(CircularProgressIndicator),
        warnIfMissed: false);
    await tester.pump();
    expect(bids.opens, 1);

    bids.gate.complete();
    await tester.pump();
    expect(find.text('Відкрити контакт · 25 ₴'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // let the snackbar go
    await tester.pumpAndSettle();
  });

  testWidgets('copy is only for distributors on grain or fertilizer',
      (tester) async {
    final home = Get.find<NewHomeController>();

    home.modelUser = ModelUser(role: 'farmer');
    await pump(tester, closed);
    expect(find.byIcon(Icons.copy_rounded), findsNothing);

    home.modelUser = ModelUser(role: 'distrib');
    await tester.pumpWidget(const SizedBox());
    await pump(tester, closed);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pump(tester, BidItem(orderId: 1, sphereId: 13, productTitle: 'x'));
    expect(find.byIcon(Icons.copy_rounded), findsNothing);
  });
}
