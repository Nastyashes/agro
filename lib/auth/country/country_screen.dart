import 'package:agro/generated/assets.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:agro/routes/app_pages.dart';

class CountryScreen extends StatelessWidget {
  const CountryScreen({super.key});

  Future<void> _saveCountryAndCheckToken(
      BuildContext context, Country country) async {
    var box = Hive.box('data');
    await box.put('selectedCountry', country.name);

    ModelUser? modelUser = box.get('modelUser');
    if (modelUser != null && modelUser.token != null) {
      Get.offAllNamed(Routes.app);
    } else {
      Get.offAllNamed(Routes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const AppBackground(), Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset(Assets.pictureLogo,
                    width: MediaQuery.of(context).size.width / 1.2),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  context.l.selectCountry,
                  style: AppFonts.title1.darkGreen,
                ),
              ),
              for (final item in Country.values) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: bStyle(
                    text: item.label(context),
                    c: context,
                    colorText: AppColors.additionalGreen,
                    vertical: 15,
                    border:
                        Border.all(color: AppColors.additionalGreen, width: 1),
                    colorButt: Colors.transparent,
                    onPressed: () =>
                        _saveCountryAndCheckToken(context, item),
                  ),
                )
              ]
            ]),
      ),
    ]));
  }
}

enum Country {
  ukraine,
  kazakh;

  String label(BuildContext context) {
    switch (this) {
      case Country.ukraine:
        return context.l.countryUkraine;
      case Country.kazakh:
        return context.l.countryKazakhstan;
    }
  }
}
