import 'dart:developer';

import 'package:agro/model/bids_item_new_model.dart';
import 'package:agro/app/home/order/components/add_price.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/add_banner/add_banner_model.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/feed_item.dart';
import 'package:agro/model/message/created.dart';
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
import 'package:agro/model/model_order/struct_order.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:hive/hive.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/app_input_controller.dart';
import '../../../model/model_order/model_order.dart';
import '../../../ui/local_notification/local_notification.dart';

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
  int page = 1;
  List<BidItem> bids = [];
  List<ModelOrder> modelOrder = [];
  List<Answer> callResults = [];
  List<Message> messages = [];
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

  String get adsPrice => adsDisabledUntil == 0 ? '150 грн' : '300 грн';

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
    page = 1;
    modelOrder = [];
    bidsOffset = 0; // додати
    bids = []; // додати
    loadRequest();
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
        log('⚪ loadRequest() CALLED | role=${modelUser.role} bidsOffset=$bidsOffset bidsLimit=$bidsLimit page=$page');

        await onMessages();

        if (modelUser.role == 'distrib') {
          log('⚪ getAllBids() REQUEST | limit=$bidsLimit offset=$bidsOffset');

          ApiAnswer apiFreeAnswer = await Api().traider.getAllBids(
                limit: bidsLimit,
                offset: bidsOffset,
              );

          //    log('⚪ getAllBids() RAW RESPONSE: ${apiFreeAnswer.data}');

          BidsResponse bidsResponse;
          try {
            bidsResponse = BidsResponse.fromJson(apiFreeAnswer.data);
          } catch (e, s) {
            log('🔴 PARSER ERROR: $e\n$s');
            return;
          }

          log('⚪ getAllBids() PARSED | новых bids=${bidsResponse.bids.length} '
              //       'bids_total(raw)=${apiFreeAnswer.data['bids_total']} '
              //      'bids_fresh_total(raw)=${apiFreeAnswer.data['bids_fresh_total']}'
              );

          setState(() {
            userfield = Map<String, dynamic>.from(
              apiFreeAnswer.data['userfield'] ?? {},
            );
            bidsTotal =
                int.tryParse('${apiFreeAnswer.data['bids_total'] ?? ''}');
            bidsFreshTotal =
                int.tryParse('${apiFreeAnswer.data['bids_fresh_total'] ?? ''}');

            if (bidsOffset == 0) {
              bids = bidsResponse.bids;
            } else {
              bids.addAll(bidsResponse.bids);
            }
            bidsOffset += bidsResponse.bids.length;
          });

          log('⚪ AFTER UPDATE | bidsOffset=$bidsOffset bidsTotal=$bidsTotal '
              'bids.length=${bids.length} hasMoreBids=$hasMoreBids');

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
    final List<Created> list = [];
    final splitedMessage =
        messages.splitMatch((element) => (element.readed ?? 0) == 0);
    list.addAll(splitedMessage.matched);

    final List<Created> tale = [];
    tale.addAll(bids);

    // Межа: найстаріший вже завантажений bid (за віком ордера).
    // Поки не всі bids довантажені — не показуємо messages старіші за цю межу,
    // бо там ще МОЖУТЬ бути bids, яких ми просто ще не отримали з бекенду.
    final oldestLoadedBidTimestamp = bids.isEmpty
        ? null
        : bids
            .map((b) => b.orderCreatedAt?.millisecondsSinceEpoch ?? 0)
            .reduce((a, b) => a < b ? a : b);

    final visibleMessages = (hasMoreBids && oldestLoadedBidTimestamp != null)
        ? splitedMessage.unmatched.where((m) =>
            (m.createdAt?.millisecondsSinceEpoch ?? 0) >=
            oldestLoadedBidTimestamp)
        : splitedMessage.unmatched; // всі bids вже завантажені — показуємо все

    tale.addAll(visibleMessages);
    tale.sort((a, b) => _sortTimestamp(b).compareTo(_sortTimestamp(a)));
    list.addAll(tale);
    setState(() => combinedList = list);
  }

  int _sortTimestamp(Created item) {
    if (item is BidItem) {
      return item.orderCreatedAt?.millisecondsSinceEpoch ?? 0;
    }
    return item.createdAt?.millisecondsSinceEpoch ?? 0;
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
    final List<Created> list = [];
    final splitedMessage =
        messages.splitMatch((element) => (element.readed ?? 0) == 0);
    list.addAll(splitedMessage.matched);
    final List<Created> tale = [];
    tale.addAll(modelOrder);
    tale.addAll(splitedMessage.unmatched);
    tale.sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
        .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
    list.addAll(tale);
    setState(() {
      combinedList = list;
    });
  }

  void onLoadData() async {
    log('🟢 onLoadData() STARTED | hasMoreBids=$hasMoreBids bidsOffset=$bidsOffset bidsTotal=$bidsTotal bids.length=${bids.length}');

    if (modelUser.role == 'distrib' && !hasMoreBids) {
      log('🟡 onLoadData() -> loadNoData() (hasMoreBids=false)');
      controllerLoading.loadNoData();
      return;
    }

    try {
      await loadRequest();
      log('🟢 onLoadData() SUCCESS | bidsOffset=$bidsOffset bidsTotal=$bidsTotal bids.length=${bids.length}');
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

  onReadMessage(Message message) async {
    await Api().traider.readMessage(message.id);
    log("read message ${message.id}");
    await onMessages();
    onCombineList();
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

  Future<void> onMessages() async {
    try {
      ApiAnswer apiAnswer = await Api().traider.getMessages();
      messages.clear();
      for (final i in apiAnswer.data) {
        messages.add(Message.fromJson(i));
      }
    } catch (e) {
      log(e.toString(), error: e);
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

      if (item is Message) {
        result.add(FeedMessageItem(item));
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
    final q = searchController.text.trim().toLowerCase();

    if (q.isEmpty) return combinedList;

    return combinedList.where((item) {
      if (item is BidItem) {
        final title = (item.productTitle ?? '').toLowerCase();
        final region = (item.regionName ?? '').toLowerCase();

        return title.contains(q) || region.contains(q);
      }

      if (item is ModelOrder) {
        final title = (item.title ?? '').toLowerCase();

        return title.contains(q);
      }

      if (item is Message) {
        // 🔥 важливо: прибираємо messages з search
        return false;
      }

      return false;
    }).toList();
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

extension SplitMatch<T> on List<T> {
  ListMatch<T> splitMatch(bool Function(T element) matchFunction) {
    final listMatch = ListMatch<T>();

    for (final element in this) {
      if (matchFunction(element)) {
        listMatch.matched.add(element);
      } else {
        listMatch.unmatched.add(element);
      }
    }

    return listMatch;
  }
}

class ListMatch<T> {
  List<T> matched = <T>[];
  List<T> unmatched = <T>[];
}
