import 'package:agro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension LocaleContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;
}