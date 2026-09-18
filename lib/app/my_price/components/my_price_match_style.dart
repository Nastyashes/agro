import 'package:agro/model/my_price/my_price_order_meta.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';

Color matchCardColor(MyPriceOrderMeta? meta, Color fallback) {
  if (meta == null || !meta.matched) return fallback;
  switch (meta.tone) {
    case 'agreed':
      return const Color(0xFFB8E8C8);
    case 'declined':
      return const Color(0xFFFFD0C8);
    default:
      return fallback;
  }
}

Color matchBorderColor(MyPriceOrderMeta? meta, Color fallback) {
  if (meta == null || !meta.matched) return fallback;
  switch (meta.tone) {
    case 'agreed':
      return AppColors.mainGreen;
    case 'declined':
      return AppColors.red;
    default:
      return fallback;
  }
}
