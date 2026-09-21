import 'package:agro/app/new_home_screen/drawer/bid_list_item.dart';
import 'package:agro/old_code/app/all_applications/all_applications_controller.dart';
import 'package:agro/app/new_home_screen/banner/banner_in_list.dart';

import 'package:agro/old_code/app/home/components/block_order_unified.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agro/ui/app_components/block_page_screen.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:agro/ui/load/footer_load.dart';

class AllApplicationsScreen extends StatefulWidget {
  const AllApplicationsScreen({super.key});

  @override
  State<AllApplicationsScreen> createState() => AllApplicationsScreenState();
}

class AllApplicationsScreenState extends State<AllApplicationsScreen> {
  AllApplicationsController controller = Get.find();

  @override
  void initState() {
    controller.initPage(context: context, set: setState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlockPageScreen(
        header: context.l.freshApplications,
        theme: SystemUiOverlayStyle.dark,
        child: Column(children: [
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
                      waterDropColor: AppColors.mainGreen),
                  child: ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      itemCount: 1,
                      separatorBuilder: (c, i) {
                        return Container();
                      },
                      itemBuilder: (_, e) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.hasFreshBids) ...[
                              () {
                                final widgets = <Widget>[];
                                int counter = 0;

                                for (final item in controller.bidsFresh) {
                                  widgets.add(
                                    BidListItem(
                                      isFresh: true,
                                      bidItem: item,
                                      onPressed: ({required model}) =>
                                          controller.onPageBidItem(item: item),
                                    ),
                                  );

                                  counter++;

                                  if (controller.shouldShowAds &&
                                      counter % 5 == 0) {
                                    widgets.add(
                                      BannerItemForList(
                                        imageUrl: controller.adBanner?.image ??
                                            'https://uagro.trade/uploads/vipline/6a45509dbb6ba_photo_2026-07-01_20-38-02.jpg',
                                        phoneNumber:
                                            controller.adBanner?.phone ??
                                                '+380774804040',
                                      ),
                                    );
                                  }
                                }

                                return Column(children: widgets);
                              }(),
                            ] else
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.dobriva.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.dobriva),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        context.l.noFreshApplications,
                                        style: AppFonts.body1medium.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      })))
        ]));
  }
}

Widget getBlockOrder(ModelOrder order, Answer? answer,
    Function({required ModelOrder model}) onPressed) {
  switch (order.sphere) {
    case 15:
      return BlockOrderUnified(
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.zerno);
    case 12:
      return BlockOrderUnified(
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.dobriva);
    case 13:
      return BlockOrderUnified(
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.seeds);
    case 14:
      return BlockOrderUnified(
          modelOrder: order,
          answer: answer,
          onPressed: onPressed,
          orderType: OrderType.oil);
    default:
      return BlockOrderUnified(
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
