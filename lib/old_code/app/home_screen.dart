import 'package:agro/app/home/banner/banner_in_list.dart';

import 'package:agro/old_code/app/home/components/home_header.dart';
import 'package:agro/old_code/app/home/components/block_order_unified.dart';
import 'package:agro/app/home/bids_pages/bid_list_item.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/ui/pop_up/top_up_balance_popup.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/new_models_bids/feed_item_model.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agro/ui/app_components/block_page_screen.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/load/footer_load.dart';
import 'package:agro/ui/text_field/text_field.dart';
import 'package:agro/old_code/app/home/components/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = Get.find();

  @override
  void initState() {
    controller.initPage(context: context, set: setState);
    super.initState();
  }

  List<FeedItem> buildFeed(HomeController controller) {
    final result = <FeedItem>[];

    int bidCounter = 0;

    for (final item in controller.combinedList) {
      if (item is ModelOrder) {
        result.add(
          FeedOrderItem(
            item,
            controller.callResults.firstWhereOrNull(
              (e) => e.orderId == item.id.toString(),
            ),
          ),
        );
      }

      if (item is BidItem) {
        result.add(FeedBidItem(item));

        bidCounter++;

        // 🔥 ЗАГЛУШКА (поки немає бекенду)
        if (bidCounter % 6 == 0) {
          result.add(
            FeedBannerItem(
              const AdBannerModel(
                image:
                    'https://uagro.trade/uploads/vipline/6a45509dbb6ba_photo_2026-07-01_20-38-02.jpg',
                phone: '+380774804040',
              ),
            ),
          );
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final feed = controller.getFeed();

    return BlockPageScreen(
      headerSize: 21,
      padding: EdgeInsets.only(
          left: controller.modelUser.isTraider ? 30 : 40,
          right: controller.modelUser.isTraider ? 30 : 0),
      header:
          controller.modelUser.isTraider ? null : context.l.yourApplications,
      headerWidget: controller.modelUser.isTraider
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HomeHeader(
                baslance: controller.balance,
                // monopay load
                tariff: controller.tariff,
                onTabTopUp: () {
                  showTopUpDialog(context, controller.balance, (amount) {
                    controller.onPayBalance(amount, context);
                  });
                },
              ))
          : null,
      endWidget: controller.modelUser.isTraider
          ? null
          : BTransparentScalableButton(
              onPressed: () =>
                  {controller.fermerCreateOrder(context.l.applicationSent)},
              scale: ScaleFormat.big,
              child: Row(
                children: [
                  const Icon(Icons.add, color: Color(0xffFCD300), size: 45),
                  readText(
                      text: context.l.add,
                      style: AppFonts.title2.withColor(AppColors.mainGreen)),
                ],
              )),
      theme:
          SystemUiOverlayStyle.dark.copyWith(statusBarColor: AppColors.white),
      child: Column(
        children: [
          TextFieldWidget(
              padding: const EdgeInsets.only(top: 12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.grey2),
              text: context.l.search,
              height: 60,
              textStyle: AppFonts.body1medium.black,
              hintStyle: AppFonts.body1medium.grey3,
              openKeyboardAuto: true,
              colorBg: AppColors.grey1,
              controller: controller.searchController,
              onChanged: (_) => controller.onSearch()),
          Expanded(
            child: SmartRefresher(
              controller: controller.controllerLoading,
              scrollController: controller.controllerScroll,
              enablePullUp: true,
              enablePullDown: true,
              onLoading: controller.onLoadData,
              onRefresh: controller.onRefresh,
              footer: const FooterLoad(),
              header: const WaterDropHeader(
                complete: CompleteWidget(),
                waterDropColor: AppColors.mainGreen,
              ),
              child: ListView.builder(
                key: const PageStorageKey('home_feed_list'),
                controller: controller.controllerScroll,
                physics: const AlwaysScrollableScrollPhysics(),
                //    physics: const ClampingScrollPhysics(),
                itemCount: feed.length,
                itemBuilder: (context, index) {
                  final item = feed[index];

                  if (item is FeedBannerItem) {
                    return BannerItemForList(
                      imageUrl: item.banner.image,
                      phoneNumber: item.banner.phone,
                    );
                  }

                  if (item is FeedBidItem) {
                    return BidListItem(
                      key: ValueKey('bid_${item.bid.orderId}'),
                      isFresh: false,
                      bidItem: item.bid,
                      onPressed: ({required BidItem model}) =>
                          controller.onPageBidItem(item: model),
                    );
                  }

                  if (item is FeedOrderItem) {
                    return getBlockOrder(
                      key: ValueKey('order_${item.order.id}'),
                      item.order,
                      item.answer,
                      controller.onPageOrderFermer,
                    );
                  }

                  return const SizedBox.shrink();
                },
                //      );
                //           },
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget getBlockOrder(ModelOrder order, Answer? answer,
    Function({required ModelOrder model}) onPressed,
    {required ValueKey<String> key}) {
  switch (order.sphere) {
    case 15:
      return BlockOrderUnified(
          key: key,
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.zerno);
    case 12:
      return BlockOrderUnified(
          key: key,
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.dobriva);
    case 13:
      return BlockOrderUnified(
          key: key,
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.seeds);
    case 14:
      return BlockOrderUnified(
          key: key,
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.oil);
    default:
      return BlockOrderUnified(
          key: key,
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.unknown);
  }
}

class CompleteWidget extends StatelessWidget {
  const CompleteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.done,
          color: Colors.grey,
        ),
        Container(
          width: 15.0,
        ),
        Text(
          context.l.updateComplete,
          style: const TextStyle(color: Colors.grey),
        )
      ],
    );
  }
}
