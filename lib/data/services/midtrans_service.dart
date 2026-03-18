import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {

  // ── Base URL ───────────────────────────────────────────────
  // Pilih salah satu, comment sisanya:

  //static const String baseUrl = 'http://127.0.0.1:8000/api';        // Browser
  //static const String baseUrl = 'http://10.0.2.2:8000/api';      // Emulator Android
  // static const String baseUrl = 'http://192.168.x.x:8000/api';   // HP Fisik
  static const String baseUrl = 'https://bacteriophagic-marcelle-semiconical.ngrok-free.dev/api'; // Ngrok

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
        Uri.parse('$baseUrl/payment/create-token'),
        headers: _headers,
        body: jsonEncode({'id_tagihan': idTagihan}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}