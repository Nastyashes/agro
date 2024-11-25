import 'dart:convert';

import 'package:agro/server/api/api.dart';

class Commmon extends Api {
  Future<ApiAnswer> sendMessageToBot(String message) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('admin.sendMessage',
        parameter: 'message=$message&akey=Palladium57884');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

  Future<ApiAnswer> tariffPay({required int amount}) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('checkout',
        parameter: 'amount=$amount', langActive: false, apiUrl: "api.php");
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);
    return apiAnswer;
  }

  Future<ApiAnswer> getTariffs() async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('voc.tariffs');
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);
    return apiAnswer;
  }

  Future<ApiAnswer> setOrderReaded(String orderId) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('order.setReaded', parameter: "order_id=$orderId");
    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);
    return apiAnswer;
  }
}
