import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/model_order/struct_order.dart';
import 'package:agro/server/api/api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/model/model_order/model_contact.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/ui/adds.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:hive/hive.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../controllers/app_input_controller.dart';
import '../../../model/model_order/model_order.dart';
import '../../../ui/local_notification/local_notification.dart';

class AllApplicationsController extends BaseController {
  late Function(VoidCallback fn) setState;
  late BuildContext context;
  late TextEditingController searchController;
  late ModelUser modelUser;
  late final RefreshController controllerLoading;
  late final ScrollController controllerScroll;
  String? messHeader;
  final localStorageRepository = LocalStorageRepository();
  final _interstitial = Interstitial();
  int page = 1;
  List<ModelOrder> modelOrder = [];
  List<Answer> callResults = [];
  List<Message> messages = [];
  Tariff? tariff;

  @override
  void onInit() {
    searchController = AppInputController();
    controllerLoading = RefreshController();
    controllerScroll = ScrollController();
    super.onInit();
  }

  void initPage(
      {required BuildContext context,
      required Function(VoidCallback fn) set}) async {
    this.context = context;
    setState = set;
    modelUser = Hive.box('data').get('modelUser');

    setState(() => page = 1);
    await Future.delayed(const Duration(milliseconds: 100));
    modelOrder = [];
    onTariffInfo();
    loadRequest();
  }

  void loadRequest() => loadIfValid(() async {
        ApiAnswer apiAnswer = await Api()
            .traider
            .getAllOrders(page: page, limit: 50, search: searchController.text);

        log(apiAnswer.data.toString());
        callResults = await localStorageRepository.getAll();
        setState(() {
          if (context.mounted) {
              for (final i in apiAnswer.data['orders']) {
                modelOrder.add(structOrderData(data: i));
              }
              page++;
          }
        });
        log('modelOrder.length: ${modelOrder.length}');
      });

  void onLaunchPhone(BuildContext context, ModelContact contact) =>
      showCupertinoModalBottomSheet(
          topRadius: const Radius.circular(30),
          context: context,
          builder: (c) => LaunchPhone(contact: contact.userPhone));

  void onSearch() {
    page = 1;
    modelOrder = [];
    loadRequest();
  }

  void onLoadData() {
    loadRequest();
    controllerLoading.loadComplete();
  }

  Future<void> onContactClick(ModelOrder order, BuildContext context) async {
    if (order.contact == null) {
      try {
        if (tariff?.isPremium == false || tariff?.isVip == false) {
          await _interstitial.loadRewardedAd(doAfter: () async {
            var contact = await onLoadInfoUser(order);
            onContactOpened(order);
            setState(() {
              modelOrder
                  .firstWhere((element) => element.id == order.id)
                  .contact = contact;
            });
          }, onFailed: () async {
            await Future.delayed(const Duration(milliseconds: 100));
            var contact = await onLoadInfoUser(order);
            onContactOpened(order);
            setState(() {
              modelOrder
                  .firstWhere((element) => element.id == order.id)
                  .contact = contact;
            });
          });
        } else {
          var contact = await onLoadInfoUser(order);
          onContactOpened(order);
          setState(() {
            modelOrder.firstWhere((element) => element.id == order.id).contact =
                contact;
          });
        }
      } catch (e) {
        if (context.mounted) {
          notification(text: context.l.errorTariffMail);
        }
        log("contact doesn't opened");
      }
    }
  }

  Future<ModelContact> onLoadInfoUser(ModelOrder order) async {
    ApiAnswer apiAnswer =
        await Api().traider.orderOpenContactFermer(orderId: order.id!);

    var contact = ModelContact();
    contact.userName = apiAnswer.data['payload']['name'];
    contact.userRegion = apiAnswer.data['payload']['region'];
    contact.userDistrict = apiAnswer.data['payload']['district'];
    contact.userCity = apiAnswer.data['payload']['city'];
    contact.userEmail = apiAnswer.data['payload']['email'];
    contact.userPhone = apiAnswer.data['payload']['phone'];
    return contact;
  }

  void updateCallResults() async {
    log('callResults.length: ${callResults.length}');
    callResults = await localStorageRepository.getAll();
  }

  onPageOrderFermer({required ModelOrder model}) async {
    model.request = true;
    var data = await Get.toNamed(Routes.orderInfo, arguments: [model.id]);

    if (data != null) {
      model = data as ModelOrder;
    }
    setState(() {});
  }

  onContactOpened(ModelOrder order) {
    modelOrder.firstWhere((element) => element.id == order.id).request = true;
    setState(() {});
  }

  void onRefresh() {
    setState(() {
      page = 0;

      modelOrder = [];
    });
    loadRequest();
    controllerLoading.refreshCompleted();
  }

  void onTariffInfo() async {
    try {
      ApiAnswer apiAnswer = await Api().traider.getTariff();
      setState(() {
        tariff = Tariff.fromJson(apiAnswer.data['payload']);
      });
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> launchMap(
      BuildContext context, ModelContact contact, String id) async {
    if (tariff?.isFree == false) {
      final region = contact.userRegion;
      final district = contact.userDistrict;
      final city = contact.userCity;

      if (region == null ||
          region.isEmpty ||
          district == null ||
          district.isEmpty ||
          city == null ||
          city.isEmpty) {
        notification(text: context.l.waitAddress);
        await Api().common.sendMessageToBot(
            "${context.l.nomber} ${modelUser.phone} ${context.l.requestingAddress} $id ${context.l.correctAddress}");
      } else {
        final query = '$city $region $district';
        MapsLauncher.launchQuery(query);
      }
    } else {
      notification(text: context.l.mapForPaid);
    }
  }
}
