// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // ══════════════════════════════════════════════════════════════
// // MODEL — sesuaikan dengan respons API Laravel
// // ══════════════════════════════════════════════════════════════
// class NotifikasiItem {
//   final int id;
//   final String judul;
//   final String pesan;
//   final NotifikasiTipe tipe;
//   bool sudahDibaca;
//   final DateTime waktu;

//   NotifikasiItem({
//     required this.id,
//     required this.judul,
//     required this.pesan,
//     required this.tipe,
//     required this.sudahDibaca,
//     required this.waktu,
//   });

//   factory NotifikasiItem.fromJson(Map<String, dynamic> json) {
//     return NotifikasiItem(
//       id: json['id'],
//       judul: json['judul'],
//       pesan: json['pesan'],
//       tipe: NotifikasiTipe.values.firstWhere(
//         (e) => e.name == json['tipe'],
//         orElse: () => NotifikasiTipe.umum,
//       ),
//       sudahDibaca: json['sudah_dibaca'] == true,
//       waktu: DateTime.parse(json['created_at']),
//     );
//   }
// }

// enum NotifikasiTipe { tagihan, keluhan, umum }

// // ══════════════════════════════════════════════════════════════
// // API SERVICE
// // ══════════════════════════════════════════════════════════════
// class NotifikasiApiService {
//   // ⚠️ Ganti dengan base URL API kamu
//   //static const String _baseUrl = 'https://api.domainmu.com/api';  //kalau mau pakai domain
//   static const String _baseUrl = 'http://10.73.161.109:8000/api';

//   // Simpan token auth user (isi setelah login)
//   static String? authToken;

//   Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         if (authToken != null) 'Authorization': 'Bearer $authToken',
//       };

//   // ── Ambil semua notifikasi dari server ────────────────────
//   Future<Map<String, dynamic>> ambilNotifikasi() async {
//     final res = await http.get(
//       Uri.parse('$_baseUrl/notifikasi'),
//       headers: _headers,
//     );

//     if (res.statusCode == 200) {
//       final body = jsonDecode(res.body);
//       final items = (body['data'] as List)
//           .map((e) => NotifikasiItem.fromJson(e))
//           .toList();
//       return {
//         'items': items,
//         'jumlah_belum_baca': body['jumlah_belum_baca'] ?? 0,
//       };
//     }
//     throw Exception('Gagal ambil notifikasi: ${res.statusCode}');
//   }

//   // ── Tandai 1 notifikasi sudah dibaca ─────────────────────
//   Future<void> tandaiBaca(int notifId) async {
//     await http.post(
//       Uri.parse('$_baseUrl/notifikasi/$notifId/baca'),
//       headers: _headers,
//     );
//   }

//   // ── Tandai semua sudah dibaca ─────────────────────────────
//   Future<void> tandaiSemuaBaca() async {
//     await http.post(
//       Uri.parse('$_baseUrl/notifikasi/baca-semua'),
//       headers: _headers,
//     );
//   }

//   // // ── Kirim FCM token ke server ─────────────────────────────
//   // Future<void> simpanFcmToken(String fcmToken) async {
//   //   await http.post(
//   //     Uri.parse('$_baseUrl/fcm-token'),
//   //     headers: _headers,
//   //     body: jsonEncode({'fcm_token': fcmToken}),
//   //   );
//   // }

//   Future<void> simpanFcmToken(String fcmToken) async {
//   debugPrint('Menyimpan FCM token ke server...');
//   debugPrint('Auth token: $authToken');
//   debugPrint('FCM token: $fcmToken');

//   final res = await http.post(
//     Uri.parse('$_baseUrl/fcm-token'),
//     headers: _headers,
//     body: jsonEncode({'fcm_token': fcmToken}),
//   );

//   debugPrint('Response simpan FCM: ${res.statusCode}');
//   debugPrint('Response body: ${res.body}');
//   }
// }

// // ══════════════════════════════════════════════════════════════
// // FCM SETUP — panggil initFcm() setelah user login
// // ══════════════════════════════════════════════════════════════
// class FcmSetup {
//   static final _api = NotifikasiApiService();

//   /// Panggil ini tepat setelah user berhasil login
//   static Future<void> initFcm() async {
//     final messaging = FirebaseMessaging.instance;

//     // 1. Minta izin notifikasi (iOS wajib, Android 13+ wajib)
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // 2. Ambil FCM token dan kirim ke server
//     final token = await messaging.getToken();
//     debugPrint('FCM TOKEN: $token');
//     if (token != null) {
//       await _api.simpanFcmToken(token);
//     }

//     // 3. Pantau jika token berubah (refresh)
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       _api.simpanFcmToken(newToken);
//     });

//     // 4. Handle notif saat app di FOREGROUND
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // Tampilkan snackbar / dialog manual karena FCM tidak auto-show saat foreground
//       debugPrint('Notif foreground: ${message.notification?.title}');
//       // Kamu bisa pakai flutter_local_notifications untuk tampilkan popup
//     });

//     // 5. Handle klik notif saat app di BACKGROUND (tap dari notification tray)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       final tipe = message.data['tipe'];
//       debugPrint('User tap notif: $tipe');
//       // Navigasi berdasarkan tipe — lihat contoh di bawah
//     });
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notifikasi_model.dart';
import '../helper/api_constants.dart';

class NotifikasiApiService {
  static String? authToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>> ambilNotifikasi() async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}notifikasi'),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final items = (body['data'] as List)
          .map((e) => NotifikasiItem.fromJson(e))
          .toList();

      return {
        'items': items,
        'jumlah_belum_baca': body['jumlah_belum_baca'] ?? 0,
      };
    }

    throw Exception('Gagal ambil notifikasi: ${res.statusCode}');
  }

  Future<void> tandaiBaca(int notifId) async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}notifikasi/$notifId/baca'),
      headers: _headers,
    );
  }

  Future<void> tandaiSemuaBaca() async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}notifikasi/baca-semua'),
      headers: _headers,
    );
  }

  Future<void> simpanFcmToken(String fcmToken) async {
    debugPrint('=== SIMPAN FCM ===');
    debugPrint('Auth token: $authToken');
    debugPrint('Headers: $_headers');

    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}fcm-token'),
      headers: _headers,
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    debugPrint('Response: ${res.statusCode}');
    debugPrint('Body: ${res.body}');
  }
}

// // ══════════════════════════════════════════════════════════════
// // FCM SETUP
// // ══════════════════════════════════════════════════════════════
// class FcmSetup {
//   static final _api = NotifikasiApiService();

//   static Future<void> initFcm() async {
//     final messaging = FirebaseMessaging.instance;

//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     final token = await messaging.getToken();
//     debugPrint('FCM TOKEN: $token');
//     if (token != null) {
//       await _api.simpanFcmToken(token);
//     }

//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       _api.simpanFcmToken(newToken);
//     });

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('Notif foreground: ${message.notification?.title}');
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       final tipe = message.data['tipe'];
//       debugPrint('User tap notif: $tipe');
//     });
//   }
// }