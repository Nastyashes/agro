import 'package:agro/app/new_home_screen/home_actions.dart';
import 'package:agro/ui/pop_up/top_up_balance_popup.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MyPriceErrorAction {
  message,
  retryQuote,
  topUp,
  refreshOverview,
  hideFeature,
  relogin,
  keepRequestId,
  retrySameRequest,
  refreshOrder,
  validation,
}

class MyPriceErrorOutcome {
  final MyPriceErrorAction action;
  final String text;

  const MyPriceErrorOutcome({
    required this.action,
    required this.text,
  });
}

MyPriceErrorOutcome resolveMyPriceError(
  BuildContext context,
  MyPriceResult result,
) {
  final l = context.l;
  final message = result.fallbackMessage(l.myPriceErrorGeneric);

  switch (result.errorCode) {
    case 'feature_disabled':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.hideFeature,
        text: l.myPriceFeatureDisabled,
      );
    case 'unauthorized':
    case 'user_not_found':
    case 'user_disabled':
      return const MyPriceErrorOutcome(
        action: MyPriceErrorAction.relogin,
        text: '',
      );
    case 'trader_account_required':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: l.traderAccountRequired,
      );
    case 'post_required':
    case 'method_not_found':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: l.myPriceImplementationError,
      );
    case 'validation_failed':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.validation,
        text: message,
      );
    case 'region_not_found':
    case 'product_not_found':
    case 'team_member_required':
    case 'team_member_not_found':
    case 'team_member_phone_required':
    case 'entry_not_editable':
    case 'combination_not_found':
    case 'reservation_not_found':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.refreshOverview,
        text: message,
      );
    case 'promo_unavailable':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: l.promoUnavailable,
      );
    case 'confirmation_required':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.retryQuote,
        text: message,
      );
    case 'slot_state_changed':
    case 'price_changed':
    case 'deal_price_changed':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.retryQuote,
        text: message,
      );
    case 'insufficient_balance':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.topUp,
        text: message,
      );
    case 'idempotency_conflict':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.keepRequestId,
        text: message,
      );
    case 'match_not_available':
    case 'match_not_found':
    case 'deal_claim_taken':
    case 'order_unavailable':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.refreshOrder,
        text: message,
      );
    case 'match_selected_number_required':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: l.matchSelectedNumberRequired,
      );
    case 'contact_required':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: l.contactRequiredBeforeDeal,
      );
    case 'deal_already_created':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: message,
      );
    case 'database_error':
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.retrySameRequest,
        text: message,
      );
    default:
      return MyPriceErrorOutcome(
        action: MyPriceErrorAction.message,
        text: message,
      );
  }
}

Future<MyPriceErrorAction> showMyPriceError(
  BuildContext context,
  MyPriceResult result, {
  MainController? mainController,
}) async {
  final outcome = resolveMyPriceError(context, result);

  if (outcome.action == MyPriceErrorAction.relogin) {
    checkAuth({'message': 'Unauthorized'});
    return outcome.action;
  }

  if (outcome.action == MyPriceErrorAction.hideFeature) {
    mainController?.disableMyPrice();
  }

  if (outcome.text.isNotEmpty && context.mounted) {
    inAppNotification(text: outcome.text, c: context);
  }

  if (outcome.action == MyPriceErrorAction.topUp && context.mounted) {
    final main = mainController ??
        (Get.isRegistered<MainController>()
            ? Get.find<MainController>()
            : null);
    showTopUpDialog(
        context, main?.balance, (amount) => payBalance(amount, context));
  }

  return outcome.action;
}
