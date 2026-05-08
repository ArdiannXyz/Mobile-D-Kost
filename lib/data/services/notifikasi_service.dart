import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../data/helper/api_constants.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  // ── authToken diisi dari LoginController setelah login ────
  // Sama persis dengan pola NotifikasiApiService.authToken = token
  static String authToken = '';

  // ── Header standar dengan Sanctum token ──────────────────
  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── GET /api/notifikasi ───────────────────────────────────
  static Future<Map<String, dynamic>> getNotifikasi() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.notifikasiList),
        headers: _headers,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List data = body['data'] ?? [];
        return {
          'error'             : false,
          'data'              : data.map((e) => NotifikasiModel.fromJson(e)).toList(),
          'jumlah_belum_baca' : body['jumlah_belum_baca'] ?? 0,
        };
      }

      return {'error': true, 'message': body['message'] ?? 'Gagal memuat notifikasi'};
    } catch (e) {
      debugPrint('NotifikasiService.getNotifikasi error: $e');
      return {'error': true, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // ── POST /api/notifikasi/{id}/baca ────────────────────────
  static Future<bool> tandaiBaca(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.notifikasiBaca(id)),
        headers: _headers,
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
      final response = await http.post(
        Uri.parse(ApiConstants.notifikasiBacaSemua),
        headers: _headers,
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
      final response = await http.post(
        Uri.parse(ApiConstants.oneSignalPlayerId),
        headers: _headers,
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