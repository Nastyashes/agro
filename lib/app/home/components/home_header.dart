import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:agro/ui/utils/date_extensions.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader(
      {Key? key,
      required this.tariff,
      required this.onTabTopUp,
      required this.baslance})
      : super(key: key);

  final Tariff? tariff;
  final int? baslance;
  final VoidCallback? onTabTopUp;

  @override
  Widget build(BuildContext context) {
    final isByPiece = (tariff?.isPremium == true || tariff?.isVip == true);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      headerItem((tariff?.orderCount ?? 0).toString(), context.l.bids),
      //    headerItem((tariff?.balanceContactsDayOsttk ?? 0).toString(),
      //        context.l.encounters),
      //    headerItem((tariff?.balanceSms ?? 0).toString(), context.l.sms),

      if (isByPiece)
        headerItem(
          tariff?.balanceEnd?.formatDateShort() ?? '',
          context.l.tariffDuration,
          isValid: tariff?.balanceEnd?.isActive() ?? true,
        ),
      headerItem(
        '${baslance ?? 0} грн',
        context.l.youBalance,
        isValid: true,
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTabTopUp,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: AppColors.mainGreen),
              child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(context.l.topUp, style: AppFonts.body2medium.white)
                    ],
                  )),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget headerItem(String value, String description, {bool isValid = true}) {
    return Column(children: [
      readText(
          text: value,
          style:
              isValid ? AppFonts.body1bold.mainGreen : AppFonts.body1bold.red),
      readText(text: description, style: AppFonts.caption.darkGreen)
    ]);
  }
}
