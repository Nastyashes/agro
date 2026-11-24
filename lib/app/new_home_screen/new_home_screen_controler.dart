import 'dart:async';
import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/data/repositories/messages_repository.dart';
import 'package:agro/controllers/app_input_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';


enum NewHomeTab {
  all,
  fresh,
}

class NewHomeController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  final MainController mainController = Get.find<MainController>();

  late final TextEditingController searchController;
  late final FocusNode searchFocusNode;

  bool isSearchOpen = false;

  late final RefreshController allRefreshController;
  late final RefreshController freshRefreshController;

  late final ScrollController allScrollController;
  late final ScrollController freshScrollController;

  late ModelUser modelUser;

  NewHomeTab selectedTab = NewHomeTab.all;


  // =========================
  // ALL BIDS
  // =========================

  final List<BidItem> bids = [];

  int _bidsOffset = 0;
  int? _bidsTotal;

  bool _loadingAll = false;

  /// Incremented on every request; responses from superseded requests
  /// (e.g. an older search query) are discarded.
  int _allRequestId = 0;

  bool get hasMoreBids =>
      _bidsTotal == null || bids.length < _bidsTotal!;

  // =========================
  // FRESH BIDS
  // =========================

  final List<BidItem> bidsFresh = [];

  int _freshOffset = 0;
  int? _freshTotal;

  bool _loadingFresh = false;

  bool get hasMoreFresh =>
      _freshTotal == null || bidsFresh.length < _freshTotal!;

  // =========================
  // SHARED DATA
  // =========================

  AdBannerModel? adBanner;

  Timer? _searchDebounce;

  bool get isFree => mainController.isFree;

  bool get shouldShowAds => mainController.shouldShowAds;

  int get balance => mainController.balance;

  bool get hasFreshBids => bidsFresh.isNotEmpty;

  final unreadInformCount = 0.obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    searchController = AppInputController();
    searchFocusNode = FocusNode();

    allRefreshController = RefreshController();
    freshRefreshController = RefreshController();

    allScrollController = ScrollController();
    freshScrollController = ScrollController();

    final storedUser = Hive.box('data').get('modelUser');
    modelUser = storedUser is ModelUser ? storedUser : ModelUser();

    super.onInit();
  }

  Future<void> initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) async {
    this.context = context;
    setState = set;

    modelUser = Hive.box('data').get('modelUser');

    await mainController.initUserData();

    await Future.wait([
      loadAdBanner(),
      loadAllBids(reset: true),
      loadUnreadInformMessages(),
      if (isFree) loadFreshBids(reset: true),
    ]);

    if (!context.mounted) return;

    setState(() {});
  }

  // =========================
  // TAB
  // =========================

  void selectTab(NewHomeTab tab) {
    if (tab == NewHomeTab.fresh && !isFree) {
      return;
    }

    if (selectedTab == tab) {
      return;
    }

    setState(() {
      selectedTab = tab;
    });
  }

  // =========================
  // ALL APPLICATIONS
  // =========================

  Future<void> loadAllBids({
    bool reset = false,
  }) async {
    // Pagination waits for the current request; a reset (new search,
    // refresh) always wins and supersedes whatever is in flight.
    if (_loadingAll && !reset) return;

    if (!reset && !hasMoreBids) {
      allRefreshController.loadNoData();
      return;
    }

    final requestId = ++_allRequestId;
    _loadingAll = true;

    try {
      final offset = reset ? 0 : _bidsOffset;

      final apiAnswer = await Api().traider.searchBids(
        search: searchController.text,
        limit: AppConstants.bidsPageLimit,
        offset: offset,
      );

      if (requestId != _allRequestId) return;

      log('NewHomeController loadAllBids bids: ${apiAnswer.data['bids']}');

      if (apiAnswer.data['status'] == '-') {
        throw Exception(
          apiAnswer.data['error']?.toString() ??
              'searchBids failed',
        );
      }

      final response = BidsResponse.fromJson(apiAnswer.data);

      final newItems = response.bids;

      if (reset) {
        bids
          ..clear()
          ..addAll(newItems);
      } else {
        bids.addAll(newItems);
      }

      _bidsOffset = offset + newItems.length;

      _bidsTotal = int.tryParse(
        '${apiAnswer.data['bids_total'] ?? ''}',
      );

      _updateUserfield(apiAnswer.data);

      if (context.mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      if (requestId != _allRequestId) return;

      log(
        'NewHomeController loadAllBids error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      if (requestId == _allRequestId) {
        _loadingAll = false;
      }
    }
  }

  // =========================
  // FRESH APPLICATIONS
  // =========================

  Future<void> loadFreshBids({
    bool reset = false,
  }) async {
    if (!isFree) return;

    if (_loadingFresh) return;

    if (!reset && !hasMoreFresh) {
      freshRefreshController.loadNoData();
      return;
    }

    _loadingFresh = true;

    try {
      if (reset) {
        _freshOffset = 0;
        _freshTotal = null;
      }

      final apiAnswer = await Api().traider.getAllBids(
        limit: AppConstants.bidsPageLimit,
        offset: _freshOffset,
      );

      log(
        'NewHomeController loadFreshBids bids: ${apiAnswer.data['bids_fresh']}',
      );

      final response = BidsResponse.fromJson(apiAnswer.data);

      final newItems = response.bidsFresh;

      if (reset) {
        bidsFresh
          ..clear()
          ..addAll(newItems);
      } else {
        bidsFresh.addAll(newItems);
      }

      _freshOffset += newItems.length;

      _freshTotal = int.tryParse(
        '${apiAnswer.data['bids_fresh_total'] ?? ''}',
      );

      _updateUserfield(apiAnswer.data);

      if (context.mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      log(
        'NewHomeController loadFreshBids error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      _loadingFresh = false;
    }
  }

  // =========================
  // SEARCH
  // =========================

  void toggleSearch() {
    final opening = !isSearchOpen;

    setState(() {
      isSearchOpen = opening;

      if (opening && isFree) {
        selectedTab = NewHomeTab.all;
      }
    });

    if (opening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (searchFocusNode.canRequestFocus) {
          searchFocusNode.requestFocus();
        }
      });
      return;
    }

    searchFocusNode.unfocus();

    if (searchController.text.isNotEmpty) {
      searchController.clear();
      onSearch();
    }
  }

  void onSearch() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
       AppConstants.searchDebounce,
      () async {
        try {
          await loadAllBids(reset: true);
        } catch (_) {
          if (context.mounted) {
            notification(
              text: context.l.somethingWentWrong,
            );
          }
        }
      },
    );
  }

  // =========================
  // REFRESH / PAGINATION
  // =========================

  Future<void> onLoadAll() async {
    if (!hasMoreBids) {
      allRefreshController.loadNoData();
      return;
    }

    try {
      await loadAllBids();
      allRefreshController.loadComplete();
    } catch (_) {
      allRefreshController.loadFailed();
    }
  }

  Future<void> onRefreshAll() async {
    try {
      await Future.wait([
        loadAllBids(reset: true),
        loadUnreadInformMessages(),
      ]);
      allRefreshController.refreshCompleted();
    } catch (_) {
      allRefreshController.refreshFailed();
    }
  }

  Future<void> onLoadFresh() async {
    if (!hasMoreFresh) {
      freshRefreshController.loadNoData();
      return;
    }

    try {
      await loadFreshBids();
      freshRefreshController.loadComplete();
    } catch (_) {
      freshRefreshController.loadFailed();
    }
  }

  Future<void> onRefreshFresh() async {
    try {
      await Future.wait([
        loadFreshBids(reset: true),
        loadUnreadInformMessages(),
      ]);
      freshRefreshController.refreshCompleted();
    } catch (_) {
      freshRefreshController.refreshFailed();
    }
  }

  Future<void> loadUnreadInformMessages() async {
    try {
      unreadInformCount.value = await MessagesRepository().unreadCount();
    } catch (e) {
      log('NewHomeController loadUnreadInformMessages error: $e');
    }
  }

  // =========================
  // BID
  // =========================

  Future<void> onPageBidItem({
    required BidItem item,
  }) async {
    final result = await Get.toNamed(
      Routes.bidItemScreen,
      arguments: [item],
    );

    if (result is BidItem) {
      updateBidItem(result);
    }
  }

  void updateBidItem(BidItem updated) {
    final allIndex = bids.indexWhere(
      (e) => e.orderId == updated.orderId,
    );

    if (allIndex != -1) {
      bids[allIndex] = updated;
    }

    final freshIndex = bidsFresh.indexWhere(
      (e) => e.orderId == updated.orderId,
    );

    if (freshIndex != -1) {
      bidsFresh[freshIndex] = updated;
    }

    if (context.mounted) {
      setState(() {});
    }
  }

  // =========================
  // ADS
  // =========================

  Future<void> loadAdBanner() async {
    try {
      adBanner = await Api().traider.getAdBanner();

      log(
        'NewHomeController ad banner: ${adBanner?.image}',
      );
    } catch (e) {
      log(
        'NewHomeController loadAdBanner error: $e',
      );

      adBanner = null;
    }
  }

  Future<void> disableAds(BuildContext context) async {
    try {
      final result = await AccountRepository().disableAds();

      if (result.ok) {
        mainController.patchUserfield(result.userfieldPatch);

        await Future.wait([
          loadAllBids(reset: true),
          if (isFree) loadFreshBids(reset: true),
        ]);

        mainController.patchUserfield(result.userfieldPatch);
      }

      if (context.mounted) {
        inAppNotification(
          text: result.message ?? '',
          c: context,
        );
      }
    } catch (e) {
      log(
        'NewHomeController disableAds error: $e',
      );

      if (context.mounted) {
        notification(
          text: context.l.somethingWentWrong,
        );
      }
    }
  }

  void _updateUserfield(dynamic data) {
    final value = data['userfield'];

    if (value is Map) {
      mainController.updateUserfield(
        Map<String, dynamic>.from(value),
      );
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();

    searchController.dispose();
    searchFocusNode.dispose();

    allRefreshController.dispose();
    freshRefreshController.dispose();

    allScrollController.dispose();
    freshScrollController.dispose();

    super.onClose();
  }
}

Future<void> payBalance(int amount, BuildContext context) async {
  try {
    final payUrl = await AccountRepository().topUpPaymentUrl(amount);
    final opened = await openPaymentUrl(payUrl);
    if (!opened && context.mounted) {
      notification(text: context.l.somethingWentWrong);
    }
  } catch (e, stackTrace) {
    log('payBalance failed: $e', error: e, stackTrace: stackTrace);
    if (context.mounted) {
      notification(text: context.l.somethingWentWrong);
    }
  }
}

Future<bool> openPaymentUrl(String rawUrl) async {
  var value = rawUrl.trim();
  if (value.startsWith('//')) {
    value = 'https:$value';
  } else if (!value.contains('://')) {
    final base = Api.baseUrl();
    value = '$base${value.startsWith('/') ? value.substring(1) : value}';
  }

  final uri = Uri.tryParse(value);
  print('openPaymentUrl raw=$rawUrl parsed=$uri');
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    print('openPaymentUrl rejected scheme=${uri?.scheme}');
    return false;
  }

  try {
    final canLaunch = await canLaunchUrl(uri);
    print('openPaymentUrl canLaunchUrl=$canLaunch');
  } catch (e) {
    print('openPaymentUrl canLaunchUrl error: $e');
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    print('openPaymentUrl externalApplication=$launched');
    if (launched) return true;
  } catch (e) {
    print('openPaymentUrl externalApplication error: $e');
  }

  try {
    final launched = await launchUrl(uri);
    print('openPaymentUrl platformDefault=$launched');
    return launched;
  } catch (e) {
    print('openPaymentUrl platformDefault error: $e');
    return false;
  }
}