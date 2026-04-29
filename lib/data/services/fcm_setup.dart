import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notifikasi_api_service.dart';

class FcmSetup {
  static final _api = NotifikasiApiService();

  static Future<void> initFcm() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    debugPrint('FCM TOKEN: $token');

    if (token != null) {
      await _api.simpanFcmToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _api.simpanFcmToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notif foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tap notif');
    });
  }
}