import 'package:agro/generated/assets.dart';
import 'package:agro/server/api/controller/traider.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
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
        title: Text(
          context.l.scanQrCode,
          style: AppFonts.title2.white,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanRect = _qrScanRect(
            Size(constraints.maxWidth, constraints.maxHeight),
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                scanWindow: scanRect,
                onDetect: (BarcodeCapture capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  debugPrint('Barcodes detected: ${barcodes.length}');

                  if (barcodes.isEmpty) {
                    debugPrint('Failed to scan: No barcodes found');
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/profile');
                      inAppNotification(
                        text: context.l.qrNotValidForLogin,
                        c: context,
                      );
                    }
                    return;
                  }

                  final Barcode barcode = barcodes.first;
                  final String? code = barcode.rawValue;

                  if (code == null) {
                    debugPrint('Failed to scan: Barcode rawValue is null');
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/profile');
                      inAppNotification(
                        text: context.l.failedScan,
                        c: context,
                      );
                    }
                  } else {
                    debugPrint('Code found: $code');
                    final apiAnswer = await traider.loginWithQr(code);
                    debugPrint('API Answer: ${apiAnswer.toString()}');

                    if (apiAnswer.code == 200) {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/profile');
                        inAppNotification(
                          text: context.l.loginSuccess,
                          c: context,
                        );
                      }
                    } else if (context.mounted) {
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
                },
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: _QrScannerOverlayPainter(scanRect: scanRect),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Rect _qrScanRect(Size size) {
  final side = (size.shortestSide * 0.72).clamp(220.0, 300.0);
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: side,
    height: side,
  );
}

class _QrScannerOverlayPainter extends CustomPainter {
  const _QrScannerOverlayPainter({required this.scanRect});

  final Rect scanRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)));

    canvas.drawPath(
      overlay,
      Paint()..color = AppColors.black.withValues(alpha: 0.55),
    );

    const cornerLength = 28.0;
    final cornerPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawCorner(Offset origin, Offset alongX, Offset alongY) {
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx + alongX.dx, origin.dy + alongX.dy)
          ..lineTo(origin.dx, origin.dy)
          ..lineTo(origin.dx + alongY.dx, origin.dy + alongY.dy),
        cornerPaint,
      );
    }

    drawCorner(
      scanRect.topLeft,
      const Offset(0, cornerLength),
      const Offset(cornerLength, 0),
    );
    drawCorner(
      scanRect.topRight,
      const Offset(0, cornerLength),
      const Offset(-cornerLength, 0),
    );
    drawCorner(
      scanRect.bottomLeft,
      const Offset(0, -cornerLength),
      const Offset(cornerLength, 0),
    );
    drawCorner(
      scanRect.bottomRight,
      const Offset(0, -cornerLength),
      const Offset(-cornerLength, 0),
    );
  }

  @override
  bool shouldRepaint(covariant _QrScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanRect != scanRect;
  }
}
