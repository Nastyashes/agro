import 'dart:developer';
import 'package:agro/app/bid_detail/components/launch_phone.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:get/get.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/model/model_order/application.dart';
import 'package:agro/server/api/api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

import 'package:agro/ui/local_notification/local_notification.dart';

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
  AdBannerModel? adBanner;

  List<BidItem> bids = [];
  List<BidItem> bidsFresh = [];

  // 🔽 пагінація для bidsFresh
  int bidsFreshOffset = 0;
  static const int bidsFreshLimit = 20;
  int? bidsFreshTotal;

  bool get hasMoreBidsFresh =>
      bidsFreshTotal == null || bidsFresh.length < bidsFreshTotal!;

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
    bidsFreshOffset = 0;
    bidsFresh = [];
    onTariffInfo();
    loadRequest();
    loadAdBanner();
  }

  bool get isFree => tariff?.isFree == true;
  bool get isAdsDisabled => userfield['is_ads_disabled'] == true;
  bool get shouldShowAds => isFree && !isAdsDisabled;
  int get adsDisabledUntil => userfield['ads_disabled_until'] ?? 0;

  Future<void> loadAdBanner() async {
    try {
      final apiAnswer = await Api().traider.getAdBanner();
      log('Ad banner loaded: ${apiAnswer?.image}');
      adBanner = apiAnswer;
    } catch (_) {
      adBanner = null;
    }
  }

 Future<void> loadRequest() => loadIfValid(() async {
      try {
        ApiAnswer apiFreeAnswer = await Api().traider.getAllBids(
              limit: bidsFreshLimit,
              offset: bidsFreshOffset,
            );

        final bidsResponse = BidsResponse.fromJson(apiFreeAnswer.data);

        setState(() {
          if (context.mounted) {
            bids = bidsResponse.bids;

            if (bidsFreshOffset == 0) {
              bidsFresh = bidsResponse.bidsFresh;
            } else {
              bidsFresh.addAll(bidsResponse.bidsFresh);
            }
            bidsFreshOffset += bidsResponse.bidsFresh.length;

            userfield = Map<String, dynamic>.from(
              apiFreeAnswer.data['userfield'] ?? {},
            );

            bidsFreshTotal = int.tryParse(
                '${apiFreeAnswer.data['bids_fresh_total'] ?? ''}');

            page++;
          }
        });
      } catch (e, s) {
        log('🔴 loadRequest FAILED: $e\n$s');
        if (context.mounted) {
          notification(text: context.l.somethingWentWrong);
        }
        rethrow; // 🔥 прокидуємо далі, щоб onLoadData/onRefresh отримали loadFailed()
      }
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
    bidsFreshOffset = 0;
    bidsFresh = [];
    loadRequest();
  }

  void onLoadData() {
    if (!hasMoreBidsFresh) {
      controllerLoading.loadNoData();
      return;
    }
    loadRequest();
    controllerLoading.loadComplete();
  }

  void onRefresh() {
    setState(() {
      bidsFreshOffset = 0;
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