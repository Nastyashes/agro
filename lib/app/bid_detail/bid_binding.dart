import 'package:agro/app/bid_detail/bid_controller.dart';
import 'package:get/get.dart';

class BidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BidItemController());
  }
}
