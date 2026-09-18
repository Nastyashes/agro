class AppConstants {
  AppConstants._();

  static const String adsPrice = '150';
  static const String fallbackAdImage =
      'https://uagro.trade/uploads/vipline/6a45509dbb6ba_photo_2026-07-01_20-38-02.jpg';
  static const String fallbackAdPhone = '+380774804040';
  static const int adEveryBids = 5;
  static const int bidsPageLimit = 20;
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const String siteUrl = 'https://uagro.trade/';
  static const String supportTelegramUrl = 'https://t.me/uagro_admin';
  static const String privacyPolicyUrl =
      'https://www.freeprivacypolicy.com/live/3afe785c-8de8-4a5b-985b-353bfca6bd17';

  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String emDash = '—';
  static const String currencySymbolUah = '₴';
  static const String currencyCodeUah = 'UAH';
  static const String currencyCodeUsd = 'USD';
  static const String currencyCodeEur = 'EUR';
  static const String paymentForm1f = '1f';
  static const String paymentForm2f = '2f';
  static const String tariffByPieceName = 'ПОШТУЧНО';

  static const String deliveryAll = 'ALL';
  static const String deliveryExwg = 'EXWG';
  static const String deliveryExwf = 'EXWF';
  static const String deliveryExwe = 'EXWE';
  static const String deliveryCpt = 'CPT';
  static const String deliveryCptp = 'CPTP';
  static const String deliveryCpte = 'CPTE';

  static const String paymentApi1f2f = '1ф/2ф';
  static const String paymentApi1fNonCash = '1ф Безгот';
  static const String paymentApi2fCash = '2ф Готiвка';
  static const String paymentApi3fNonCashVatFree = '3ф (б/г без ПДВ)';

  static const String amountApiTonn = 'tonn';
  static const String amountApiBigBag500 = 'b500';
  static const String amountApiBag50 = 'b050';
  static const String amountApiBulk = 'b000';
  static const String amountApiSeedUnit = 'poso';
  static const String amountApiHectare = 'gekt';
}
