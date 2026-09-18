import 'package:flutter/material.dart';

import 'base_controller.dart';

abstract class FormController extends BaseController {
  late final GlobalKey<FormState> formKey;

  bool validate = true;

  @override
  void onInit() {
    formKey = GlobalKey<FormState>();
    super.onInit();
  }
}