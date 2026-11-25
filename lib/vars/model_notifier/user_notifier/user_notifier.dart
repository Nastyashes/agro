import 'package:agro/data/session_storage.dart';
import 'package:flutter/material.dart';
import '../../../model/model_user/model_user.dart';

class UserNotifier extends ChangeNotifier {
  ModelUser modelUser = SessionStorage.instance.user ?? ModelUser();

  setModelUser({required ModelUser val, bool upd = true}) {
    modelUser = val;
    SessionStorage.instance.saveUser(modelUser);
    if (upd) notifyListeners();
  }

}