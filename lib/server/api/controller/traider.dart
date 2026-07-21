import 'dart:convert';
import 'dart:developer';
import 'package:agro/model/add_banner/add_banner_model.dart';

import '../api.dart';

class Traider extends Api {
  Future<ApiAnswer> loginWithQr(String code) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request =
        await dataRequestMultipart('qr_login', parameter: 'secret=$code');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

// Отриматирекламний баннер 1.0.23

  Future<OpenContactsAdResponse> openContactsAd({
    required int orderId,
  }) async {
    final request = await dataRequestMultipart(
      'order.opencontacts',
      apiUrl: 'apiapp.php',
      parameter: 'order_id=$orderId',
    );

    final rawBody = await request.stream.bytesToString();

    final jsonData = json.decode(rawBody);

    checkAuth(jsonData);

    return OpenContactsAdResponse.fromJson(jsonData);
  }

// Замовити аналіз заявки  1.0.23

  Future<ApiAnswer> orderAnalysis({required int orderId}) async {
    ApiAnswer apiAnswer = ApiAnswer();

    var request = await dataRequestMultipartBody(
      'uagro.order.analysis',
      apiUrl: 'api.php',
      formData: {
        'order_id': orderId.toString(),
      },
    );

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

// Замовити перевізника (Telegram-бот диспетчера) 1.0.23

  Future<ApiAnswer> orderCarrier() async {
    ApiAnswer apiAnswer = ApiAnswer();

    var request = await dataRequestMultipart(
      'order.carrier',
      apiUrl: 'apiapp.php',
    );

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

//Відкрити повний контакт фермера 1.0.22

  Future<ApiAnswer> openBidContact({
    required int orderId,
  }) async {
    ApiAnswer apiAnswer = ApiAnswer();

    var request = await dataRequestMultipartBody(
      'uagro.order.contacts',
      apiUrl: 'api.php',
      formData: {
        'order_id': orderId.toString(),
      },
    );

    apiAnswer.code = request.statusCode;

    apiAnswer.data = json.decode(
      await request.stream.bytesToString(),
    );

    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

// Укласти угоду (новий ендпоінт)

  Future<ApiAnswer> dealNew({required int orderId}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart(
      'uagro.order.deal',
      apiUrl: "api.php",
      parameter: 'order_id=$orderId',
    );
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);
    return apiAnswer;
  }

  Future<ApiAnswer> getOrder({required int? orderId}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('order.view',
        parameter: 'order_id=$orderId');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

// Отримати всі заявки 1.0.22

  Future<ApiAnswer> getAllBids({int? limit, int? offset}) async {
    ApiAnswer apiAnswer = ApiAnswer();

    final params = <String>[
      if (limit != null) 'limit=$limit',
      if (offset != null) 'offset=$offset',
    ].join('&');

    var request = await dataRequestMultipart(
      'auth.my',
      apiUrl: "api.php",
      parameter: params.isEmpty ? null : params,
    );
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

//Вимкнення реклами 1.0.22

  Future<ApiAnswer> disableAds() async {
    ApiAnswer apiAnswer = ApiAnswer();

    var request = await dataRequestMultipart(
      'free.disable_ads',
      apiUrl: "api.php",
    );

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());

    return apiAnswer;
  }

  Future<ApiAnswer> getMessages() async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request =
        await dataRequestMultipart('push.getall', parameter: 'type=MESSAGE');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> readMessage(int? pushId) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('push.setreaded',
        parameter: 'push_id=$pushId');

    apiAnswer.code = request.statusCode;
    return apiAnswer;
  }

  Future<ApiAnswer> orderOpenContactFermer({required int orderId}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('order.opencontacts',
        parameter: 'order_id=$orderId');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> addPrice(
      {required int orderId,
      required String price,
      required String form,
      required String currency}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('order.addbid',
        parameter:
            'order_id=$orderId&price=$price&place_type=EXW1&send_sms=1&forma=$form&currc=$currency');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> deal({required int tenderId}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('vip_accept',
        parameter: 'tender_id=$tenderId');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> getTariff() async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('tariff');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> sendDeviceToken({required String deviceToken}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('send_devicetoken',
        parameter: 'device_token=$deviceToken');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> checkSendOffer({int? sphere = 12}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('smssender.get',
        parameter: 'sphere=$sphere');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);
    return apiAnswer;
  }

  Future<ApiAnswer> sendOffer(String? asId, String? sms) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('smssender.send',
        parameter: 'as_id=$asId&sms=$sms');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);
    return apiAnswer;
  }

  Future<AdBannerModel?> getAdBanner() async {
    final request = await dataRequestMultipart(
      'order.list',
      apiUrl: 'apiapp.php',
    );

    final jsonData = json.decode(await request.stream.bytesToString());

    checkAuth(jsonData);
log('Ad banner loaded: $jsonData');

    final banner = jsonData['feed_ad_banner'];

    if (banner == null) {
      return null;
    }

    return AdBannerModel.fromJson(banner);
  }
/*
  Future<ApiAnswer> getAllOrders(
      {required int page, required int limit}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('uagro.listorders',
        apiUrl: "api.php",
        parameter: 'sphere=0&filters=[]&page=$page&perpage=$limit');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }
*/

  /*
  Future<ApiAnswer> viewReviewTender({required int orderId}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('order.reviews',
        parameter: 'order_id=$orderId');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<OpenContactsAdResponse> openContactsAdWatched({
  required int orderId,
}) async {
  final request = await dataRequestMultipart(
    'order.opencontacts',
    apiUrl: 'apiapp.php',
    parameter: 'order_id=$orderId&ad_watched=1',
  );

  final rawBody = await request.stream.bytesToString();
  log('RAW BODY (order.opencontacts ad_watched): $rawBody');

  final jsonData = json.decode(rawBody);
  checkAuth(jsonData);

  return OpenContactsAdResponse.fromJson(jsonData);
}
*/
}
