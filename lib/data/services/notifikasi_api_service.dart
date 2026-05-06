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
        'X-Requested-With': 'XMLHttpRequest',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>> ambilNotifikasi() async {
    debugPrint('NOTIF AUTH TOKEN: $authToken');
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

    // ========== DITAMBAH: registrasi OneSignal player ID ke backend ==========
  Future<void> daftarkanOneSignalPlayerId(String playerId) async {
  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}onesignal/login'),
    headers: _headers,
    body: jsonEncode({'onesignal_player_id': playerId}),
  );
  if (response.statusCode != 200) {
    throw Exception('Gagal daftar OneSignal: ${response.statusCode}');
  }
  debugPrint('✅ OneSignal player ID terdaftar di backend');
  }

  Future<void> simpanFcmToken(String fcmToken) async {
    debugPrint('=== SIMPAN FCM ===');
    debugPrint('Auth token: $authToken'); // ← apakah null di sini?
    debugPrint('FCM token: $fcmToken'); // ← apakah null di sini?
    debugPrint('Headers: $_headers');
    debugPrint('URL: ${ApiConstants.baseUrl}fcm-token');

    if (authToken == null) {
      debugPrint('❌ authToken NULL! FCM tidak dikirim.');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}fcm-token'),
        headers: _headers,
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      debugPrint('Response: ${res.statusCode}');
      debugPrint('Body: ${res.body}');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }
}
