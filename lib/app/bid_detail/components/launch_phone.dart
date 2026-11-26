import 'package:agro/generated/assets.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Call" sheet for an opened contact: phone, call, Telegram, Viber.
void showCallSheet(BuildContext context, String phone) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SingleChildScrollView(child: LaunchPhone(contact: phone)),
  );
}

class LaunchPhone extends StatelessWidget {
  final String? contact;

  const LaunchPhone({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final phone = contact ?? '';
    final l = context.l;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.phone,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(color: Palette.textTertiary)),
          const SizedBox(height: 2),
          Text(phone, textAlign: TextAlign.center, style: AppText.numL),
          const SizedBox(height: 16),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Palette.bg1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Palette.line),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(children: [
                _ContactRow(
                  leading: const Icon(Icons.call_rounded,
                      size: 24, color: Palette.green),
                  label: l.call,
                  onTap: () => onCall(phone),
                ),
                const Divider(height: 1),
                _ContactRow(
                  leading: SvgPicture.asset(Assets.authTelegram, width: 28),
                  label: 'Telegram',
                  onTap: () => openTelegram(phone: phone, context: context),
                ),
                const Divider(height: 1),
                _ContactRow(
                  leading: SvgPicture.asset(Assets.authViber, width: 28),
                  label: 'Viber',
                  onTap: () => openViber(phone: phone, context: context),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: l.close,
            style: AppButtonStyle.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void onCall(String phone) => launchUrl(Uri(scheme: 'tel', path: phone),
      mode: LaunchMode.externalApplication);

  Future<void> openTelegram({
    required BuildContext context,
    required String phone,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    const String url = 'tg://msg';
    final String errorTelegram = context.l.errorTelegram;

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse('$url?to=$phone'), mode: mode);
    } else {
      notification(text: errorTelegram, type: SnackType.error);
    }
  }

  Future<void> openViber({
    required BuildContext context,
    required String phone,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final String url = 'viber://chat?number=$phone';
    final String errorViber = context.l.errorViber;

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: mode);
    } else {
      notification(text: errorViber, type: SnackType.error);
    }
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(
      {required this.leading, required this.label, required this.onTap});

  final Widget leading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              SizedBox(width: 28, child: Center(child: leading)),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppText.bodyMedium)),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Palette.textTertiary),
            ]),
          ),
        ),
      );
}
