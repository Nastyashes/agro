import 'package:agro/app/all_applications/all_applications_controller.dart';

import 'package:agro/app/home/components/block_order_unified.dart';
import 'package:agro/app/home/components/new_block/bid_list_item.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/app/home/components/new_block/bids_item_new_model.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agro/app/components/block_page_screen.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../ui/footer_load.dart';

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
                              for (BidItem item in controller.bidsFresh)
                                BidListItem(
                                  bidItem: item,
                                  onPressed: ({required model}) =>
                                      controller.onPageBidItem(item: item),
                                ),
                            ] else
                              readText(
                                  text: context.l.noFreshApplications,
                                  style:
                                      const TextStyle(color: AppColors.grey)),
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
