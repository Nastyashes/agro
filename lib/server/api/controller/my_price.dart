import 'dart:developer';
import 'dart:math' as math;

import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';

/// Client-side code for a request that never reached the server.
const myPriceNetworkError = 'network_error';

class MyPriceApi extends Api {
  Future<MyPriceResult<T>> _post<T>(
    String method, {
    Map<String, String>? formData,
    T Function(dynamic data)? parse,
  }) async {
    try {
      final answer = await send(
        method,
        endpoint: 'api.php',
        transport: ApiTransport.body,
        fields: formData ?? const {},
      );
      final jsonData = answer.data;
      log('MyPriceApi $method formData=$formData');
      log('MyPriceApi $method raw=$jsonData');
      return MyPriceResult<T>.fromJson(jsonData, parse: parse);
    } catch (e, stackTrace) {
      log(
        'MyPriceApi $method failed',
        error: e,
        stackTrace: stackTrace,
      );
      // Never show the raw exception to the user (BUG-006); a lost
      // connection gets its own code and a localized text.
      final offline = e is ApiException &&
          (e.kind == ApiErrorKind.network || e.kind == ApiErrorKind.timeout);
      return MyPriceResult<T>(
        ok: false,
        errorCode: offline ? myPriceNetworkError : 'database_error',
      );
    }
  }

  Future<MyPriceResult<MyPriceOverview>> overview() {
    return _post(
      'my_price.overview',
      parse: MyPriceOverview.fromJson,
    );
  }

  Future<MyPriceResult<MyPriceQuote>> quote(MyPriceActivateParams params) {
    return _post(
      'my_price.quote',
      formData: params.toFormData(),
      parse: MyPriceQuote.fromJson,
    );
  }

  Future<MyPriceResult<MyPriceActivateResult>> activate({
    required MyPriceActivateParams params,
    required String requestId,
    required String expectedAction,
    required double expectedAmount,
  }) {
    return _post(
      'my_price.activate',
      formData: {
        ...params.toFormData(),
        'request_id': requestId,
        'expected_action': expectedAction,
        'expected_amount': expectedAmount.toString(),
        'confirmed': '1',
      },
      parse: MyPriceActivateResult.fromJson,
    );
  }

  Future<MyPriceResult<dynamic>> update({
    required String targetType,
    required int targetId,
    double? pricePerTon,
    int? teamUserId,
  }) {
    final formData = <String, String>{
      'target_type': targetType,
      'target_id': targetId.toString(),
    };
    if (pricePerTon != null) {
      formData['price_per_ton'] = pricePerTon.toString();
    }
    if (teamUserId != null) {
      formData['team_user_id'] = teamUserId.toString();
    }
    return _post('my_price.update', formData: formData);
  }

  Future<MyPriceResult<dynamic>> deleteCombination(int combinationId) {
    return _post(
      'my_price.delete',
      formData: {
        'combination_id': combinationId.toString(),
        'confirmed': '1',
      },
    );
  }

  Future<MyPriceResult<dynamic>> matchAck(int matchId) {
    return _post(
      'my_price.match.ack',
      formData: {'match_id': matchId.toString()},
    );
  }

  Future<MyPriceResult<MyPriceDealQuote>> dealQuote({required int orderId}) {
    return _post(
      'my_price.deal.quote',
      formData: {'order_id': orderId.toString()},
      parse: MyPriceDealQuote.fromJson,
    );
  }

  Future<MyPriceResult<dynamic>> dealConfirm({
    required int orderId,
    required double expectedAmount,
  }) {
    return _post(
      'my_price.deal.confirm',
      formData: {
        'order_id': orderId.toString(),
        'expected_amount': expectedAmount.toString(),
        'confirmed': '1',
      },
    );
  }

  Future<MyPriceResult<MyPriceDealsPage>> dealsList({
    int limit = 50,
    int offset = 0,
  }) {
    return _post(
      'my_price.deals.list',
      formData: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
      parse: MyPriceDealsPage.fromJson,
    );
  }
}

String generateMyPriceRequestId() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = math.Random.secure();
  final suffix = List.generate(
    16,
    (_) => chars[random.nextInt(chars.length)],
  ).join();
  return 'mp.${DateTime.now().millisecondsSinceEpoch}.$suffix';
}
