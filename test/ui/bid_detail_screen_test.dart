import 'dart:io';

import 'package:agro/app/bid_detail/bid_controller.dart';
import 'package:agro/app/bid_detail/bid_detail_screen.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class NoNetworkBids extends BidsRepository {
  int opens = 0, analyses = 0;

  @override
  Future<OrderView> view(int orderId) async => const OrderView();

  @override
  Future<OpenContactResult> openContact(int orderId) async {
    opens++;
    return const OpenContactResult(OpenContactStatus.failed);
  }

  @override
  Future<AnalysisResult> orderAnalysis(int orderId) async {
    analyses++;
    return const AnalysisResult(AnalysisStatus.failed);
  }
}

class CountingMyPrice extends MyPriceApi {
  int quotes = 0;

  @override
  Future<MyPriceResult<MyPriceDealQuote>> dealQuote(
      {required int orderId}) async {
    quotes++;
    return const MyPriceResult(ok: true, data: MyPriceDealQuote(amount: 0));
  }
}

class PaidMain extends MainController {
  @override
  bool get isFree => false;
}

/// Contract: a trader sees the seller locked until the contact is opened
/// and a paid "open contact" action; once opened, the seller, a call
/// button and the carrier/analysis services. Others get no actions.
void main() {
  late Directory dir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('bid_detail_test');
    Hive.init(dir.path);
    Hive.registerAdapter(ModelUserAdapter());
    await Hive.openBox('data');
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(Get.reset);

  final bid = BidItem(
    orderId: 184522,
    sphereId: 15,
    productTitle: 'Пшениця 2 клас',
    amount: 500,
    year: 2025,
    regionName: 'Київська',
    contactPrice: 25,
    opened: 0,
  );

  late NoNetworkBids bids;
  late CountingMyPrice myPrice;
  late BidItemController ctrl;

  Future<void> pump(WidgetTester tester, BidItem item,
      {required String role}) async {
    bids = NoNetworkBids();
    myPrice = CountingMyPrice();
    ctrl = BidItemController(
      bids: bids,
      myPrice: myPrice,
      mainController: PaidMain(),
      withLoader: (action) => action(),
    );
    await tester.runAsync(
        () => SessionStorage.instance.saveUser(ModelUser(role: role)));
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(GetMaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BidDetailScreen(
        item: item,
        controller: ctrl,
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('trader, closed: locked seller and paid open-contact',
      (tester) async {
    await pump(tester, bid, role: 'distrib');

    expect(find.text('Заявка №184522'), findsOneWidget);
    expect(find.text('Пшениця 2 клас'), findsOneWidget);
    expect(find.text('ПІБ, телефон і адреса — після відкриття контакту'),
        findsOneWidget);
    expect(find.text('Відкрити контакт · 25 ₴'), findsOneWidget);
    expect(find.text('Угода'), findsOneWidget);
    expect(find.text('Відгуки'), findsOneWidget);
    // The bottom bar keeps the button height, not the whole screen.
    expect(tester.getSize(find.widgetWithText(AppButton, 'Угода')).height,
        lessThan(80));
    // Paid services appear only after the contact is opened.
    expect(find.text('Аналіз якості'), findsNothing);
    expect(find.text('Замовити перевізника'), findsNothing);
  });

  testWidgets('trader, opened: seller, call and services', (tester) async {
    await pump(
      tester,
      bid.copyWith(
        opened: 1,
        fermerName: 'Петренко Іван',
        contacts: BidContacts(phone: '+380671234567', city: 'Обухів'),
      ),
      role: 'distrib',
    );

    expect(find.text('Петренко Іван'), findsOneWidget);
    expect(find.text('+380671234567'), findsOneWidget);
    expect(find.text('Подзвонити'), findsOneWidget);
    expect(find.textContaining('Відкрити контакт'), findsNothing);
    expect(find.text('Аналіз якості'), findsOneWidget);
    expect(find.text('Замовити перевізника'), findsOneWidget);
  });

  testWidgets('not a trader: no paid actions or services', (tester) async {
    await pump(tester, bid, role: 'farmer');

    expect(find.text('Пшениця 2 клас'), findsOneWidget);
    expect(find.textContaining('Відкрити контакт'), findsNothing);
    expect(find.text('Угода'), findsNothing);
    expect(find.text('Відгуки'), findsNothing);
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5)); // snackbars time out
    await tester.pumpAndSettle();
  }

  testWidgets('"Відкрити контакт" sends one contact request', (tester) async {
    await pump(tester, bid, role: 'distrib');
    await tester.tap(find.text('Відкрити контакт · 25 ₴'));
    await settle(tester);
    expect(bids.opens, 1);
  });

  testWidgets('"Угода" asks for a quote before any charge', (tester) async {
    await pump(tester, bid, role: 'distrib');
    await tester.tap(find.text('Угода'));
    await tester.pump();
    expect(myPrice.quotes, 1);
    // The confirm dialog is up; cancelling charges nothing.
    await tester.tap(find.text('Скасувати'));
    await settle(tester);
  });

  testWidgets('analysis is charged only after the confirm', (tester) async {
    await pump(tester, bid.copyWith(opened: 1), role: 'distrib');

    await tester.tap(find.text('Аналіз якості'));
    await tester.pumpAndSettle();
    expect(find.text('Замовити аналіз якості?'), findsOneWidget);
    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();
    expect(bids.analyses, 0);

    await tester.tap(find.text('Аналіз якості'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Замовити'));
    await settle(tester);
    expect(bids.analyses, 1);
  });
}
