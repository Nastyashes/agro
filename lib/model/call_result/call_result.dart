import 'dart:ui';
import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'call_result.g.dart';

@HiveType(typeId: 3)
enum CallResult {
  @HiveField(0)
  agreement('agreementKey', AppColors.mainGreen),
  @HiveField(1)
  noAnswer('noAnswerKey', AppColors.yellow),
  @HiveField(2)
  noConnection('noConnectionKey', AppColors.yellow),
  @HiveField(3)
  wrongPrice('wrongPriceKey', AppColors.red),
  @HiveField(4)
  notActual('notActualKey', AppColors.red);

  final String localizationKey;
  final Color color;

  const CallResult(this.localizationKey, this.color);

  String getLabel(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (localizationKey) {
      case 'agreementKey':
        return localizations!.agreementKey;
      case 'noAnswerKey':
        return localizations!.noAnswerKey;
      case 'noConnectionKey':
        return localizations!.noConnectionKey;
      case 'wrongPriceKey':
        return localizations!.wrongPriceKey;
      case 'notActualKey':
        return localizations!.notActualKey;
      default:
        return '';
    }
  }
}
