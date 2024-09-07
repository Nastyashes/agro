import 'package:agro/generated/assets.dart';
import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';

class TariffItem extends StatelessWidget {
  const TariffItem({super.key, required this.modelTariff});
  final ModelTariff modelTariff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image:  DecorationImage(
          image: AssetImage(Assets.hedTariff),
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
          const SizedBox(height: 60,),
          Text(
            modelTariff.name,
            style: AppFonts.titletariff.white,
          ),
          const SizedBox(height: 60,),
          Text(modelTariff.price,
              style: TextStyle(
                color: modelTariff.color,
                fontFamily: 'Nunito',
                fontSize: 32,
                fontWeight: FontWeight.w700
              )),
               Row (mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 80,),
                Text ('на рік', 
               style: TextStyle(
                color: modelTariff.color,
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700),)] ),
              const SizedBox(height: 30,),
           ...modelTariff.advantages.map((adv) => Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),  // Іконка для переваг
              const SizedBox(width: 8.0),
              Expanded(child: Text(adv, style: AppFonts.body1bold,)),
            ],
          )),
          
          const SizedBox(height: 8.0),
          
          // Недоліки
           ...modelTariff.disadvantages.map((disadv) => Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red),  // Іконка для недоліків
              const SizedBox(width: 8.0),
              Expanded(child: Text(disadv, style: AppFonts.body1bold,)),
            ],
          )),
        ],
      ),
    );
  }
}
