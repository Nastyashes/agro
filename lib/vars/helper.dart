import 'package:agro/l10n/app_localizations.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:flutter/material.dart';

extension LocaleContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;

  String uahAmount(Object? amount) => '${amount ?? 0} ${l.uahShort}';

  String adsPriceLabel() => uahAmount(AppConstants.adsPrice);
}

bool isSet(String? value) {
  return value != null && value.trim().isNotEmpty;
}