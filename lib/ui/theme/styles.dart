import 'package:flutter/material.dart';

import 'colors.dart';

InputDecoration textFieldInputDecoration = const InputDecoration(
  focusColor: AppColors.white,
  focusedBorder: textFieldBorder,
  enabledBorder: textFieldBorder,
  border: textFieldBorder,
  hintText: '',
  filled: true,
  fillColor: AppColors.grey1,
);

const OutlineInputBorder textFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppColors.grey2),
  borderRadius: BorderRadius.all(Radius.circular(8)),
);
