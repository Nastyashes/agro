import 'package:agro/ui/text_field/text_field.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

void showTopUpDialog(BuildContext context, int? balance,
    final void Function(int amount) onSelect) {
  final TextEditingController controller = TextEditingController();

  int selectedAmount = 100;
  bool isNoValidSum = false;
  showDialog<int>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void selectAmount(int amount) {
            setState(() {
              selectedAmount = amount;
              controller.text = amount.toString();
            });
          }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l.topUpBalance,
                          style: AppFonts.body1medium.black),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 10,
                    runSpacing: 10,
                    children: [100, 200, 500, 1000].map((amount) {
                      return GestureDetector(
                        onTap: () => selectAmount(amount),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.5 - 30,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedAmount == amount
                                ? Colors.green.withOpacity(0.15)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(context.uahAmount(amount),
                              style: selectedAmount == amount
                                  ? AppFonts.body2medium.darkGreen
                                  : AppFonts.body2medium.grey4),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// INPUT LABEL
                  Text(context.l.orInputSum, style: AppFonts.body3medium.black),

                  const SizedBox(height: 10),

                  /// INPUT
                  TextFieldWidget(
                    padding: const EdgeInsets.only(bottom: 12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.grey2),
                    text: context.l.sum,
                    height: 54,
                    textStyle: AppFonts.body1medium.black,
                    hintStyle: AppFonts.body1medium.grey3,
                    openKeyboardAuto: false,
                    colorBg: AppColors.grey1,
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        selectedAmount = int.tryParse(value) ?? 0;
                        isNoValidSum = false;
                      });
                    },
                  ),
                  if (isNoValidSum)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        context.l.errorPaymant,
                        style: AppFonts.body2bold.red,
                      ),
                    ),
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
                          onPressed: selectedAmount >= 10
                              ? () {
                                  Navigator.pop(context);
                                  onSelect(selectedAmount);
                                }
                              : () {
                                  setState(() {
                                    isNoValidSum = true;
                                  });
                                },
                          child: Text(
                            context.l.onPay,
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
    },
  );
}
