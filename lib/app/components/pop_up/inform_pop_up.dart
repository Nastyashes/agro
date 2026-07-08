import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

void showInformPoUp(BuildContext context, String? title, String? description,) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: AppColors.grey1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// HEADER
              
                  Text(title ?? '', style: AppFonts.body1medium.black),
                
                

              const SizedBox(height: 20),

              Text(description ?? '', style: AppFonts.body1medium.black),
              const SizedBox(height: 20),

              /// BUTTON
              Row(
                children: [
               
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
                        Navigator.pop(context);                      },
                      child: Text(
                        context.l.yes,
                        style: AppFonts.body2bold.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
