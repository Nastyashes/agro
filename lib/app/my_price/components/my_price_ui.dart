import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/components/my_price_error.dart';
import 'package:agro/controllers/main_controler.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/model/my_price/my_price_result.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Dialogs a My price controller needs mid-flow. Screens provide
/// [ScreenMyPriceUi]; tests provide a fake, so controllers hold no
/// BuildContext.
abstract class MyPriceUi {
  Future<MyPriceErrorAction> showError(MyPriceResult result);

  /// Shows what will be charged for [quote]; true if the user confirms.
  Future<bool> confirmActivation(MyPriceQuote quote);

  Future<bool> confirmDelete();
}

class ScreenMyPriceUi implements MyPriceUi {
  ScreenMyPriceUi(this.context, {this.mainController});

  final BuildContext context;
  final MainController? mainController;

  @override
  Future<MyPriceErrorAction> showError(MyPriceResult result) async {
    if (!context.mounted) return MyPriceErrorAction.message;
    return showMyPriceError(context, result, mainController: mainController);
  }

  @override
  Future<bool> confirmActivation(MyPriceQuote quote) async {
    if (!context.mounted) return false;
    final l = context.l;
    final amount = quote.pricing.chargedAmount ?? 0;
    final date = quote.slot.activeUntil == null
        ? '—'
        : DateFormat('dd.MM.yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(quote.slot.activeUntil! * 1000),
          );
    final body = StringBuffer()
      ..writeln(
          quote.isReserve ? l.combinationOccupied(date) : l.actionActivate)
      ..writeln(l.confirmChargeBody(amount.toString()))
      ..writeln('${l.selectedPhone}: ${quote.teamPhone ?? ''}');

    return showMyPriceConfirmDialog(
      context: context,
      title: quote.isReserve ? l.actionReserve : l.actionActivate,
      body: body.toString(),
    );
  }

  @override
  Future<bool> confirmDelete() async {
    if (!context.mounted) return false;
    return showMyPriceConfirmDialog(
      context: context,
      title: context.l.deleteCombinationTitle,
      body: context.l.deleteCombinationBody,
      confirmText: context.l.delete,
    );
  }
}
