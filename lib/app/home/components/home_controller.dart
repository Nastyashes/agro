import 'dart:developer';

import 'package:agro/app/home/components/new_block/bids_item_new_model.dart';
import 'package:agro/app/home/order/components/add_price.dart';
import 'package:agro/app/home/order/components/launch_phone.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/answer/answer.dart';
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
    loadRequest();
  }

  bool get isFree => tariff?.isFree == true;

  bool get isAdsDisabled => userfield['is_ads_disabled'] == true;

  bool get shouldShowAds => isFree && !isAdsDisabled;

  int get adsDisabledUntil => userfield['ads_disabled_until'] ?? 0;
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
    loadRequest();
  }

  void loadRequest() => loadIfValid(() async {
        await onMessages();
        late ApiAnswer apiAnswer;

        if (modelUser.role == 'distrib') {
          ApiAnswer apiFreeAnswer = await Api().traider.getFreeOrders();
          final bidsResponse = BidsResponse.fromJson(apiFreeAnswer.data);
          log(apiFreeAnswer.data['bids'].toString());
          setState(() {
            userfield = Map<String, dynamic>.from(
              apiFreeAnswer.data['userfield'] ?? {},
            );

            log(userfield.toString());
          });
          bids = bidsResponse.bids;
          await onCombineListWithBids();
          return;
        } else {
          apiAnswer = await Api().fermer.getOrderList(
              page: page, limit: 15, search: searchController.text);
        }

        log(apiAnswer.data.toString());
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
        //   log('modelOrder.length: ${modelOrder.length}');
        await onCombineList();
      });
  Future<void> onCombineListWithBids() async {
    final List<Created> list = [];
    final splitedMessage =
        messages.splitMatch((element) => (element.readed ?? 0) == 0);
    list.addAll(splitedMessage.matched);

    final List<Created> tale = [];
    tale.addAll(bids);
    tale.addAll(splitedMessage.unmatched);
    tale.sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
        .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
    list.addAll(tale);
    setState(() => combinedList = list);
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

  void onLoadData() {
    loadRequest();
    controllerLoading.loadComplete();
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

  void onRefresh() {
    setState(() {
      page = 0;
      bids = [];
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
