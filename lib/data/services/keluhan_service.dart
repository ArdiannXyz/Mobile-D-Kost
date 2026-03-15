// ============================================================
// BACKEND LAYER — keluhan_service.dart
// Sesuai ERD tabel `keluhan` D'Kost.
// ============================================================

import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/keluhan_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class KeluhanService {
  KeluhanService._();

  // ── GET: Daftar keluhan by user ────────────────────────────
  static Future<List<KeluhanModel>> getKeluhanList(int userId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.keluhanList(userId)),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        final List list = data['data'];
        return list.map((e) => KeluhanModel.fromJson(e)).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
          message: 'Gagal memuat daftar keluhan.', statusCode: 500);
    }
  }

  // ── POST: Buat keluhan baru (dengan upload foto) ───────────
  static Future<bool> createKeluhan({
    required int idKamar,
    required String deskripsiMasalah,
    File? fotoBukti,
  }) async {
    try {
      final userId = await ApiHelper.getUserId();
      final token = await ApiHelper.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.keluhanCreate),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['id_user']           = userId.toString();
      request.fields['id_kamar']          = idKamar.toString();
      request.fields['deskripsi_masalah'] = deskripsiMasalah;

      if (fotoBukti != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_bukti',
          fotoBukti.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = ApiHelper.handleResponse(response);
      return data['success'] == true;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
          message: 'Gagal mengirim keluhan.', statusCode: 500);
    }
  }
}