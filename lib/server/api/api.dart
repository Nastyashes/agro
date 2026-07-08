import 'dart:convert';
import 'dart:developer';

import 'package:agro/server/api/controller/common.dart';
import 'package:agro/auth/country/country_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../../routes/app_pages.dart';
import 'controller/auth.dart';
import 'controller/fermer.dart';
import 'controller/traider.dart';

int numRequestSend = 0;

class Api {
  //   'Authorization': 'Bearer ${Hive.box('data').get('modelUser') != null ? Hive.box('data').get('modelUser').token : ''}',
  Map<String, String> headers() =>
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Map<String, String> headersNoBearer() =>
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  String getUrl() {
    var box = Hive.box('data');
    String? selectedCountry = box.get('selectedCountry');
    if (selectedCountry == Country.kazakh.name) {
      return 'https://uagro.kz/';
    } else {
      return "https://uagro.trade/";
    }
  }

  String getLanguage() {
    var box = Hive.box('data');
    return box.get('language') ?? 'en';
  }

  //final url = 'https://uagro.trade/apiapp.php';

  Future<StreamedResponse> dataRequest(path,
      {String req = 'POST',
      String? parameter,
      bool urlActive = true,
      bool bearerActive = true,
      String? body,
      required BuildContext c}) async {
    StreamedResponse request = await ((Request(req,
            Uri.parse('${urlActive ? getUrl() : ''}$path?${parameter ?? ''}')))
          ..headers.addAll(bearerActive ? headers() : headersNoBearer())
          ..body = body ?? json.encode({}))
        .send();

    log('${getUrl()}$path${parameter ?? ''}');

    return request;
  }

  Future<StreamedResponse> dataRequestMultipartBody(
    String method, {
    String apiUrl = "apiapp.php",
    bool bearerActive = true,
    bool langActive = true,
    Map<String, String>? formData,
  }) async {
    final key = Hive.box('data').get('modelUser')?.token ?? '';

    final url = '${getUrl()}$apiUrl';

    final request = MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers.addAll(
      bearerActive ? headers() : headersNoBearer(),
    );

    request.fields['method'] = method;
    request.fields['key'] = key;

    if (langActive) {
      request.fields['lang'] = getLanguage();
    }

    if (formData != null) {
      request.fields.addAll(formData);
    }

    log('POST $url');
 //   log('FIELDS: ${request.fields}');

    return await request.send();
  }

  Future<StreamedResponse> dataRequestMultipart(method,
      {String? parameter,
      String apiUrl = "apiapp.php",
      bool bearerActive = true,
      bool langActive = true,
      Map<String, String>? formData}) async {
    String key = Hive.box('data').get('modelUser') == null ||
            Hive.box('data').get('modelUser').token == null
        ? ''
        : Hive.box('data').get('modelUser').token;
    String url =
        '${getUrl()}$apiUrl?method=$method&key=$key${parameter == null ? '' : '&$parameter'}${langActive ? '&lang=${getLanguage()}' : ''}';
    var request = MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(bearerActive ? headers() : headersNoBearer());

    if (formData != null) {
      formData.forEach((key, value) {
        request.fields[key] = value;
      });
    }
    log(url);

    return await request.send();
  }

  Auth get auth => Auth();

  Fermer get fermer => Fermer();

  Traider get traider => Traider();

  Commmon get common => Commmon();
}

class ApiAnswer {
  int? code;
  dynamic data;
}

void checkAuth(data) {
 // log('data: $data');
  try {
    if (data['message'] == 'Unauthorized') {
      Hive.box('data').put('pinCode', null);
      Hive.box('data').clear();

      Get.offAllNamed(Routes.auth);
    }
  } catch (_) {}
}
