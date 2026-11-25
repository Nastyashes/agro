import 'package:agro/data/session_storage.dart';
import 'dart:async';
import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/data/repositories/bids_repository.dart';
import 'package:agro/data/repositories/messages_repository.dart';
import 'package:agro/controllers/app_input_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum NewHomeTab {
  all,
  fresh,
}

class NewHomeController extends BaseController {
  NewHomeController({BidsRepository? bids, AccountRepository? account})
      : _bidsRepository = bids ?? BidsRepository(),
        _account = account ?? AccountRepository();

  final AccountRepository _account;
  final MainController mainController = Get.find<MainController>();

  final BidsRepository _bidsRepository;

  late final TextEditingController searchController;
  late final FocusNode searchFocusNode;

  final RxBool isSearchOpen = false.obs;

  late final RefreshController allRefreshController;
  late final RefreshController freshRefreshController;

  late final ScrollController allScrollController;
  late final ScrollController freshScrollController;

  late ModelUser modelUser;

  final Rx<NewHomeTab> selectedTab = NewHomeTab.all.obs;

  // =========================
  // ALL BIDS
  // =========================

  final RxList<BidItem> bids = <BidItem>[].obs;

  int _bidsOffset = 0;
  int? _bidsTotal;

  bool _loadingAll = false;

  /// Incremented on every request; responses from superseded requests
  /// (e.g. an older search query) are discarded.
  int _allRequestId = 0;

  bool get hasMoreBids => _bidsTotal == null || bids.length < _bidsTotal!;

  // =========================
  // FRESH BIDS
  // =========================

  final RxList<BidItem> bidsFresh = <BidItem>[].obs;

  int _freshOffset = 0;
  int? _freshTotal;

  bool _loadingFresh = false;

  bool get hasMoreFresh =>
      _freshTotal == null || bidsFresh.length < _freshTotal!;

  // =========================
  // SHARED DATA
  // =========================

  final Rxn<AdBannerModel> adBanner = Rxn<AdBannerModel>();

  /// Incremented when a search fails; the screen shows an error.
  final RxInt failures = 0.obs;

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

    modelUser = SessionStorage.instance.user ?? ModelUser();

    super.onInit();
  }

  Future<void> initPage() async {
    modelUser = SessionStorage.instance.user ?? ModelUser();

    await mainController.initUserData();

    await Future.wait([
      loadAdBanner(),
      loadAllBids(reset: true),
      loadUnreadInformMessages(),
      if (isFree) loadFreshBids(reset: true),
    ]);
  }

  // =========================
  // TAB
  // =========================

  void selectTab(NewHomeTab tab) {
    if (tab == NewHomeTab.fresh && !isFree) {
      return;
    }

    selectedTab.value = tab;
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

      final page = await _bidsRepository.search(
        query: searchController.text,
        limit: AppConstants.bidsPageLimit,
        offset: offset,
      );

      if (requestId != _allRequestId) return;

      final newItems = page.items;

      if (reset) {
        bids
          ..clear()
          ..addAll(newItems);
      } else {
        bids.addAll(newItems);
      }

      _bidsOffset = offset + newItems.length;

      _bidsTotal = page.total;

      _updateUserfield(page.userfield);
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

      final page = await _bidsRepository.fresh(
        limit: AppConstants.bidsPageLimit,
        offset: _freshOffset,
      );

      final newItems = page.items;

      if (reset) {
        bidsFresh
          ..clear()
          ..addAll(newItems);
      } else {
        bidsFresh.addAll(newItems);
      }

      _freshOffset += newItems.length;

      _freshTotal = page.total;

      _updateUserfield(page.userfield);
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
    final opening = !isSearchOpen.value;
    isSearchOpen.value = opening;
    if (opening && isFree) selectedTab.value = NewHomeTab.all;

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
          failures.value++;
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
  }

  // =========================
  // ADS
  // =========================

  Future<void> loadAdBanner() async {
    try {
      adBanner.value = await _bidsRepository.feedBanner();

      log(
        'NewHomeController ad banner: ${adBanner.value?.image}',
      );
    } catch (e) {
      log(
        'NewHomeController loadAdBanner error: $e',
      );

      adBanner.value = null;
    }
  }

  /// Charges the balance to switch ads off and refreshes the lists.
  /// Returns the server message, or null if the request failed.
  Future<String?> disableAds() async {
    try {
      final result = await _account.disableAds();
      if (result.ok) {
        mainController.patchUserfield(result.userfieldPatch);
        await Future.wait([
          loadAllBids(reset: true),
          if (isFree) loadFreshBids(reset: true),
        ]);
        mainController.patchUserfield(result.userfieldPatch);
      }
      return result.message ?? '';
    } catch (e) {
      log('NewHomeController disableAds error: $e');
      return null;
    }
  }

  void _updateUserfield(Map<String, dynamic>? value) {
    if (value != null) mainController.updateUserfield(value);
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
