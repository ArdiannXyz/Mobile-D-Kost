import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class PembayaranService {
  PembayaranService._();

  // POST: Buat pembayaran + ambil snap token
  static Future<Map<String, dynamic>> createPembayaran(int idTagihan) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.post(
        Uri.parse(ApiConstants.pembayaranCreate),
        headers: headers,
        body: jsonEncode({'id_tagihan': idTagihan}),
      );
      return ApiHelper.handleResponse(response);
    } on ApiException { rethrow; }
    catch (_) {
      throw ApiException(message: 'Gagal membuat pembayaran.', statusCode: 500);
    }
  }

  // GET: Cek status pembayaran
  static Future<Map<String, dynamic>> checkStatus(int idTagihan) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.pembayaranStatus(idTagihan)),
        headers: headers,
      );
      return ApiHelper.handleResponse(response);
    } on ApiException { rethrow; }
    catch (_) {
      throw ApiException(message: 'Gagal cek status.', statusCode: 500);
    }
  }
}