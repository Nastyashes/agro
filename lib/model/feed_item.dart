import 'package:agro/model/bids_item_new_model.dart';
import 'package:agro/model/add_banner/add_banner_model.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/model/model_order/model_order.dart';

sealed class FeedItem {}
class FeedOrderItem extends FeedItem {
  final ModelOrder order;
  final Answer? answer;

  FeedOrderItem(this.order, this.answer);
}

class FeedBidItem extends FeedItem {
  final BidItem bid;

  FeedBidItem(this.bid);
}

class FeedMessageItem extends FeedItem {
  final Message message;

  FeedMessageItem(this.message);
}

class FeedBannerItem extends FeedItem {
  final AdBannerModel banner;

  FeedBannerItem(this.banner);
}