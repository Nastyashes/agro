import 'package:agro/generated/assets.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TariffItem extends StatelessWidget {
  const TariffItem({super.key, required this.modelTariff});
  final ModelTariff modelTariff;

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
            padding: const EdgeInsets.only(top: 60),
            child: Text(
              modelTariff.name,
              style: AppFonts.tariffName.white,
            ),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text(modelTariff.price,
                    style: AppFonts.tariffPrice.withColor(modelTariff.color)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  'на рік',
                  style: AppFonts.body1bold.withColor(modelTariff.color),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          ...modelTariff.advantages.map((adv) => propItem(
              iconAsset: Assets.checkCircle,
              iconColor: modelTariff.color,
              text: adv)),
          // Недоліки
          ...modelTariff.disadvantages.map((disadv) => propItem(
              iconAsset: Assets.cancel, iconColor: AppColors.red, text: disadv)),
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
              colorFilter: ColorFilter.mode(
                  iconColor, BlendMode.srcIn)), // Іконка для недоліків
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
