import 'dart:io';

import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/controllers/session_end.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Home controller without its network start-up and disposal.
class _Home extends NewHomeController {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  void onClose() {}
}

/// Contract (BUG-005/018): logout, a deleted profile and an expired token
/// end the session the same way. Nothing of the old account stays in
/// storage or memory; an expired token keeps country and language; several
/// calls at once (many 401s) run it once.
void main() {
  late Directory dir;
  final storage = SessionStorage.instance;

  setUpAll(() async {
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('session_end_test');
    Hive.init(dir.path);
    Hive.registerAdapter(ModelUserAdapter());
    await Hive.openBox('data');
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  late MainController main;
  late List<String> opened;

  Future<void> pumpApp(WidgetTester tester) async {
    Get.reset();
    main = MainController()..updateBalance(500);
    Get.put<MainController>(main);
    Get.put<NewHomeController>(_Home(), permanent: true);
    opened = [];
    Widget page(String name) => Builder(builder: (_) {
          opened.add(name);
          return Text(name);
        });
    await tester.runAsync(() async {
      await storage.saveUser(ModelUser(token: 'tok', role: 'distrib'));
      await storage.saveCountry('kazakhstan');
      await storage.saveLanguage('kk');
    });
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => page('home')),
        GetPage(name: '/auth', page: () => page('auth')),
        GetPage(name: '/splash', page: () => page('splash')),
      ],
    ));
    await tester.pumpAndSettle();
    opened.clear();
  }

  Future<void> end(WidgetTester tester,
      {required bool keepCountry, required String route}) async {
    await tester
        .runAsync(() => endSession(keepCountry: keepCountry, route: route));
    await tester.pumpAndSettle();
  }

  testWidgets('expired token: signed out, country and language kept',
      (tester) async {
    await pumpApp(tester);

    await end(tester, keepCountry: true, route: '/auth');

    expect(storage.user, isNull);
    expect(storage.hasSession, isFalse);
    expect(storage.country, 'kazakhstan');
    expect(storage.language, 'kk');
    expect(main.balance, 0);
    expect(Get.isRegistered<NewHomeController>(), isFalse);
    expect(find.text('auth'), findsOneWidget);
    expect(find.text('home'), findsNothing, reason: 'no way back');
  });

  testWidgets('logout: everything is forgotten', (tester) async {
    await pumpApp(tester);

    await end(tester, keepCountry: false, route: '/splash');

    expect(storage.user, isNull);
    expect(storage.country, isNull);
    expect(storage.language, 'en');
    expect(main.balance, 0);
    expect(Get.isRegistered<NewHomeController>(), isFalse);
    expect(find.text('splash'), findsOneWidget);
  });

  testWidgets('several 401s at once end the session once', (tester) async {
    await pumpApp(tester);

    await tester.runAsync(() => Future.wait([
          endSession(keepCountry: true, route: '/auth'),
          endSession(keepCountry: true, route: '/auth'),
          endSession(keepCountry: false, route: '/splash'),
        ]));
    await tester.pumpAndSettle();

    expect(opened, ['auth']);
    expect(storage.country, 'kazakhstan', reason: 'later calls ignored');

    // A later, separate end still works.
    await end(tester, keepCountry: false, route: '/splash');
    expect(find.text('splash'), findsOneWidget);
  });
}
