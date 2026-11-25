import 'package:agro/ui/components/confirm_dialog.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// Confirms, then runs [onConfirm]. Cancel, the scrim or back do nothing.
Future<void> showConfirmPoUp(
  BuildContext context,
  String? title,
  String? description,
  Future<void> Function() onConfirm, {
  String? confirmLabel,
  IconData? icon,
  bool destructive = false,
}) async {
  final confirmed = await showAppConfirm(
    context,
    title: title ?? '',
    text: description,
    confirmLabel: confirmLabel ?? context.l.confirm,
    icon: icon,
    destructive: destructive,
  );
  if (confirmed) await onConfirm();
}

/// Asks the user to confirm the disable-ads charge of [amount] UAH.
/// [onConfirm] runs only after an explicit confirm; cancel/close does nothing.
Future<void> showDisableAdsConfirm(
  BuildContext context, {
  required String amount,
  required Future<void> Function() onConfirm,
}) =>
    showConfirmPoUp(
      context,
      '${context.l.disableBanner.trim()}?',
      context.l.confirmChargeBody(amount),
      onConfirm,
      icon: Icons.block_rounded,
    );
