import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:agro/ui/utils/date_extensions.dart';

class NewHomeHeader extends StatelessWidget {
  const NewHomeHeader(
      {Key? key,
      required this.tariff,
      required this.onPressed,
      required this.onTabTopUp,
      required this.baslance})
      : super(key: key);

  final Tariff? tariff;
  final int? baslance;
  final VoidCallback? onTabTopUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isByPiece = (tariff?.isPremium == true || tariff?.isVip == true);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      InkWell(
        onTap: onPressed,
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_rounded,
                color: AppColors.mainGreen,
                size: 32,
              ),
              readText(text: context.l.menu, style: AppFonts.caption.darkGreen),
            ],
          ),
        ),
      ),
      if (isByPiece)
        headerItem(
          tariff?.balanceEnd?.formatDateShort() ?? '',
          context.l.tariffDuration,
          isValid: tariff?.balanceEnd?.isActive() ?? true,
        ),
      headerItem(
        context.uahAmount(baslance ?? 0),
        context.l.youBalance,
        isValid: true,
      ),
  /*    Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTabTopUp,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.mainGreen,
                      size: 32,
                    ),
                    readText(
                        text: context.l.notifications,
                        style: AppFonts.caption.darkGreen),
                  ],
                )),
          ), 
        ],*
      ),*/
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
