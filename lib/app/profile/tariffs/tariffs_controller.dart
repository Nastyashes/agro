import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class TariffsController extends BaseController {
  late Function(VoidCallback fn) setState;
  late BuildContext context; 
  Tariff? tariff;
  ModelUser? modelUser;
  int currentPageIndex = 0;
  bool buyButtonVisible = false;
  List<ModelTariff> tariffs = [];

  void initPage(
      {required BuildContext context,
      required Function(VoidCallback fn) set}) async {
    setState = set;
    modelUser = Hive.box('data').get('modelUser');

    await Future.delayed(const Duration(milliseconds: 100));
    onTariffInfo();
    getTariffs();
  }

  void onTariffInfo() async {
    try {
      ApiAnswer apiAnswer = await Api().traider.getTariff();
      setState(
        () {
          tariff = Tariff.fromJson(apiAnswer.data['payload']);
          currentPageIndex = 0;
          buyButtonVisible = getBuyButtonVisible(0, tariff);
        },
      );
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  void getTariffs() async {
    try {
      ApiAnswer apiAnswer = await Api().common.getTariffs();
      setState(
        () {
          tariffs.clear();
          for (final item in apiAnswer.data['items']) {
            tariffs.add(structTariffData(data: item));
          }
        },
      );
    } catch (e) {
      log(e.toString(), error: e);
    }
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

  Future<void> onPayTariff(ModelTariff tariff, BuildContext content) async {
    try {
      final apiAnswer = await Api().common.tariffPay(amount: tariff.price ?? 0);

      if (apiAnswer.data['error'] != null){
        if (context.mounted){
        
        log('Error: ${apiAnswer.data['error']}');
        notification(text: content.l.somethingWentWrong);
       
      }} else {
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
      notification(text: content.l.somethingWentWrong);
    }}
  }

  void onPageChanged(int page) {
    setState(() {
      currentPageIndex = page;
      buyButtonVisible = getBuyButtonVisible(page, tariff);
      buyButtonVisible = getBuyButtonVisible(page, tariff);
    });
  }

  bool getBuyButtonVisible(int index, Tariff? tariff) {
    switch (index) {
      case 0:
        return (tariff?.isVip == false &&
                tariff?.isPremium == false &&
                tariff?.isBeslim == false) ||
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
