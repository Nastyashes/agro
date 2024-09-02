import 'dart:convert';

import 'package:agro/server/api/api.dart';

class Commmon extends Api {

Future<ApiAnswer> sendMessageToBot(String message) async {
    ApiAnswer apiAnswer = ApiAnswer();
    var request = await dataRequestMultipart('admin.sendMessage',
        parameter:
            'message=$message&akey=Palladium57884');

    apiAnswer.code = request.statusCode;
    apiAnswer.data = json.decode(await request.stream.bytesToString());
    checkAuth(apiAnswer.data);

    return apiAnswer;
  }

}
