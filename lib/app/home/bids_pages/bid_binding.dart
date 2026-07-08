import 'package:agro/app/home/bids_pages/bid_controller.dart';
import 'package:get/get.dart';

class BidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BidItemController());
  }
}
