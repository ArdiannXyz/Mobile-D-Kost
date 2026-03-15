// ============================================================
// BACKEND LAYER — furnitur_service.dart
// ============================================================

import 'package:dkost/data/helper/api_constants.dart';
import 'package:http/http.dart' as http;
import '../models/furnitur_models.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class FurniturService {
  FurniturService._();

  static Future<List<FurniturModel>> getFurniturList() async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}furnitur'),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        final List list = data['data'];
        return list.map((e) => FurniturModel.fromJson(e)).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gagal memuat daftar furnitur.', statusCode: 500);
    }
  }
}