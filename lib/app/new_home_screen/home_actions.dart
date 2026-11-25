import 'dart:developer';

import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// UI-side money actions started from the home screen and its dialogs.

/// Runs [NewHomeController.disableAds] and shows its outcome.
Future<void> disableAdsWithFeedback(BuildContext context) async {
  final message = await Get.find<NewHomeController>().disableAds();
  if (!context.mounted) return;
  if (message == null) {
    notification(text: context.l.somethingWentWrong);
  } else {
    inAppNotification(text: message, c: context);
  }
}

Future<void> payBalance(int amount, BuildContext context) async {
  try {
    final payUrl = await AccountRepository().topUpPaymentUrl(amount);
    final opened = await openPaymentUrl(payUrl);
    if (!opened && context.mounted) {
      notification(text: context.l.somethingWentWrong);
    }
  } catch (e, stackTrace) {
    log('payBalance failed: $e', error: e, stackTrace: stackTrace);
    if (context.mounted) {
      notification(text: context.l.somethingWentWrong);
    }
  }
}

Future<bool> openPaymentUrl(String rawUrl) async {
  var value = rawUrl.trim();
  if (value.startsWith('//')) {
    value = 'https:$value';
  } else if (!value.contains('://')) {
    final base = Api.baseUrl();
    value = '$base${value.startsWith('/') ? value.substring(1) : value}';
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return false;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (launched) return true;
  } catch (e) {
    log('openPaymentUrl external launch failed, retrying in-app: $e');
  }

  try {
    final launched = await launchUrl(uri);
    return launched;
  } catch (e) {
    return false;
  }
}
