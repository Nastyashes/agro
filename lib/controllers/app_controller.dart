import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:agro/data/repositories/account_repository.dart';
import 'package:agro/routes/app_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> backgroundNotificationHandler(RemoteMessage message) async {
  log("Push in background: ${message.data.toString()}");
}

/// Owns push-notification setup (FCM + local notifications).
class AppController extends GetxController {
  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  /// AppController is permanent, but initPage runs every time the home screen
  /// opens (e.g. after logout + login). Listeners must be attached only once.
  bool _pushListenersAttached = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initPage() async {
    if (kIsWeb) return;

    try {
      if (_pushListenersAttached) {
        // Re-bind the device token to the (possibly new) logged-in user.
        await registerFCMToken();
      } else {
        _pushListenersAttached = true;
        await _setupPushNotifications();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _setupPushNotifications() async {
    _setupFCMToken();

    /// Triggers when App is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      if (!Platform.isIOS) {
        log("notification $message");
        _display(message);
      }
    });

    /// App is in background but opened and user taps on the notification
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _handleTapOnPushNotification(message));

    /// Get notification info when its delivered in background
    FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);

    await _initializeLocalNotifications();

    // Cold start from a tapped push: open its bid once (BUG-013).
    final initial = await _firebaseMessaging.getInitialMessage();
    if (initial != null) await openBidFromPushData(initial.data);
  }

  _handleTapOnPushNotification(RemoteMessage? remoteMessage) async {
    await openBidFromPushData(remoteMessage?.data);
  }

  _display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      log("NOTIFICATION ${message.data}");
      await _notificationsPlugin.show(id, message.notification?.title,
          message.notification?.body, _getNotificationDetails(),
          payload: jsonEncode(message.data));
    } catch (e) {
      log("display notification: ${e.toString()}");
    }
  }

  NotificationDetails _getNotificationDetails() {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'muzos_android_notification_channel', 'Main channel',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  _initializeLocalNotifications() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    );

    _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
      if (response.payload != null) {
        log("DidReceiveNotificationResponse: ${response.payload}");
        try {
          final data = jsonDecode(response.payload!);
          await openBidFromPushData(data);
        } catch (e) {
          log("handle tap error $e");
        }
      }
    });

    AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'muzos_android_notification_channel', 'Main channel',
        importance: Importance.max, playSound: true, enableVibration: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    log("Did Receive Local Notification");
  }

  Future<void> _setupFCMToken() async {
    await _registerSafely();
    _firebaseMessaging.onTokenRefresh.listen((token) {
      // Fired at each app start and whenever a new token is generated
      // (on iOS also once the APNS token arrives).
      log("FCM token refreshed");
      _registerSafely();
    }).onError((err) {
      log(err.toString());
    });
  }

  /// Push setup must never crash the app: offline start, no APNS yet
  /// (BUG-027, BUG-037) are logged and retried on the next token refresh.
  Future<void> _registerSafely() async {
    try {
      await registerFCMToken();
    } catch (e) {
      log('registerFCMToken failed: $e');
    }
  }

  /// Asks for the notification permission first (so iOS shows the system
  /// prompt even before the APNS token exists), then sends the FCM token.
  Future registerFCMToken() async {
    if (kIsWeb) {
      return;
    }

    await askForPermissionIfNeeded();

    if (Platform.isIOS && await _firebaseMessaging.getAPNSToken() == null) {
      log('APNS token not set yet; will register on token refresh');
      return;
    }

    final token = await _firebaseMessaging.getToken();
    if (token == null) return;

    await AccountRepository().registerDeviceToken(token);
    log("FCM token registered");
  }

  Future askForPermissionIfNeeded() async {
    if (await needToRequestPermission()) {
      await askForPermission();
    }
  }

  /// Shows the system prompt only while it can still be shown. A user who
  /// said no is not sent to Settings on every launch.
  Future askForPermission() async {
    final status = await Permission.notification.status;
    if (status == PermissionStatus.denied) {
      await Permission.notification.request();
    }
  }

  Future<bool> needToRequestPermission() async {
    final status = await Permission.notification.status;

    return !status.isGranted;
  }

  Future<void> openBidFromPushData(dynamic data) async {
    final orderId = bidIdFromPush(data);
    if (orderId == null) return;
    await Get.toNamed(Routes.bidItemScreen, arguments: {'orderId': orderId});
  }
}

/// The bid a push opens: a Match (`uagro_message_type`, previously
/// `message_type`) or a legacy TENDER push with a `tender_id` (BUG-022).
int? bidIdFromPush(dynamic data) {
  if (data is! Map) return null;
  final type = (data['uagro_message_type'] ?? data['message_type'])?.toString();
  final legacy = data['messagetype']?.toString();
  if (type != 'MATCH' && legacy != 'TENDER') return null;
  return int.tryParse('${data['tender_id'] ?? ''}');
}
