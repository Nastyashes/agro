import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

void showConfirmPoUp(BuildContext context, String? title, String? description,
    final Future<void> Function() onConfirm) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: AppColors.backgroundGradient1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentGeometry.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24,),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            Padding(
          padding: const EdgeInsets.fromLTRB(20,0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
                  Text(title ?? '', style: AppFonts.title2.white),
               

              const SizedBox(height: 20),

              Text(description ?? '',
                  textAlign: TextAlign.center,
                  style: AppFonts.body1medium.white),
              const SizedBox(height: 20),

              /// BUTTON
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        disabledBackgroundColor: AppColors.additionalGreen,
                        backgroundColor: AppColors.backgroundGradient1,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.yellow),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.l.cancel,
                        style: AppFonts.body2bold.copyWith(
                          color: AppColors.yellow,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: AppColors.additionalGreen,
                        backgroundColor: AppColors.mainGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: Text(
                        context.l.confirm,
                        style: AppFonts.body2bold.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        ])));
    },
  );
}

/// Asks the user to confirm the disable-ads charge of [amount] UAH.
/// [onConfirm] runs only after an explicit confirm; cancel/close does nothing.
void showDisableAdsConfirm(
  BuildContext context, {
  required String amount,
  required Future<void> Function() onConfirm,
}) {
  showConfirmPoUp(
    context,
    '${context.l.disableBanner.trim()}?',
    context.l.confirmChargeBody(amount),
    onConfirm,
  );
}
