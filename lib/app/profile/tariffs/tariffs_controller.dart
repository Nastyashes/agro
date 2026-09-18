import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class TariffsController extends BaseController {
   late Function(VoidCallback fn) setState;

  final MainController mainController = Get.find<MainController>();

  ModelUser? modelUser;
  int currentPageIndex = 0;
  bool buyButtonVisible = false;
  List<ModelTariff> tariffs = [];

  Tariff? get tariff => mainController.tariff;


  Future<void> initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) async {
    setState = set;
    modelUser = Hive.box('data').get('modelUser');

    await getTariffs();

    if (mainController.tariff == null) {
      await mainController.initUserData();
    }

    if (context.mounted) {
      setState(() {
        currentPageIndex = 0;
        buyButtonVisible = getBuyButtonVisible(0, tariff);
      });
    }
  }

  Future<void> getTariffs() async {
    try {
      final ApiAnswer apiAnswer = await Api().common.getTariffs();

      tariffs.clear();

      for (final item in apiAnswer.data['items']) {
        tariffs.add(structTariffData(data: item));
      }
    } catch (e, stackTrace) {
      log(
        'getTariffs error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  void onPageChanged(int page) {
    setState(() {
      currentPageIndex = page;
      buyButtonVisible = getBuyButtonVisible(page, tariff);
    });
  }

  void onBuyTariff(String tariff) {
    openTelegram(text: tariff);
  }

  Future<void> openTelegram({
    required String text,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    String url =
        'https://t.me/uagro_admin?text=Доброго дня. Хочу придбати пакет "$text" ';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
      );
    } else {
      throw Exception('openTelegram could not launching url: $url');
    }
  }

  Future<void> onPayTariff(ModelTariff tariff, BuildContext context) async {
    try {
      final rawPrice = tariff.price ?? '';

      final normalized = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.tryParse(normalized) ?? 0;

      final apiAnswer = await Api().common.tariffPay(
            amount: amount,
          );

      if (apiAnswer.data == null || apiAnswer.data is! Map) {
        if (context.mounted) {
          notification(text: context.l.somethingWentWrong);
        }
        return;
      }

      if (apiAnswer.data['error'] != null) {
        if (context.mounted) {
          log('Error: ${apiAnswer.data['error']}');
          notification(text: context.l.somethingWentWrong);
        }
      } else {
        final String payUrl = apiAnswer.data['pay_url'];

        if (await canLaunchUrl(Uri.parse(payUrl))) {
          await launchUrl(Uri.parse(payUrl));
        } else {
          throw Exception('Could not launch pay_url: $payUrl');
        }

        log('Order ID: ${apiAnswer.data['order_id']}');
      }
    } catch (e) {
      if (context.mounted) {
        log('Error purchasing tariff: ${e.toString()}', error: e);
        notification(text: context.l.somethingWentWrong);
      }
    }
  }


  bool getBuyButtonVisible(int index, Tariff? tariff) {
    switch (index) {
      case 0:
        return (tariff?.isVip == false && tariff?.isPremium == false) ||
            tariff?.isFree == true;
      case 1:
        return tariff?.isFree != false ||
            (tariff?.isPremium != true && tariff?.isVip != true);
      case 2:
        return tariff?.isVip != true;
    }
    return true;
  }

  void onBack(BuildContext context) => Navigator.pop(context);
}
