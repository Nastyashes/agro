import 'package:agro/app/home/components/block_message.dart';

import 'package:agro/app/home/components/home_header.dart';
import 'package:agro/app/home/components/block_order_unified.dart';
import 'package:agro/app/home/components/new_block/bid_list_item.dart';
import 'package:agro/app/home/components/new_block/bids_item_new_model.dart';
import 'package:agro/app/home/components/top_up_balance_popup.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/message/created.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/model/enums.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agro/app/components/block_page_screen.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../ui/buttons/b_transparent_scalable_button.dart';
import '../../ui/footer_load.dart';
import '../../ui/text_field/text_field.dart';
import 'components/home_controller.dart';

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

  @override
  Widget build(BuildContext context) {
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
                        waterDropColor: AppColors.mainGreen),
                    child: ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemCount: 1,
                        separatorBuilder: (c, i) {
                          return Container();
                        },
                        itemBuilder: (_, e) {
                          return Column(
                            children: [
                              for (Created item in controller.combinedList) ...[
                                if (item is ModelOrder)
                                  getBlockOrder(
                                    item,
                                    controller.callResults.firstWhereOrNull(
                                        (element) =>
                                            element.orderId ==
                                            item.id.toString()),
                                    controller.onPageOrderFermer,
                                  )
                                else if (item is BidItem)
                                  BidListItem(
                                    bidItem: item,
                                    onPressed: ({required BidItem model}) =>
                                        controller.onPageBidItem(item: model),
                                  )
                                else if (item is Message)
                                  BlockMessage(message: item)
                                else
                                  const SizedBox(),
                              ]
                            ],
                          );
                        })))
          ],
        ));
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
