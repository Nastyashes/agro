 import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';

Widget orderInfo({
    required String header,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          readText(
            text: header,
            style: AppFonts.body4semibold.copyWith(color: AppColors.grey2),
          ),
          const Spacer(),
        Expanded(child:   readText(
            text: text,
            align: TextAlign.right,
            style: AppFonts.body4medium.copyWith(color: AppColors.primaryTextCard),
          )),
        ],
      ),
    );
  }

