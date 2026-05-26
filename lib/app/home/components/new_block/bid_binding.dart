import 'package:agro/app/home/components/new_block/bid_item_controller.dart';
import 'package:get/get.dart';

class BidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BidItemController());
  }
}
