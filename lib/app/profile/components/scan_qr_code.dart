import 'package:agro/generated/assets.dart';
import 'package:agro/server/api/controller/traider.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Traider traider = Traider();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.scanQrCode),
        leading: IconButton(
          icon: SvgPicture.asset(Assets.componentsBack, width: 24, height: 24),
          color: AppColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              debugPrint('Barcodes detected: ${barcodes.length}');

              if (barcodes.isEmpty) {
                debugPrint('Failed to scan: No barcodes found');
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/profile');
                  inAppNotification(text: context.l.qrNotValidForLogin, c: context);
                }
                return;
              }

              final Barcode barcode = barcodes.first;
              final String? code = barcode.rawValue;

              if (code == null) {
                debugPrint('Failed to scan: Barcode rawValue is null');
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/profile');
                  inAppNotification(text: context.l.failedScan, c: context);
                }
              } else {
                debugPrint('Code found: $code');
                final apiAnswer = await traider.loginWithQr(code);
                debugPrint('API Answer: ${apiAnswer.toString()}');


                if (apiAnswer.code == 200) {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/profile');
                    inAppNotification(text: context.l.loginSuccess, c: context);
                  }
                } else {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.l.error),
                        content: Text(context.l.loginFailed),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(context.l.ok),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
