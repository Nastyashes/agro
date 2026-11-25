import 'package:agro/ui/components/app_snackbar.dart';
import 'package:flutter/widgets.dart';

/// Short message at the bottom of the screen. [c] and [size] are kept for
/// old call sites; the look comes from [AppSnack].
void inAppNotification(
        {required String text,
        required BuildContext c,
        double? size,
        int? seconds,
        SnackType type = SnackType.info}) =>
    showAppSnackbar(text,
        type: type,
        duration: seconds == null ? null : Duration(seconds: seconds));

void notification({required String text, SnackType type = SnackType.info}) =>
    showAppSnackbar(text, type: type);
