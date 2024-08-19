import 'package:agro/generated/assets.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.scanQrCode),
        leading: IconButton(
          icon: SvgPicture.asset(Assets.componentsBack,
                                    width: 24, height: 24), 
                                    color: AppColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              final Barcode barcode = barcodes.first;

              if (barcode.rawValue == null) {
                debugPrint(context.l.failedScan);
              } else {
                final String code = barcode.rawValue!;
                debugPrint('${context.l.codeFound} $code');

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.l.codeDetected),
                    content: Text('${context.l.result} $code'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l.yes),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
