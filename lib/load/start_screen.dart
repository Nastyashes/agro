import 'package:agro/data/session_storage.dart';
import 'dart:developer';

import 'package:agro/load/load_screen.dart';
import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  static const _minVisible = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openApp();
    });
  }

  Future<void> _openApp() async {
    final startedAt = DateTime.now();
    var nextRoute = Routes.country;

    try {
      if (!Hive.isBoxOpen('data')) {
        await Hive.openBox('data');
      }
      if (!mounted) return;

      final session = SessionStorage.instance;
      await session.saveLanguage(AppLocalizations.of(context)?.localeName);

      if (session.hasSession) {
        nextRoute = Routes.app;
      }
    } catch (e, stackTrace) {
      log(
        'StartScreen openApp error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      nextRoute = Routes.country;
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minVisible) {
      await Future.delayed(_minVisible - elapsed);
    }

    if (!mounted) return;
    Get.offAllNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const LoadScreen();
  }
}
