import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  // ── Header diambil dari ApiHelper (SharedPreferences) ───
  // Tidak perlu static authToken lagi — token selalu sinkron
  // dengan sesi yang aktif dan otomatis ter-reset saat logout.
  static Future<Map<String, String>> get _headers => ApiHelper.authHeaders;

  // ── GET /api/notifikasi ───────────────────────────────────
  static Future<Map<String, dynamic>> getNotifikasi() async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse(ApiConstants.notifikasiList),
        headers: headers,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List data = body['data'] ?? [];
        return {
          'error': false,
          'data': data.map((e) => NotifikasiModel.fromJson(e)).toList(),
          'jumlah_belum_baca': body['jumlah_belum_baca'] ?? 0,
        };
      }

      return {
        'error': true,
        'message': body['message'] ?? 'Gagal memuat notifikasi'
      };
    } catch (e) {
      debugPrint('NotifikasiService.getNotifikasi error: $e');
      return {'error': true, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // ── POST /api/notifikasi/{id}/baca ────────────────────────
  static Future<bool> tandaiBaca(int id) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse(ApiConstants.notifikasiBaca(id)),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('NotifikasiService.tandaiBaca error: $e');
      return false;
    }
  }

  // ── POST /api/notifikasi/baca-semua ──────────────────────
  static Future<bool> tandaiSemuaBaca() async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse(ApiConstants.notifikasiBacaSemua),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('NotifikasiService.tandaiSemuaBaca error: $e');
      return false;
    }
  }

  // ── POST /api/onesignal-player-id ─────────────────────────
  static Future<bool> simpanPlayerId(String playerId) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse(ApiConstants.oneSignalPlayerId),
        headers: headers,
        body: jsonEncode({'player_id': playerId}),
      );
      debugPrint('simpanPlayerId status: ${response.statusCode}');
      debugPrint('simpanPlayerId body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('NotifikasiService.simpanPlayerId error: $e');
      return false;
    }
  }
}
