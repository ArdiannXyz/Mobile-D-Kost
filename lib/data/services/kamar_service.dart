// ============================================================
// BACKEND LAYER — kamar_service.dart
// Semua HTTP request terkait kamar.
// ============================================================

import 'package:http/http.dart' as http;
import '../models/kamar_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';
import 'cache_service.dart';

class KamarService {
  KamarService._();

  // ── GET: List semua kamar ──────────────────────────────────
  // forceRefresh: true → abaikan cache, ambil dari API
  static Future<List<KamarModel>> getKamarList({bool forceRefresh = false}) async {
    const cacheKey = CacheService.keyKamarList;

    // Cek cache dulu (skip jika forceRefresh)
    if (!forceRefresh) {
      final cached = CacheService.get<List<KamarModel>>(cacheKey);
      if (cached != null) return cached;
    }

    // Cache miss / expired / forceRefresh → fetch dari API
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.kamarList),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        final List list = data['data'];
        final result = list.map((e) => KamarModel.fromJson(e)).toList();

        // Simpan ke cache dengan TTL 5 menit
        CacheService.set(cacheKey, result, ttl: CacheService.ttlKamar);
        return result;
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal memuat daftar kamar.', statusCode: 500);
    }
  }

  // ── GET: Detail kamar ──────────────────────────────────────
  static Future<KamarModel?> getKamarDetail(int id, {bool forceRefresh = false}) async {
    final cacheKey = 'kamar_detail_$id';

    if (!forceRefresh) {
      final cached = CacheService.get<KamarModel>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.kamarDetail(id)),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        final result = KamarModel.fromJson(data['data']);

        // Cache detail kamar 5 menit
        CacheService.set(cacheKey, result, ttl: CacheService.ttlKamar);
        return result;
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal memuat detail kamar.', statusCode: 500);
    }
  }
}