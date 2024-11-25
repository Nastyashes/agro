import 'package:agro/generated/assets.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TariffItem extends StatelessWidget {
  const TariffItem(
      {super.key, required this.modelTariff, this.tariff, required this.isMyTariff});
  final ModelTariff modelTariff;
  final Tariff? tariff;
  final bool isMyTariff;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(Assets.hedTariff),
          alignment: Alignment.topLeft,
          fit: BoxFit.fitWidth,
          colorFilter: ColorFilter.mode(
            modelTariff.color,
            BlendMode.srcATop,
          ),
        ),
        border: Border.all(color: modelTariff.color, width: 1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Visibility(
                visible: isMyTariff,
                replacement: const SizedBox(
                  width: 120,
                  height: 54,
                ),
                child: Container(
                  width: 120,
                  height: 54,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(Assets.myTariffLable),
                          fit: BoxFit.fill)),
                  child: Text(
                    context.l.myTariff,
                    style: AppFonts.body1bold.white,
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              (modelTariff.name ?? "").toUpperCase(),
              style: AppFonts.tariffName.white,
            ),
          ),
          const SizedBox(height: 60),
          modelTariff.priceOld != 0
              ? Text('${modelTariff.priceOld} грн',
                  style: AppFonts.tariffPrice
                      .withColor(AppColors.grey3)
                      .copyWith(
                          decoration: TextDecoration.lineThrough, height: 1.0))
              : const SizedBox(),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Text('${modelTariff.price} ${modelTariff.currency}',
                  style: AppFonts.tariffPrice.withColor(modelTariff.color)),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  modelTariff.pricePeriod ?? 'year', //TODO
                  style: AppFonts.body1bold.withColor(modelTariff.color),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...modelTariff.advantages.map((adv) => propItem(
                      iconAsset: Assets.checkCircle,
                      iconColor: modelTariff.color,
                      text: adv)),
                  ...modelTariff.disadvantages.map((disadv) => propItem(
                      iconAsset: Assets.cancel,
                      iconColor: AppColors.red,
                      text: disadv)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  Widget propItem(
      {required String iconAsset,
      required Color iconColor,
      required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SvgPicture.asset(iconAsset,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
          const SizedBox(width: 10.0),
          Expanded(
              child: Text(
            text,
            style: AppFonts.tariffHeader,
          )),
        ],
      ),
    );
  }
}
