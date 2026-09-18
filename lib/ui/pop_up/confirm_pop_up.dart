import 'package:agro/ui/buttons/button_styles.dart';
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
        backgroundColor: AppColors.grey1,
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
                  Text(title ?? '', style: AppFonts.title2.black),
               

              const SizedBox(height: 20),

              Text(description ?? '',
                  textAlign: TextAlign.center,
                  style: AppFonts.body1medium.black),
              const SizedBox(height: 20),

              /// BUTTON
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        disabledBackgroundColor: AppColors.additionalGreen,
                        backgroundColor: AppColors.grey1,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.mainGreen),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.l.cancel,
                        style: AppFonts.body2bold.copyWith(
                          color: AppColors.mainGreen,
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
