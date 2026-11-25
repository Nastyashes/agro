import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

class ModelTariff {
  String? name;
  String? price;
  int? priceOld;
  String? pricePeriod, currency;

  List<String> advantages;
  List<String> disadvantages;

  ModelTariff({
    this.name,
    this.price,
    this.priceOld,
    this.pricePeriod,
    this.currency,
    this.advantages = const [],
    this.disadvantages = const [],
  });
}

ModelTariff structTariffData({required data}) {
  String? name = data['name'].toString();
  String? price =  data['price'].toString();
  int? priceOld = int.tryParse(data['price_old'].toString());
  String? pricePeriod = data['price_period'].toString();
  String? currency = data['currency'].toString();
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
  tariff.currency = currency;
  return tariff;
}

extension TariffExt on ModelTariff {
  Color get color {
    switch (name) {
      case 'VIP':
        return Palette.tariffVip;
      case 'Premium':
        return Palette.tariffPremium;
      default:
        return Palette.tariffUnlim;
    }
  }
}
