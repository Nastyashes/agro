import 'dart:async';

import 'package:agro/generated/assets.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> showAdBannerDialog(
  BuildContext context, {
  required String imageUrl,
  String? phone,
  required String price,
  required Future<void> Function() onDisableAds,
  Duration duration = const Duration(seconds: 30),
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AdBannerDialog(
      imageUrl: imageUrl,
      phone: phone,
      duration: duration,
      price: price,
      onDisableAds: onDisableAds,
    ),
  );

  return result ?? false;
}

class _AdBannerDialog extends StatefulWidget {
  const _AdBannerDialog({
    required this.imageUrl,
    this.phone,
    this.onDisableAds,
    required this.duration,
    required this.price,
  });

  final String imageUrl;
  final String? phone;
  final Duration duration;
  final String price;
  final Future<void> Function()? onDisableAds;

  @override
  State<_AdBannerDialog> createState() => _AdBannerDialogState();
}

class _AdBannerDialogState extends State<_AdBannerDialog> {
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();

    _secondsLeft = widget.duration.inSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft <= 1) {
        timer.cancel();
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _secondsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundGradient1,
          title: Text(context.l.closeBanner, style: AppFonts.body1medium.white),
          content: Text(context.l.closeBannerDescr,
              style: AppFonts.body2medium.white),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    disabledBackgroundColor: AppColors.black,
                    backgroundColor: AppColors.backgroundGradient1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(
                          color: AppColors.yellow, width: 1),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    context.l.toStay,
                    style: AppFonts.body2bold.yellow,
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.additionalGreen,
                      backgroundColor: AppColors.mainGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      context.l.close,
                      style: AppFonts.body2bold.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
                '${context.l.adsDisableOffer}${widget.price} ${context.l.adsDisableLater}',
                style: AppFonts.body2medium.white),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Stack(
                      children: [
                        bStyle(
                          text:
                              "${context.l.disableBanner} (${widget.price})",
                          c: context,
                          colorText: AppColors.white,
                          vertical: 15,
                          onPressed: () async {
  await widget.onDisableAds?.call();
},
                        ),
                        Positioned(
                          left: -7,
                          top: -8,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(Assets.newBadge),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )
                      ],
                    ))),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _closePressed() async {
    if (_secondsLeft <= 0) {
      Navigator.pop(context, true);
      return;
    }

    final close = await _showExitDialog();

    if (close && mounted) {
      Navigator.pop(context, false);
    }
  }

  Future<void> _call() async {
    final phone = widget.phone;

    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Future.microtask(() async {
          await _closePressed();
        });
      },
      child: Material(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 60,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildTopBar(),
                    ),
                  ],
                ),
              ),
              if (widget.phone?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mainGreen,
                      ),
                      onPressed: _call,
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label:
                          Text(context.l.call, style: AppFonts.body1bold.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer,
                  size: 16,
                  color: AppColors.darkGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '${context.l.forEnd} $_secondsLeft ${context.l.secondsShort}',
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withOpacity(0.8),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: _closePressed,
            ),
          ),
        ],
      ),
    );
  }
}
