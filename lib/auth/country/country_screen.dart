import 'package:agro/data/session_storage.dart';
import 'package:agro/auth/components/auth_layout.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro/routes/app_pages.dart';

class CountryScreen extends StatelessWidget {
  const CountryScreen({super.key});

  Future<void> _saveCountryAndCheckToken(
      BuildContext context, Country country) async {
    await SessionStorage.instance.saveCountry(country.name);

    if (SessionStorage.instance.hasSession) {
      Get.offAllNamed(Routes.app);
    } else {
      Get.offAllNamed(Routes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      children: [
        Text(context.l.selectCountry,
            style: AppText.title, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        for (final item in Country.values) ...[
          AppButton(
            label: item.label(context),
            style: AppButtonStyle.secondary,
            pill: true,
            onPressed: () => _saveCountryAndCheckToken(context, item),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
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
