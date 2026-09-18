import 'dart:convert';
import 'dart:developer';
import 'dart:io';

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
            // #region agent log
            try {
              File('/Users/siell/Documents/git/uagro/.cursor/debug-ea8539.log').writeAsStringSync(
                '${jsonEncode({
                  'sessionId': 'ea8539',
                  'hypothesisId': 'A',
                  'location': 'base_controller.dart:execute',
                  'message': 'showOverlay_started',
                  'data': {'type': runtimeType.toString()},
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                })}\n',
                mode: FileMode.append,
              );
            } catch (_) {}
            // #endregion
            result = await action();
            // #region agent log
            try {
              File('/Users/siell/Documents/git/uagro/.cursor/debug-ea8539.log').writeAsStringSync(
                '${jsonEncode({
                  'sessionId': 'ea8539',
                  'hypothesisId': 'E',
                  'location': 'base_controller.dart:execute',
                  'message': 'showOverlay_action_finished',
                  'data': {'type': runtimeType.toString()},
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                })}\n',
                mode: FileMode.append,
              );
            } catch (_) {}
            // #endregion
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