import 'dart:async';
import 'dart:developer';

import 'package:agro/app/bids_pages/components/launch_phone.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/old_code/app/home/order/components/add_price.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/new_models_bids/feed_item_model.dart';
import 'package:agro/model/message/created.dart';
import 'package:agro/model/model_order/model_contact.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/repository/local_storage_repository.dart';
import 'package:agro/old_code/ui/adds.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro/model/model_order/struct_order.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:hive/hive.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agro/controllers/app_input_controller.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:agro/ui/local_notification/local_notification.dart';

class HomeController extends BaseController {
  late Function(VoidCallback fn) setState;
  late BuildContext context;
  late TextEditingController searchController;
  late ModelUser modelUser;
  late final RefreshController controllerLoading;
  late final ScrollController controllerScroll;
  String? messHeader;
  final localStorageRepository = LocalStorageRepository();
  final _interstitial = Interstitial();
    Timer? _searchDebounce;
  int _searchRequestId = 0;
  int page = 1;
  List<BidItem> bids = [];
  List<ModelOrder> modelOrder = [];
  List<Answer> callResults = [];
  List<Created> combinedList = [];
  Tariff? tariff;
  int? balance;
  Map<String, dynamic> userfield = {};
  int bidsOffset = 0;
  static const int bidsLimit = 20;
  int? bidsTotal;
  int? bidsFreshTotal;
  AdBannerModel? adBanner;
  bool get isFree => tariff?.isFree == true;

  bool get isAdsDisabled => userfield['is_ads_disabled'] == true;

  bool get shouldShowAds => isFree && !isAdsDisabled;

  int get adsDisabledUntil =>
      int.tryParse('${userfield['ads_disabled_until'] ?? 0}') ?? 0;

  String get adsPrice => AppConstants.adsPrice;

  bool get hasMoreBids => bidsTotal == null || bids.length < bidsTotal!;

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
    onBalanceInfo();
    loadAdBanner();
    loadRequest();
  }

  void fermerCreateOrder(String message) => loadIfValid(() async {
        ApiAnswer apiAnswer = await Api().fermer.createOrder();

        if (context.mounted) {
          if (apiAnswer.data['status']) {
            notification(
              text: message,
            );
          } else {
            notification(text: apiAnswer.data['message']);
          }
        }
      });

  void onLaunchPhone(BuildContext context, ModelContact contact) =>
      showCupertinoModalBottomSheet(
          topRadius: const Radius.circular(30),
          context: context,
          builder: (c) => LaunchPhone(contact: contact.userPhone));


 void onSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      page = 1;
      modelOrder = [];
      bidsOffset = 0;
      bids = [];
      loadRequest();
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  
  Future<void> disableAds(BuildContext context) async {
    final result = await Api().traider.disableAds();

    if (result.data['status'] == '+') {
      await loadRequest();

      inAppNotification(
        text: result.data['message'],
        c: context,
      );
    } else {
      inAppNotification(
        text: result.data['message'],
        c: context,
      );
    }
  }

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
     //   log('⚪ loadRequest() CALLED | role=${modelUser.role} bidsOffset=$bidsOffset bidsLimit=$bidsLimit page=$page');

      if (modelUser.role == 'distrib') {
 // log('⚪ searchBids() REQUEST | search="${searchController.text}" limit=$bidsLimit offset=$bidsOffset');

  ApiAnswer apiFreeAnswer = await Api().traider.searchBids(
        search: searchController.text,
        limit: bidsLimit,
        offset: bidsOffset,
      );

  if (apiFreeAnswer.data['status'] == '-') {
    log('🔴 searchBids() ERROR: ${apiFreeAnswer.data['error']}');
    if (context.mounted) {
      notification(text: context.l.somethingWentWrong);
    }
    return;
  }

  BidsResponse bidsResponse;
  try {
    bidsResponse = BidsResponse.fromJson(apiFreeAnswer.data);
  } catch (e, s) {
    log('🔴 PARSER ERROR: $e\n$s');
    return;
  }

  setState(() {
    userfield = Map<String, dynamic>.from(
      apiFreeAnswer.data['userfield'] ?? {},
    );
    bidsTotal = int.tryParse('${apiFreeAnswer.data['bids_total'] ?? ''}');
    bidsFreshTotal =
        int.tryParse('${apiFreeAnswer.data['bids_fresh_total'] ?? ''}');

    if (bidsOffset == 0) {
      bids = bidsResponse.bids;
    } else {
      bids.addAll(bidsResponse.bids);
    }
    bidsOffset += bidsResponse.bids.length;
  });

  await onCombineListWithBids();
  return;
}

        ApiAnswer apiAnswer = await Api()
            .fermer
            .getOrderList(page: page, limit: 15, search: searchController.text);

        callResults = await localStorageRepository.getAll();
        setState(() {
          if (context.mounted) {
            if (apiAnswer.data['status']) {
              for (final i in apiAnswer.data['payload']['items']) {
                modelOrder.add(structOrderData(data: i));
              }
              page++;
            }
          }
        });
        await onCombineList();
      });
  Future<void> onCombineListWithBids() async {
    setState(() => combinedList = List<Created>.from(bids));
  }

  void updateBid(BidItem updatedBid) {
    final bidIndex = bids.indexWhere((e) => e.orderId == updatedBid.orderId);

    if (bidIndex != -1) {
      bids[bidIndex] = updatedBid;
    }

    final combinedIndex = combinedList.indexWhere(
      (e) => e is BidItem && e.orderId == updatedBid.orderId,
    );

    if (combinedIndex != -1) {
      combinedList[combinedIndex] = updatedBid;
    }

    setState(() {});
  }

  Future<void> onCombineList() async {
    setState(() {
      combinedList = List<Created>.from(modelOrder);
    });
  }

  void onLoadData() async {
 //  log('🟢 onLoadData() STARTED | hasMoreBids=$hasMoreBids bidsOffset=$bidsOffset bidsTotal=$bidsTotal bids.length=${bids.length}');

    if (modelUser.role == 'distrib' && !hasMoreBids) {
 //     log('🟡 onLoadData() -> loadNoData() (hasMoreBids=false)');
      controllerLoading.loadNoData();
      return;
    }

    try {
      await loadRequest();
    //  log('🟢 onLoadData() SUCCESS | bidsOffset=$bidsOffset bidsTotal=$bidsTotal bids.length=${bids.length}');
      controllerLoading.loadComplete();
    } catch (e, s) {
      log('🔴 onLoadData() FAILED: $e\n$s');
      controllerLoading.loadFailed();
    }

    log('🟢 onLoadData() FINISHED');
  }

  void onRefresh() async {
    log('🔵 onRefresh() STARTED | bidsOffset=$bidsOffset bidsTotal=$bidsTotal bids.length=${bids.length}');

    setState(() {
      page = 0;
      bidsOffset = 0;
      bids = [];
      modelOrder = [];
    });
    try {
      await loadRequest();
      log('🔵 onRefresh() SUCCESS | bidsOffset=$bidsOffset bidsTotal=$bidsTotal bids.length=${bids.length}');

      controllerLoading.refreshCompleted();
    } catch (e, s) {
      log('🔴 onRefresh() FAILED: $e\n$s');

      controllerLoading.refreshFailed();
    }
    log('🔵 onRefresh() FINISHED');
  }

  Future<void> onPayBalance(int? paySum, BuildContext context) async {
    try {
      // 1. нормалізація price
      final amount = paySum ?? 0;

      // 2. виклик API
      final apiAnswer = await Api().common.balancePay(
            amount: amount,
          );

      // 3. базова валідація response
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
        final String payUrl = apiAnswer.data['url'];

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

  void onDeal(ModelOrder order, String errorAgreement) => loadIfValid(() async {
        ApiAnswer apiAnswer = await Api().traider.deal(tenderId: order.id!);

        log(apiAnswer.data.toString());
        if (apiAnswer.data['status'].toString() == 'true') {
          Get.back();
        } else {
          notification(text: errorAgreement);
        }
      });

  void onAddPrice(BuildContext context, ModelOrder order) =>
      showCupertinoModalBottomSheet(
          topRadius: const Radius.circular(30),
          context: context,
          builder: (c) => AddPriceScreen(order: order));

  void onReview(ModelOrder order) =>
      Get.toNamed(Routes.review, arguments: order);

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

  void onPageBidItem({required BidItem item}) async {
    await Get.toNamed(Routes.bidItemScreen, arguments: [item]);
    setState(() {});
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

// HomeController
  void updateBidItemSilently(BidItem updated) {
    final index = bids.indexWhere((e) => e.orderId == updated.orderId);
    if (index != -1) bids[index] = updated;

    final combinedIndex = combinedList.indexWhere(
      (e) => e is BidItem && e.orderId == updated.orderId,
    );
    if (combinedIndex != -1) combinedList[combinedIndex] = updated;

    // НЕ викликаємо setState — весь список не перебудовується,
    // BidListItem вже сам показав контакти локально
  }

  onContactOpened(ModelOrder order) {
    modelOrder.firstWhere((element) => element.id == order.id).request = true;
    setState(() {});
  }

  onContactSought(String orderId) async {
    await Api().common.setOrderReaded(orderId);
    log("read order $orderId");
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

  void onBalanceInfo() async {
    try {
      ApiAnswer apiAnswer = await Api().common.getBalance();
      final data = apiAnswer.data;

      setState(() {
        balance = data['balance'] ?? 0;
      });
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  void updateBidItem(BidItem updated) {
    final index = bids.indexWhere((e) => e.orderId == updated.orderId);

    if (index != -1) {
      bids[index] = updated;
      onCombineListWithBids();
      setState(() {});
    }
  }

  List<FeedItem> getFeed() {
    final result = <FeedItem>[];

    final source = _getFilteredSource();

    int bidCounter = 0;

    for (final item in source) {
      if (item is ModelOrder) {
        result.add(
          FeedOrderItem(
            item,
            callResults.firstWhereOrNull(
              (e) => e.orderId == item.id.toString(),
            ),
          ),
        );
      }

      if (item is BidItem) {
        result.add(FeedBidItem(item));

        bidCounter++;

        // ✅ ONLY ADS RULE
        if (shouldShowAds && bidCounter % 5 == 0) {
          result.add(
            FeedBannerItem(
              adBanner ??
                  const AdBannerModel(
                    image:  'https://uagro.trade/uploads/vipline/6a45509dbb6ba_photo_2026-07-01_20-38-02.jpg',
                    phone: '+380774804040',
                  ),
            ),
          );
        }
      }
    }

    return result;
  }

  List<Created> _getFilteredSource() {
    return combinedList;
  }
  Future<void> launchMap(
      BuildContext context, ModelContact contact, String id) async {
    if (tariff?.isPremium == true || tariff?.isVip == true) {
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
