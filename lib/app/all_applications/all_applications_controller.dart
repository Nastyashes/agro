import 'dart:developer';
import 'package:get/get.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/app/home/components/new_block/bids_item_new_model.dart';
import 'package:agro/model/model_order/application.dart';
import 'package:agro/server/api/api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/model/model_order/model_contact.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../ui/local_notification/local_notification.dart';

class AllApplicationsController extends BaseController {
  late Function(VoidCallback fn) setState;
  late BuildContext context;
  late ModelUser modelUser;
  late final RefreshController controllerLoading;
  late final ScrollController controllerScroll;
  String? messHeader;
  final localStorageRepository = LocalStorageRepository();
  int page = 1;
  List<Application> orders = [];
  Tariff? tariff;
  Map<String, dynamic> userfield = {};

  List<BidItem> bids = [];
  List<BidItem> bidsFresh = [];

  @override
  void onInit() {
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
    orders = [];
    onTariffInfo();
    loadRequest();
  }

  bool get isFree => tariff?.isFree == true;

  bool get isAdsDisabled => userfield['is_ads_disabled'] == true;

  bool get shouldShowAds => isFree && !isAdsDisabled;

  int get adsDisabledUntil => userfield['ads_disabled_until'] ?? 0;
  void loadRequest() => loadIfValid(() async {
        //    ApiAnswer apiAnswer =
        //        await Api().traider.getAllOrders(page: page, limit: 50);

        //    log(apiAnswer.data.toString());
        ApiAnswer apiFreeAnswer = await Api().traider.getFreeOrders();
        final bidsResponse = BidsResponse.fromJson(apiFreeAnswer.data);
        setState(() {
          if (context.mounted) {
            //     orders.addAll(parseApplications(apiAnswer.data['orders']));
            bids = bidsResponse.bids;
            bidsFresh = bidsResponse.bidsFresh;

            setState(() {
              userfield = Map<String, dynamic>.from(
                apiFreeAnswer.data['userfield'] ?? {},
              );

              log(userfield.toString());
            });
            log('''
  bids NEW

 ${apiFreeAnswer.data['bids'].toString()}


  bidsFresh NEW  
 ${apiFreeAnswer.data['bids_fresh'].toString()}''');
            page++;
          }
        });
        //   log('modelOrder.length: ${orders.length}');
      });

  void onLaunchPhone(BuildContext context, ModelContact contact) =>
      showCupertinoModalBottomSheet(
          topRadius: const Radius.circular(30),
          context: context,
          builder: (c) => LaunchPhone(contact: contact.userPhone));

  void onPageBidItem({required BidItem item}) async {
    await Get.toNamed(Routes.bidItemScreen, arguments: [item]);
    setState(() {});
  }

  void onSearch() {
    page = 1;
    orders = [];
    loadRequest();
  }

  void onLoadData() {
    loadRequest();
    controllerLoading.loadComplete();
  }

  void onRefresh() {
    setState(() {
      bids = [];
      bidsFresh = [];
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

  bool get hasFreshBids => bidsFresh.isNotEmpty;
}
