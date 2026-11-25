import 'dart:developer';

import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/server/api/api_client.dart';

import '../api.dart';

class Traider extends Api {
  Future<ApiAnswer> loginWithQr(String code) =>
      send('qr_login', query: {'secret': legacyQueryValue(code)});

  // Отримати рекламний баннер 1.0.23
  Future<OpenContactsAdResponse> openContactsAd({required int orderId}) async {
    final answer =
        await send('order.opencontacts', query: {'order_id': '$orderId'});
    return OpenContactsAdResponse.fromJson(answer.data);
  }

  // Замовити аналіз заявки 1.0.23
  Future<ApiAnswer> orderAnalysis({required int orderId}) => send(
        'uagro.order.analysis',
        endpoint: 'api.php',
        transport: ApiTransport.body,
        fields: {'order_id': '$orderId'},
      );

  // Замовити перевізника (Telegram-бот диспетчера) 1.0.23
  Future<ApiAnswer> orderCarrier() => send('order.carrier');

  // Відкрити повний контакт фермера 1.0.22
  Future<ApiAnswer> openBidContact({required int orderId}) => send(
        'uagro.order.contacts',
        endpoint: 'api.php',
        transport: ApiTransport.body,
        fields: {'order_id': '$orderId'},
      );

  Future<ApiAnswer> getOrder({required int? orderId}) =>
      send('order.view', query: {'order_id': '$orderId'});

  // Отримати всі заявки 1.0.22
  Future<ApiAnswer> getAllBids({int? limit, int? offset}) => send(
        'auth.my',
        endpoint: 'api.php',
        query: {
          if (limit != null) 'limit': '$limit',
          if (offset != null) 'offset': '$offset',
        },
      );

  // Вимкнення реклами 1.0.22
  Future<ApiAnswer> disableAds() =>
      send('free.disable_ads', endpoint: 'api.php');

  Future<ApiAnswer> getMessages() =>
      send('push.getall', query: {'type': 'MESSAGE'});

  /// Callers only need the status code; the body is not guaranteed JSON.
  Future<ApiAnswer> readMessage(int? pushId) async {
    try {
      return await send('push.setreaded', query: {'push_id': '$pushId'});
    } on ApiException catch (e) {
      if (e.kind != ApiErrorKind.badResponse) rethrow;
      return ApiAnswer()..code = e.statusCode;
    }
  }

  // Пошук / список заявок 1.0.26 (auth.bids.search)
  Future<ApiAnswer> searchBids({String? search, int? limit, int? offset}) {
    final trimmedSearch = search?.trim();
    return send(
      'auth.bids.search',
      endpoint: 'api.php',
      query: {
        if (trimmedSearch != null && trimmedSearch.isNotEmpty)
          'search': trimmedSearch,
        if (limit != null) 'limit': '$limit',
        if (offset != null) 'offset': '$offset',
      },
    );
  }

  Future<ApiAnswer> getTariff() => send('tariff');

  Future<ApiAnswer> sendDeviceToken({required String deviceToken}) =>
      send('send_devicetoken', query: {'device_token': deviceToken});

  Future<AdBannerModel?> getAdBanner() async {
    final answer = await send('order.list');
    final banner = answer.data is Map ? answer.data['feed_ad_banner'] : null;
    log('Get Ad banner loaded: ${banner != null}');
    return banner == null ? null : AdBannerModel.fromJson(banner);
  }
}
