import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

String localizeDeliveryType(String? value, BuildContext context) {
  final l = context.l;
  switch (value ?? '') {
    case '':
    case 'ALL':
      return l.deliveryTypeAny;
    case 'EXWG':
      return l.deliveryTypeEXWG;
    case 'EXWF':
      return l.deliveryTypeEXWF;
    case 'EXWE':
      return l.deliveryTypeEXWE;
    case 'CPT':
      return l.deliveryTypeCPT;
    case 'CPTP':
      return l.deliveryTypeCPTP;
    case 'CPTE':
      return l.deliveryTypeCPTE;
    default:
      return value!;
  }
}

String localizePaymentType(String? value, BuildContext context) {
  final l = context.l;
  switch (value ?? '') {
    case '1ф/2ф':
      return l.paymentType1f2f;
    case '1ф Безгот':
      return l.paymentType1fNonCash;
    case '2ф Готiвка':
      return l.paymentType2fCash;
    case '3ф (б/г без ПДВ)':
      return l.paymentType3fNonCashVatFree;
    default:
      return value ?? '—';
  }
}

String localizeAmountType(String? value, BuildContext context) {
  final l = context.l;
  switch (value ?? '') {
    case '':
    case 'tonn':
      return l.amountTypeTon;
    case 'b500':
      return l.amountTypeBigBag500;
    case 'b050':
      return l.amountTypeBag50;
    case 'b000':
      return l.amountTypeBulk;
    case 'poso':
      return l.amountTypeSeedUnit;
    case 'gekt':
      return l.amountTypeHectare;
    default:
      return value!;
  }
}
