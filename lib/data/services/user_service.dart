// ============================================================
// BACKEND LAYER — user_service.dart
// Bertanggung jawab atas: semua HTTP request terkait user.
// Menggunakan ApiHelper untuk headers & session management.
// Menggunakan ApiConstants untuk semua URL endpoint.
//
// Yang DIHAPUS dari versi lama:
// - toggleFavorite, getFavorites, fetchFavorites → tidak ada di ERD D'Kost
// - fetchadd_alamats → tidak relevan untuk kost
// - baseUrl hardcoded → pindah ke ApiConstants
// - print() debugging → diganti throw ApiException
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class UserService {
  UserService._();

  // ── GET: Detail User ───────────────────────────────────────
  static Future<User?> fetchUser(int id) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.userDetail(id)),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengambil data user.',
        statusCode: 500,
      );
    }
  }

  // ── PUT: Update Profil User ────────────────────────────────
  static Future<bool> updateUser({
    required int id,
    required String nama,
    required String email,
    required String noHp,
    String? alamat,
  }) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.put(
        Uri.parse(ApiConstants.updateUser(id)),
        headers: headers,
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'no_hp': noHp,
          if (alamat != null) 'alamat': alamat,
        }),
      );

      final data = ApiHelper.handleResponse(response);
      return data['success'] == true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Gagal memperbarui data user.',
        statusCode: 500,
      );
    }
  }

  // ── POST: Register ─────────────────────────────────────────
  static Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    String? alamat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'no_hp': noHp,
          'password': password,
          'role': 'penyewa',
          if (alamat != null && alamat.isNotEmpty) 'alamat': alamat,
        }),
      );

      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Registrasi gagal. Coba lagi nanti.',
        statusCode: 500,
      );
    }
  }

  // ── POST: Login ────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = ApiHelper.handleResponse(response);

      // Simpan session jika login berhasil
      if (data['error'] == false && data['user'] != null) {
        await ApiHelper.saveSession(
          userId: data['user']['id_user'],
          role: data['user']['role'],
          token: data['token'] ?? '',
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Login gagal. Coba lagi nanti.',
        statusCode: 500,
      );
    }
  }

  // ── POST: Logout ───────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final headers = await ApiHelper.authHeaders;
      await http.post(
        Uri.parse(ApiConstants.logout),
        headers: headers,
      );
    } catch (_) {
      // Tetap clear session meskipun request gagal
    } finally {
      await ApiHelper.clearSession();
    }
  }

  // ── POST: Lupa Password ────────────────────────────────────
  static Future<Map<String, dynamic>> lupaPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.lupaPassword),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({'email': email}),
      );

      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengirim permintaan reset password.',
        statusCode: 500,
      );
    }
  }

  // ── POST: Verifikasi OTP ───────────────────────────────────
  static Future<Map<String, dynamic>> cekOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.cekOtp),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Verifikasi OTP gagal.',
        statusCode: 500,
      );
    }
  }

  // ── POST: Ganti Password ───────────────────────────────────
  static Future<Map<String, dynamic>> gantiPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.gantiPassword),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Gagal mengganti password.',
        statusCode: 500,
      );
    }
  }
}