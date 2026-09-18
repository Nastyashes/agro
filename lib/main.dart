import 'dart:async';
import 'dart:developer';

import 'package:agro/controllers/app_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/firebase_options.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/call_result/call_result.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:agro/load/start_screen.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/vars/model_notifier/user_notifier/user_notifier.dart';

import 'config/config.dart';
import 'model/model_user/model_user.dart';
import 'vars/model_notifier/bottom_menu_notifier/bottom_menu_notifier.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

  unawaited(
    MobileAds.instance.initialize(),
  );

  Get.put<AppController>(
    AppController(),
    permanent: true,
  );

  Get.put<MainController>(
    MainController(),
    permanent: true,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xff14175B),
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xff14175B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  Hive.registerAdapter(ModelUserAdapter());
  Hive.registerAdapter(AnswerAdapter());
  Hive.registerAdapter(CallResultAdapter());

  await Hive.initFlutter();

  try {
    await Hive.openBox<String>('configs');
    await Hive.openBox('data');
  } catch (err) {
    log(err.toString());
  }

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<BottomMenuNotifier>(
            create: (_) => BottomMenuNotifier()),
        ChangeNotifierProvider<UserNotifier>(create: (_) => UserNotifier()),
      ],
      child: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light, child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InAppNotification(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GetMaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.transparent));
            return GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior(),
                    child: ResponsiveWrapper.builder(child,
                        minWidth: 500,
                        defaultScale: true,
                        breakpoints: [
                          const ResponsiveBreakpoint.autoScale(600,
                              name: MOBILE),
                          const ResponsiveBreakpoint.resize(480, name: MOBILE),
                          const ResponsiveBreakpoint.autoScale(800,
                              name: TABLET),
                          const ResponsiveBreakpoint.resize(1000,
                              name: DESKTOP),
                        ]),
                  )),
            );
          },
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          getPages: AppPages.pages(context: context),
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          home: const StartScreen()),
    ));
  }
}
