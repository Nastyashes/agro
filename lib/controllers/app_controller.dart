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

  Future _setupFCMToken() async {
    await registerFCMToken();
    _firebaseMessaging.onTokenRefresh.listen((token) {
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
      log("FCM token refreshed");
      registerFCMToken();
    }).onError((err) {
      log(err.toString());
    });
  }

  /// Pass specific token or null to try getting it from Firebase
  Future registerFCMToken() async {
    if (kIsWeb) {
      return;
    }

    final token = await _firebaseMessaging.getToken();
    if (token == null) {
      throw Exception("Couldn't get FCM token");
    }

    await AccountRepository().registerDeviceToken(token);

    log("FCM token registered");
    askForPermissionIfNeeded();
  }

  Future askForPermissionIfNeeded() async {
    if (await needToRequestPermission()) {
      askForPermission();
    }
  }

  Future askForPermission() async {
    final status = await Permission.notification.status;

    switch (status) {
      case PermissionStatus.denied:
        await Permission.notification.request();
        break;
      case PermissionStatus.granted:
        return;
      case PermissionStatus.restricted:
        openAppSettings();
        break;
      case PermissionStatus.limited:
        openAppSettings();
        break;
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
        break;
      case PermissionStatus.provisional:
        openAppSettings();
        break;
    }
  }

  Future<bool> needToRequestPermission() async {
    final status = await Permission.notification.status;

    return !status.isGranted;
  }

  Future<void> openBidFromPushData(dynamic data) async {
    if (data is! Map) return;
    final messageType = data['message_type']?.toString();
    final legacyType = data['messagetype']?.toString();
    if (messageType != 'MATCH' && legacyType != 'TENDER') return;
    final orderId = int.tryParse('${data['tender_id'] ?? ''}');
    if (orderId == null) return;
    await Get.toNamed(Routes.bidItemScreen, arguments: {'orderId': orderId});
  }
}
