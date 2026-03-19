// ============================================================
// BACKEND LAYER — kamar_service.dart
// Semua HTTP request terkait kamar.
// ============================================================

import 'package:http/http.dart' as http;
import '../models/kamar_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class KamarService {
  KamarService._();

  // ── GET: List semua kamar ──────────────────────────────────
   static Future<List<KamarModel>> getKamarList() async {
  try {
    final headers = await ApiHelper.authHeaders;
    print('KAMAR HEADERS: $headers');
    final response = await http.get(
      Uri.parse(ApiConstants.kamarList),
      headers: headers,
    );
    print('KAMAR STATUS: ${response.statusCode}');
    print('KAMAR BODY: ${response.body}');
    final data = ApiHelper.handleResponse(response);
    if (data['success'] == true) {
      final List list = data['data'];
      return list.map((e) => KamarModel.fromJson(e)).toList();
    }
    return [];
  } on ApiException {
    rethrow;
  } catch (e) {
    print('KAMAR ERROR: $e');
    throw ApiException(message: 'Gagal memuat daftar kamar.', statusCode: 500);
  }
}

  // ── GET: Detail kamar ──────────────────────────────────────
  static Future<KamarModel?> getKamarDetail(int id) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.kamarDetail(id)),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        return KamarModel.fromJson(data['data']);
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal memuat detail kamar.', statusCode: 500);
    }
  }
}