import 'package:agro/model/model_user/model_user.dart';
import 'package:agro/ui/buttons/b_style.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:agro/routes/app_pages.dart';

class CountryScreen extends StatelessWidget {
  const CountryScreen({super.key});

  Future<void> _saveCountryAndCheckToken(
      BuildContext context, String country) async {
    var box = Hive.box('data');
    await box.put('selectedCountry', country);

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             const Padding(
              padding:  EdgeInsets.all(20), child: Image(image:AssetImage('picture/logo.png')),),
        
            Padding(
              padding: const EdgeInsets.all(20),
              
              child: Text(
                'Select Country',
                style: AppFonts.title1.darkGreen,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: bStyle(
                text: 'Україна',
                c: context,
                colorText: AppColors.additionalGreen,
                vertical: 15,
                border: Border.all(color: AppColors.additionalGreen, width: 1),
                colorButt: Colors.transparent,
                onPressed: () => _saveCountryAndCheckToken(context, 'Україна'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: bStyle(
                text: 'Қазақстан',
                c: context,
                colorText: AppColors.additionalGreen,
                vertical: 15,
                border: Border.all(color: AppColors.additionalGreen, width: 1),
                colorButt: Colors.transparent,
                onPressed: () =>
                    _saveCountryAndCheckToken(context, 'Қазақстан'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
