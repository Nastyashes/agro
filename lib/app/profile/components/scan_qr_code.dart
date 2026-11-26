import 'package:agro/data/repositories/auth_repository.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  /// The scanner reports the same code several times; handle it once.
  bool _handled = false;

  /// Owned here so the camera is started once and stopped on dispose; the
  /// widget's own controller restarted after the permission prompt and
  /// showed "already running" (BUG-038).
  final MobileScannerController _scanner = MobileScannerController();

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  /// Closes the scanner (back to home) and shows [message] there.
  void _closeWith(String message) {
    if (!mounted) return;
    Navigator.of(context).pop();
    notification(text: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg0,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(child: AppTopBar(title: context.l.scanQrCode)),
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
                controller: _scanner,
                scanWindow: scanRect,
                errorBuilder: (context, error) => _ScannerError(error),
                onDetect: (BarcodeCapture capture) async {
                  if (_handled) return;
                  _handled = true;
                  final List<Barcode> barcodes = capture.barcodes;

                  if (barcodes.isEmpty) {
                    _closeWith(context.l.qrNotValidForLogin);
                    return;
                  }

                  final Barcode barcode = barcodes.first;
                  final String? code = barcode.rawValue;

                  if (code == null) {
                    _closeWith(context.l.failedScan);
                  } else {
                    bool success;
                    try {
                      success = await AuthRepository().loginWithQr(code);
                    } on ApiException {
                      success = false;
                    }

                    if (!context.mounted) return;
                    if (success) {
                      _closeWith(context.l.loginSuccess);
                    } else {
                      await showDialog(
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
                      _handled = false; // let the user scan again
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
      Paint()..color = Palette.scrim,
    );

    const cornerLength = 28.0;
    final cornerPaint = Paint()
      ..color = Palette.green
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

/// Localized camera error with a way to Settings when access was denied
/// (BUG-034).
class _ScannerError extends StatelessWidget {
  const _ScannerError(this.error);

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Palette.bg0,
      child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            EmptyState(
              icon: Icons.no_photography_outlined,
              title:
                  denied ? context.l.cameraDenied : context.l.cameraUnavailable,
              text: denied ? context.l.cameraDeniedHint : null,
            ),
            if (denied)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AppButton(
                  label: context.l.openSettings,
                  onPressed: openAppSettings,
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
