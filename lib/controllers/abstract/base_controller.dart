import 'dart:developer';

import 'package:agro/load/load_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  final RxnString _errorText = RxnString();
  final RxBool loading = false.obs;
  final RxnString _responseInfoText = RxnString();

  String? get errorText => _errorText.value;

  String? get responseInfoText => _responseInfoText.value;

  void updateResponseInfoText(String? text) {
    _responseInfoText.value = text;
  }

  void updateErrorText(String? errorText) {
    _errorText.value = errorText;
  }

  Future<T> execute<T>(
    Future<T> Function() action, {
    bool showLoader = false,
  }) async {
    updateErrorText(null);
    loading.value = true;

    try {
      if (showLoader) {
        late T result;

        await Get.showOverlay(
          asyncFunction: () async {
            result = await action();
          },
          loadingWidget: const Center(
            child: AppCircularProgressIndicator(),
          ),
        );

        return result;
      }

      return await action();
    } catch (e, stackTrace) {
      updateErrorText(e.toString());

      log(
        '$runtimeType error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      loading.value = false;
    }
  }

  Future<void> load(
    Future<void> Function() action,
  ) async {
    await execute(
      action,
      showLoader: true,
    );
  }

  Future<void> loadIfValid(
    Future<void> Function() action,
  ) async {
    try {
      await load(action);
    } catch (_) {
      // Error already logged and stored by execute().
    }
  }
}