import 'package:agro/data/session_storage.dart';
import 'dart:developer';

import 'package:get/get.dart';

import 'model_user.dart';
import '../../routes/app_pages.dart';

structUserData(
    {required data, bool login = false, String? token}) {
  ModelUser modelUser = ModelUser();
  try {
    modelUser.id = data['id'].toString();
    modelUser.phone = data['phone'];
    modelUser.email = data['email'];
    modelUser.role = data['role'];
    modelUser.name = data['name'];
    modelUser.token = token;
  } catch (err) {
    log(err.toString());
  }
  if (login) {
    SessionStorage.instance.saveUser(modelUser);

    Get.offAllNamed(Routes.app);
  } else {
    return modelUser;
  }
  return null;
}

  ModelUser? parseUser({required dynamic data, String? token}) {
    ModelUser modelUser = ModelUser();
    try {
      modelUser.id = data['id'].toString();
      modelUser.phone = data['phone'];
      modelUser.email = data['email'];
      modelUser.role = data['role'];
      modelUser.name = data['name'];
      modelUser.token = token;
    } catch (err) {
      log(err.toString());
      return null;
    }
    return modelUser;
  }
