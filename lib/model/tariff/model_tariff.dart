import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class ModelTariff {
  String? name;
  int? price;
  int? priceOld;
  String? pricePeriod;

  List<String> advantages;
  List<String> disadvantages;

  ModelTariff({
    this.name,
    this.price,
    this.priceOld,
    this.pricePeriod,
    this.advantages = const [],
    this.disadvantages = const [],
  });
}

ModelTariff structTariffData({required data}) {
  String? name = data['name'];
  int? price = data['price'];
  int? priceOld = data['price_old'];
  String? pricePeriod = data['price_period'];
  List<String> advantages = [];
  for (var element in data['options_ok']) {
    advantages.add(element);
  }
  List<String> disadvantages = [];
  for (var element in data['options_no']) {
    disadvantages.add(element);
  }
  ModelTariff tariff = ModelTariff();
  tariff.advantages = advantages;
  tariff.disadvantages = disadvantages;
  tariff.price = price;
  tariff.priceOld = priceOld;
  tariff.name = name;
  tariff.pricePeriod = pricePeriod;
  return tariff;
}

extension TariffExt on ModelTariff {
  Color get color {
    switch (name) {
      case 'VIP':
        return AppColors.tariffVip;
      case 'Premium':
        return AppColors.tariffPremium;
      default:
        return AppColors.tariffBezlim;
    }
  }
}
