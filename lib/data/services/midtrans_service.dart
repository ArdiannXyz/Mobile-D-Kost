import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/api_constants.dart';

/// [LEGACY] MidtransService
/// Service ini sudah digantikan oleh PaymentService (payment_service.dart).
/// Dipertahankan untuk backward-compatibility jika ada pemanggilan `setToken()`
/// dari login flow yang belum dimigrasi.
class MidtransService {
  // ── Gunakan ApiConstants.baseUrl agar konsisten dengan service lain ─
  // (URL ngrok lama sudah dihapus, jangan hardcode URL di sini)
  static String get _baseUrl => ApiConstants.baseUrl.replaceAll('/api/', '');

  static String? _authToken;

  static void setToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      };

  // Request snap token untuk tagihan tertentu
  static Future<Map<String, dynamic>> createSnapToken(int idTagihan) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/create-token'),
        headers: _headers,
        body: jsonEncode({'id_tagihan': idTagihan}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
