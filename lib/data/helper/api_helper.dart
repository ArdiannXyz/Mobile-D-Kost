// ============================================================
// api_helper.dart
// Helper terpusat untuk headers, response handler, session.
// ApiException dipindah ke api_exception.dart
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exception.dart';

class ApiHelper {
  ApiHelper._();

  // ── SharedPreferences Keys ─────────────────────────────────
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId     = 'user_id';
  static const String _keyToken      = 'token';
  static const String _keyRole       = 'role';

  // ── Headers ────────────────────────────────────────────────
  static Map<String, String> get publicHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> get authHeaders async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Response Handler ───────────────────────────────────────
  static Map<String, dynamic> handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['message'] ?? 'Terjadi kesalahan server.';
    throw ApiException(message: message, statusCode: response.statusCode);
  }

  // ── Session Management ─────────────────────────────────────
  static Future<void> saveSession({
    required int userId,
    required String role,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyToken, token);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyToken);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }
}