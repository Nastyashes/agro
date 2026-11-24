import 'package:agro/server/api/api.dart';

class Commmon extends Api {
  // Оплатити тариф з балансу 1.0.22
  Future<ApiAnswer> tariffPay({required int amount}) => send('checkout',
      endpoint: 'api.php', query: {'amount': '$amount'}, withLang: false);

  // Поповнити баланс 1.0.22
  Future<ApiAnswer> balancePay({required int amount}) =>
      send('uagro.wallet.topup',
          endpoint: 'api.php', query: {'amount': '$amount'});

  Future<ApiAnswer> getTariffs() => send('voc.tariffs');

  // Отримати баланс 1.0.22
  Future<ApiAnswer> getBalance() => send('balance', endpoint: 'api.php');
}
