import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:agro/server/api/controller/my_price.dart';
import 'package:get/get.dart';

/// "My combinations / reservations" list. No BuildContext: dialogs go
/// through [MyPriceUi].
class MyPriceController extends BaseController {
  MyPriceController({MyPriceApi? api, MainController? mainController})
      : _api = api ?? MyPriceApi(),
        _mainController = mainController;

  final MyPriceApi _api;
  final MainController? _mainController;

  late MyPriceUi ui;

  MainController get mainController =>
      _mainController ?? Get.find<MainController>();

  final Rx<MyPriceOverview> overview = const MyPriceOverview().obs;

  /// 0 = combinations, 1 = reservations.
  final RxInt tabIndex = 0.obs;

  /// False until the first load finished (success or error).
  final RxBool loadPage = false.obs;

  ModelUser get modelUser => SessionStorage.instance.user ?? ModelUser();

  List<MyPriceEntry> get visibleEntries => tabIndex.value == 1
      ? overview.value.reservations
      : overview.value.combinations;

  @override
  void onReady() {
    super.onReady();
    loadOverview();
  }

  /// The last load failed: the screen shows an error with a retry
  /// instead of "no combinations" (BUG-026).
  final RxBool loadFailed = false.obs;

  Future<void> loadOverview() async {
    final result = await _api.overview();
    if (result.ok && result.data != null) {
      overview.value = result.data!;
      loadFailed.value = false;
    } else {
      loadFailed.value = true;
      loadPage.value = true;
      await ui.showError(result);
    }
    loadPage.value = true;
  }

  void selectTab(int index) => tabIndex.value = index;

  Future<void> onCreate() async {
    await Get.toNamed(Routes.myPriceCreate, arguments: overview.value);
    await loadOverview();
  }

  Future<void> onEdit(MyPriceEntry entry, {required bool reservation}) async {
    await Get.toNamed(
      Routes.myPriceEdit,
      arguments: {
        'overview': overview.value,
        'entry': entry,
        'targetType': reservation ? 'reservation' : 'combination',
      },
    );
    await loadOverview();
  }

  /// Deletes a combination after the user confirms.
  Future<void> deleteEntry(MyPriceEntry entry) async {
    if (entry.id == null) return;
    if (!await ui.confirmDelete()) return;
    final result = await _api.deleteCombination(entry.id!);
    if (!result.ok) {
      await ui.showError(result);
      return;
    }
    await loadOverview();
  }
}
