import 'package:agro/app/all_applications/all_applications_controller.dart';
import 'package:agro/app/home/components/block_message.dart';
import 'package:agro/app/home/components/block_order_dobriva.dart';
import 'package:agro/app/home/components/block_order_oil.dart';
import 'package:agro/app/home/components/block_order_seeds.dart';
import 'package:agro/app/home/components/block_order_unknown.dart';
import 'package:agro/model/answer/answer.dart';
import 'package:agro/model/message/created.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agro/app/components/block_page_screen.dart';
import 'package:agro/app/home/components/block_order_zerno.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../ui/footer_load.dart';
import '../../ui/text_field/text_field.dart';

class AllApplicationsScreen extends StatefulWidget {
  const AllApplicationsScreen({super.key});

  @override
  State<AllApplicationsScreen> createState() =>  AllApplicationsScreenState();
}

class  AllApplicationsScreenState extends State<AllApplicationsScreen> {
 AllApplicationsController controller = Get.find();

  @override
 void initState() {
    controller.initPage(context: context, set: setState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlockPageScreen(
        header: context.l.allApplications,
        theme: SystemUiOverlayStyle.dark,
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
                                item is ModelOrder
                                    ? getBlockOrder(
                                        item,
                                        controller.callResults.firstWhereOrNull(
                                            (element) =>
                                                element.orderId ==
                                                item.id.toString()),
                                        controller.onPageOrderFermer)
                                    : item is Message
                                        ? BlockMessage(message: item)
                                        : const SizedBox()
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
      return BlockOrderZerno(
          modelOrder: order, answer: answer, onPressed: onPressed);
    case 12:
      return BlockOrderDobriva(
          modelOrder: order, answer: answer, onPressed: onPressed);
    case 13:
      return BlockOrderSeeds(
          modelOrder: order, answer: answer, onPressed: onPressed);
    case 14:
      return BlockOrderOil(
          modelOrder: order, answer: answer, onPressed: onPressed);
    default:
      return BlockOrderUnknown(
          modelOrder: order, answer: answer, onPressed: onPressed);
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
