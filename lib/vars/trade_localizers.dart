import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

String localizeDeliveryType(String? value, BuildContext context) {
  final l = context.l;
  switch (value ?? '') {
    case '':
    case AppConstants.deliveryAll:
      return l.deliveryTypeAny;
    case AppConstants.deliveryExwg:
      return l.deliveryTypeEXWG;
    case AppConstants.deliveryExwf:
      return l.deliveryTypeEXWF;
    case AppConstants.deliveryExwe:
      return l.deliveryTypeEXWE;
    case AppConstants.deliveryCpt:
      return l.deliveryTypeCPT;
    case AppConstants.deliveryCptp:
      return l.deliveryTypeCPTP;
    case AppConstants.deliveryCpte:
      return l.deliveryTypeCPTE;
    default:
      return value!;
  }
}

String localizePaymentType(String? value, BuildContext context) {
  final l = context.l;
  switch (value ?? '') {
    case AppConstants.paymentApi1f2f:
      return l.paymentType1f2f;
    case AppConstants.paymentApi1fNonCash:
      return l.paymentType1fNonCash;
    case AppConstants.paymentApi2fCash:
      return l.paymentType2fCash;
    case AppConstants.paymentApi3fNonCashVatFree:
      return l.paymentType3fNonCashVatFree;
    default:
      return value ?? AppConstants.emDash;
  }
}

String localizeAmountType(String? value, BuildContext context) {
  final l = context.l;
  switch (value ?? '') {
    case '':
    case AppConstants.amountApiTonn:
      return l.amountTypeTon;
    case AppConstants.amountApiBigBag500:
      return l.amountTypeBigBag500;
    case AppConstants.amountApiBag50:
      return l.amountTypeBag50;
    case AppConstants.amountApiBulk:
      return l.amountTypeBulk;
    case AppConstants.amountApiSeedUnit:
      return l.amountTypeSeedUnit;
    case AppConstants.amountApiHectare:
      return l.amountTypeHectare;
    default:
      return value!;
  }
}
