import 'dart:convert';
import 'dart:developer';

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
      return 'https://uagro.kz/apiapp.php';
    } else {
      return "https://uagro.trade/apiapp.php";
    }
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

  Future<StreamedResponse> dataRequestMultipart(method,
      {String? parameter,
      bool urlActive = true,
      bool bearerActive = true,
      Map<String, String>? formData}) async {
    var request = MultipartRequest(
        'POST',
        Uri.parse('${urlActive ? getUrl() : ''}?method=$method&'
            'key=${Hive.box('data').get('modelUser') == null || Hive.box('data').get('modelUser').token == null ? '' : Hive.box('data').get('modelUser').token}${parameter == null ? '' : '&$parameter'}'));

    request.headers.addAll(bearerActive ? headers() : headersNoBearer());

    if (formData != null) {
      formData.forEach((key, value) {
        request.fields[key] = value;
      });
    }
    log('${getUrl()}/?method=$method?${parameter ?? ''}');

    return await request.send();
  }

  Auth get auth => Auth();

  Fermer get fermer => Fermer();

  Traider get traider => Traider();
}

class ApiAnswer {
  int? code;
  dynamic data;
}

void checkAuth(data) {
  log('data: $data');
  try {
    if (data['message'] == 'Unauthorized') {
      Hive.box('data').put('pinCode', null);
      Hive.box('data').clear();

      Get.offAllNamed(Routes.auth);
    }
  } catch (_) {}
}
