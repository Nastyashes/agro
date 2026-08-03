import 'package:agro/app/components/block_page_screen.dart';
import 'package:agro/app/home/components/home_controller.dart';
import 'package:agro/app/home/bids_pages/bid_controller.dart';
import 'package:agro/generated/assets.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/ui/buttons/b_style.dart';
import 'package:agro/ui/buttons/b_transparent_scalable_button.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:agro/vars/trade_localizers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BidDetailScreen extends StatefulWidget {
  const BidDetailScreen({super.key});

  @override
  State<BidDetailScreen> createState() => _BidDetailScreenState();
}

class _BidDetailScreenState extends State<BidDetailScreen> {
  late final BidItemController controller;

  final HomeController _homeController = Get.find();

  @override
  void initState() {
    controller = Get.put(BidItemController());

    final BidItem item = Get.arguments[0] as BidItem;

    controller.initPage(
      context: context,
      set: setState,
      item: item,
    );

    super.initState();
  }

  @override
  void dispose() {
    Get.delete<BidItemController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlockPageScreen(
      headerSize: 20,
      headerColor: AppColors.white,
      topbarColor: AppColors.zerno,
      dividerColor: AppColors.zerno,
      header: controller.loadPage
          ? '${context.l.applicationNo} ${controller.bidItem.orderId} '
              '${context.l.from} ${controller.bidItem.orderCreatedHum ?? ''}'
          : '',
      isBack: true,
      endWidget: controller.loadPage
          ? BTransparentScalableButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _toText(context)));
                inAppNotification(
                    text: context.l.copiedToClipboard, c: context);
              },
              scale: ScaleFormat.big,
              child: const Icon(Icons.copy, color: AppColors.white, size: 24),
            )
          : null,
      theme:
          SystemUiOverlayStyle.dark.copyWith(statusBarColor: AppColors.zerno),
      child: !controller.loadPage
          ? const SizedBox()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoCard(context),
                ],
              ),
            ),
    );
  }

  Widget _infoCard(BuildContext context) {
    final item = controller.bidItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(context.l.region, item.regionName ?? '—'),
        (item.contacts?.district != null && item.contacts!.district!.isNotEmpty)
            ? _row(context.l.district, item.contacts?.district ?? '—')
            : const SizedBox(),
        (item.contacts?.city != null && item.contacts!.city!.isNotEmpty)
            ? _row(context.l.town, item.contacts?.city ?? '—')
            : const SizedBox(),
        (item.contacts?.addr != null && item.contacts!.addr!.isNotEmpty)
            ? _row(context.l.address, item.contacts?.addr ?? '—')
            : const SizedBox(),
        (item.fermerCompany != null && item.fermerCompany!.isNotEmpty)
            ? _row(context.l.company, item.fermerCompany ?? '—')
            : const SizedBox(),
        (item.fermerName != null && item.fermerName!.isNotEmpty)
            ? _row(context.l.fullName, item.fermerName ?? '—')
            : const SizedBox(),
        _row(context.l.product, item.productTitle ?? '—'),
        _row(context.l.volume, '${item.amount ?? '—'} т'),
        _row(context.l.harvestYear, '${item.year ?? '—'}'),
        _row(
          context.l.formOfPayment,
          item.ordPaymentType == 1
              ? context.l.paymentFormF1
              : item.ordPaymentType == 2
                  ? context.l.paymentFormF2
                  : context.l.allPaymentForm,
        ),
        _row(context.l.typeOfDelivery,
            localizeDeliveryType(item.deliveryType ?? '-', context)),
        (item.contacts?.phone != null && item.contacts!.phone!.isNotEmpty)
            ? _row(context.l.phoneNumber, item.contacts?.phone ?? '—')
            : const SizedBox(),
        (item.contacts?.email != null && item.contacts!.email!.isNotEmpty)
            ? _row(context.l.eMail, item.contacts?.email ?? '—')
            : const SizedBox(),
   
        if (_homeController.modelUser.isTraider) ...[
          _traidersButtons(context)
        ] else ...[
          //          fermersButton(controller, context)
        ],
      ],
    );
  }

  Widget _traidersButtons(BuildContext context) {
    final item = controller.bidItem;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(children: [
            // --- Купити контакт ---
            if (!item.isOpened)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: bStyle(
                    text: item.contactPrice != null && item.contactPrice! > 0
                        ? '${context.l.contacts} · ${item.contactPrice} ₴'
                        : context.l.contacts,
                    c: context,
                    colorText: AppColors.darkGreen,
                    vertical: 15,
                    border: Border.all(color: AppColors.darkGreen, width: 1),
                    colorButt: Colors.transparent,
                    onPressed: () => controller.onContactClick(context),
                  ),
                ),
              ),

            Expanded(
              child: bStyle(
                text: context.l.reviews,
                c: context,
                colorText: AppColors.darkGreen,
                vertical: 15,
                border: Border.all(color: AppColors.darkGreen, width: 1),
                colorButt: Colors.transparent,
                onPressed: controller.onReview,
              ),
            ),
          ]),
        ),
  if (item.isOpened)
        Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Stack(
                        children: [ bStyle(
    text: controller.orderingCarrier
        ? '⛟ ${context.l.orderingCarrier}'
        : controller.carrierOrdered
            ? '✅️ ${context.l.carrierOrdered}'
            : '⛟ ${context.l.bookCarrier}',
    c: context,
    vertical: 15,
    active: !controller.orderingCarrier && !controller.carrierOrdered,
    colorButt: !controller.orderingCarrier && !controller.carrierOrdered ?
     AppColors.mainGreen : AppColors.greyGreen,
    onPressed: () {
      if (controller.orderingCarrier || controller.carrierOrdered) return;
      controller.onOrderCarrier(context);
    },
  ),
   Positioned(
                            left: -7,
                            top: -8,
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(Assets.newBadge),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                  
),
        ),

if (item.isOpened)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: bStyle(
      text: controller.orderingAnalysis
          ? context.l.orderingAnalysis
          : controller.analysisOrdered
              ? context.l.analysisOrdered
              : context.l.orderAnalysis,
      c: context,
      vertical: 15,
      active: !controller.orderingAnalysis && !controller.analysisOrdered,
      colorButt: !controller.orderingAnalysis && !controller.analysisOrdered
          ? AppColors.darkGreen
          : AppColors.greyGreen,
      onPressed: () {
        if (controller.orderingAnalysis || controller.analysisOrdered) return;
        controller.onOrderAnalysis(context);
      },
    ),
  ),

        const SizedBox(height: 16),
        // --- Угода (тільки VIP) ---
        //  if (controller.tariff?.isVip == true)
        /*
        Row(
          children: [
            Expanded(
              child: bStyle(
                text: context.l.agreement,
                c: context,
                colorText: AppColors.white,
                vertical: 15,
                onPressed: () => controller.onDeal(context),
              ),
            ),
          ],
          
        )*/
        // --- Додати ціну ---
        //    bStyle(
        //      key: UniqueKey(),
        //      text: context.l.addPrice,
        //      c: context,
        //      vertical: 15,
        //      colorButt: AppColors.yellow,
        //      onPressed: () => controller.onAddPrice(context, controller.bidItem),
        //    ),
      ],
    );
  }

  Widget _row(String header, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          readText(text: header, style: AppFonts.body1medium.grey3),
          const SizedBox(width: 16),
          Expanded(
              child: readText(
                  text: text,
                  style: AppFonts.body1medium.black,
                  align: TextAlign.end)),
        ]),
      );

  String _toText(BuildContext context) {
    final item = controller.bidItem;
    return '${context.l.applicationNo} ${item.id}\n'
        '${context.l.region}: ${item.regionName}\n'
        '${context.l.product}: ${item.productTitle}\n'
        '${context.l.volume}: ${item.amount} т\n'
        '${context.l.typeOfDelivery}: ${item.deliveryType}\n';
  }
  /*
   Widget fermersButton(BidItemController controller, BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 20),
      bStyle(
          key: UniqueKey(),
          padding: const EdgeInsets.only(top: 35),
          text: DateTime.now().millisecondsSinceEpoch >
                  (controller.modelOrder?.endDate?.millisecondsSinceEpoch ?? 0)
              ? context.l.sold
              : context.l.sell,
          size: 23,
          c: context,
          active: DateTime.now().millisecondsSinceEpoch <
              (controller.modelOrder?.endDate!.millisecondsSinceEpoch ?? 0),
          colorButt: DateTime.now().millisecondsSinceEpoch >
                  (controller.modelOrder?.endDate?.millisecondsSinceEpoch ?? 0)
              ? const Color(0xffF2F2F2)
              : const Color(0xffFCD300),
          onPressed: controller.onSell),
    ]);
  }
*/
}
