import 'package:agro/model/my_price/my_price_order_meta.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';

Color matchCardColor(MyPriceOrderMeta? meta, Color fallback) {
  if (meta == null || !meta.matched) return fallback;
  switch (meta.tone) {
    case 'agreed':
      return const Color.fromARGB(52, 0, 255, 166);
    case 'declined':
      return const Color.fromARGB(81, 255, 65, 112);
    default:
      return fallback;
  }
}

Color matchBorderColor(MyPriceOrderMeta? meta, Color fallback) {
  if (meta == null || !meta.matched) return fallback;
  switch (meta.tone) {
    case 'agreed':
      return AppColors.matchCardBorderAgreed;
    case 'declined':
      return AppColors.matchCardBorderDeclined;
    default:
      return fallback;
  }
}
