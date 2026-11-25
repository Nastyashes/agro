import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:get/get.dart';

/// Paged list of My price deals (moved out of the screen widget).
class MyPriceDealsController extends BaseController {
  MyPriceDealsController({MyPriceApi? api}) : _api = api ?? MyPriceApi();

  static const int limit = 50;

  final MyPriceApi _api;

  late MyPriceUi ui;

  final RxList<MyPriceDealItem> items = <MyPriceDealItem>[].obs;
  final RxBool loading = true.obs;
  final RxBool loadingMore = false.obs;
  bool hasMore = true;
  int _offset = 0;

  @override
  void onReady() {
    super.onReady();
    loadDeals(reset: true);
  }

  Future<void> loadDeals({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      hasMore = true;
      items.clear();
      loading.value = true;
    } else {
      if (!hasMore || loadingMore.value) return;
      loadingMore.value = true;
    }

    final result = await _api.dealsList(limit: limit, offset: _offset);
    if (result.ok && result.data != null) {
      final page = result.data!.items;
      items.addAll(page);
      _offset += page.length;
      hasMore = page.length >= limit;
    } else {
      await ui.showError(result);
    }
    loading.value = false;
    loadingMore.value = false;
  }
}
