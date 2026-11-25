import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/model/tariff/tariff.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';

/// The server refused to start a payment, or gave no payment link.
class PaymentRejected implements Exception {
  const PaymentRejected([this.reason]);

  final Object? reason;

  @override
  String toString() => 'PaymentRejected($reason)';
}

class DisableAdsResult {
  const DisableAdsResult({
    required this.ok,
    this.message,
    this.userfieldPatch = const {},
  });

  final bool ok;

  /// Server text for the user (success or the reason it failed).
  final String? message;

  /// Fields to merge into the user's `userfield` after a successful charge.
  final Map<String, dynamic> userfieldPatch;
}

/// Balance, tariff, payments and ads settings of the signed-in user.
class AccountRepository {
  AccountRepository([Api? api]) : _api = api ?? Api();

  final Api _api;

  Future<int> balance() async {
    final data = await _map(_api.common.getBalance());
    return int.tryParse('${data['balance'] ?? 0}') ?? 0;
  }

  Future<Tariff> currentTariff() async {
    final payload = (await _map(_api.traider.getTariff()))['payload'];
    if (payload is! Map) {
      throw const ApiException(ApiErrorKind.badResponse, statusCode: 200);
    }
    return Tariff.fromJson(Map<String, dynamic>.from(payload));
  }

  Future<List<ModelTariff>> tariffs() async {
    final items = (await _map(_api.common.getTariffs()))['items'];
    if (items is! List) return const [];
    return [for (final item in items) structTariffData(data: item)];
  }

  /// Link to pay for a tariff of [amount] UAH.
  Future<String> tariffPaymentUrl(int amount) =>
      _paymentUrl(_api.common.tariffPay(amount: amount));

  /// Link to top up the balance by [amount] UAH.
  Future<String> topUpPaymentUrl(int amount) =>
      _paymentUrl(_api.common.balancePay(amount: amount));

  /// Charges the balance to switch ads off.
  Future<DisableAdsResult> disableAds() async {
    final data = await _map(_api.traider.disableAds());
    final message = data['message']?.toString();
    if (data['status'] != '+') {
      return DisableAdsResult(ok: false, message: message);
    }

    final userfield = data['userfield'];
    final until = data['ads_disabled_until'] ??
        (userfield is Map ? userfield['ads_disabled_until'] : null);

    return DisableAdsResult(
      ok: true,
      message: message,
      userfieldPatch: {
        if (until != null) 'ads_disabled_until': until,
        if (userfield is Map) ...Map<String, dynamic>.from(userfield),
        'is_ads_disabled': true,
      },
    );
  }

  /// User flags (ads state etc.) that the backend returns with `auth.my`.
  Future<Map<String, dynamic>> userfield() async {
    final userfield = (await _map(_api.traider.getAllBids()))['userfield'];
    return userfield is Map ? Map<String, dynamic>.from(userfield) : {};
  }

  Future<void> registerDeviceToken(String token) async {
    await _api.traider.sendDeviceToken(deviceToken: token);
  }

  static Future<Map<String, dynamic>> _map(Future<ApiAnswer> call) async {
    final data = (await call).data;
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  static Future<String> _paymentUrl(Future<ApiAnswer> call) async {
    final data = (await call).data;
    if (data is! Map) throw const PaymentRejected('invalid response');
    if (data['error'] != null) throw PaymentRejected(data['error']);

    final url = findPaymentUrl(Map<String, dynamic>.from(data));
    if (url == null) throw const PaymentRejected('no payment url');
    return url;
  }
}

/// Finds the payment link the backend returns under one of several keys,
/// possibly nested in `data` / `payload` / `result`.
String? findPaymentUrl(Map<String, dynamic> data) {
  for (final key in ['url', 'pay_url', 'payment_url', 'link']) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  for (final key in ['data', 'payload', 'result']) {
    final nested = data[key];
    if (nested is Map) {
      final url = findPaymentUrl(Map<String, dynamic>.from(nested));
      if (url != null) return url;
    }
  }
  return null;
}
