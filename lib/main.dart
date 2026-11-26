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
import 'package:agro/ui/theme/app_theme.dart';
import 'package:agro/ui/theme/text_scale.dart';
import 'package:agro/load/start_screen.dart';
import 'package:agro/routes/app_pages.dart';

import 'config/config.dart';
import 'model/model_user/model_user.dart';

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

  runApp(const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GetMaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.transparent));
            return GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: MediaQuery(
                  // Drawn 1:1 so sizes match the design and touch-target
                  // norms; system text size is followed up to 1.3 (BUG-033,
                  // BUG-043).
                  data: MediaQuery.of(context).copyWith(
                      textScaler:
                          appTextScaler(MediaQuery.textScalerOf(context))),
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior(),
                    child: child!,
                  )),
            );
          },
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildAppTheme(),
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
    );
  }
}
