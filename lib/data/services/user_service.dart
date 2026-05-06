import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class UserService {
  UserService._();

  // ── Google Sign-In instance ────────────────────────────────
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ── GET: Detail User ───────────────────────────────────────
  static Future<User?> fetchUser(int id) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.userDetail(id)),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) return User.fromJson(data['data']);
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal mengambil data user.', statusCode: 500);
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
          'nama' : nama,
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
      throw ApiException(message: 'Gagal memperbarui data user.', statusCode: 500);
    }
  }

  // ── POST: Register ─────────────────────────────────────────
  // MODIFIKASI: sekarang backend hanya menyimpan ke cache & kirim OTP,
  // belum simpan ke DB. Response sukses berarti OTP sudah dikirim.
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
          'nama'    : nama,
          'email'   : email,
          'no_hp'   : noHp,
          'password': password,
          'role'    : 'penyewa',
          if (alamat != null && alamat.isNotEmpty) 'alamat': alamat,
        }),
      );
      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Registrasi gagal. Coba lagi nanti.', statusCode: 500);
    }
  }

  // ── POST: Verifikasi Email Registrasi (BARU) ───────────────
  // Dipanggil setelah user input OTP yang dikirim ke email.
  // Jika OTP valid → backend baru simpan user ke DB.
  static Future<Map<String, dynamic>> verifikasiEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifikasiEmail),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Verifikasi email gagal. Coba lagi.', statusCode: 500);
    }
  }

  // ── POST: Login biasa ──────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = ApiHelper.handleResponse(response);
      if (data['error'] == false && data['user'] != null) {
        await ApiHelper.saveSession(
          userId: data['user']['id_user'],
          role  : data['user']['role'],
          token : data['token'] ?? '',
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login gagal. Coba lagi nanti.', statusCode: 500);
    }
  }

  // ── POST: Google Login (BARU) ──────────────────────────────
  // Flow:
  // 1. Trigger popup Google Sign-In di device
  // 2. Ambil idToken dari Google
  // 3. Kirim idToken ke Laravel untuk diverifikasi
  // 4. Laravel return Sanctum token jika valid
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Step 1 — Trigger Google Sign-In popup
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User menekan tombol back / cancel
        throw ApiException(message: 'Login Google dibatalkan.', statusCode: 0);
      }

      // Step 2 — Ambil idToken
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw ApiException(
            message: 'Gagal mendapatkan token Google. Coba lagi.',
            statusCode: 0);
      }

      // Step 3 — Kirim idToken ke Laravel
      final response = await http.post(
        Uri.parse(ApiConstants.googleLogin),
        headers: ApiHelper.publicHeaders,
        body: jsonEncode({'id_token': idToken}),
      );

      final data = ApiHelper.handleResponse(response);

      // Step 4 — Simpan session jika berhasil
      if (data['error'] == false && data['user'] != null) {
        await ApiHelper.saveSession(
          userId: data['user']['id_user'],
          role  : data['user']['role'],
          token : data['token'] ?? '',
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Login Google gagal. Coba lagi nanti.', statusCode: 500);
    }
  }

  // ── POST: Sign Out Google (BARU) ───────────────────────────
  // Dipanggil bersamaan saat logout biasa jika user login via Google.
  static Future<void> signOutGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Abaikan error sign out Google, tetap lanjut clear session
    }
  }

  // ── POST: Logout ───────────────────────────────────────────
  // MODIFIKASI: tambah signOutGoogle() agar Google session juga dibersihkan
  static Future<void> logout() async {
    try {
      final headers = await ApiHelper.authHeaders;
      await http.post(Uri.parse(ApiConstants.logout), headers: headers);
    } catch (_) {
      // Tetap clear session meskipun request gagal
    } finally {
      await signOutGoogle();          // ← baru: clear Google session
      await ApiHelper.clearSession(); // clear Sanctum token & prefs
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
          message: 'Gagal mengirim permintaan reset password.', statusCode: 500);
    }
  }

  // ── POST: Verifikasi OTP Lupa Password ────────────────────
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
      throw ApiException(message: 'Verifikasi OTP gagal.', statusCode: 500);
    }
  }
static Future<Map<String, dynamic>> resendOtpRegister({
  required String email,
}) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConstants.resendOtpRegister),
      headers: ApiHelper.publicHeaders,
      body: jsonEncode({'email': email}),
    );
    return ApiHelper.handleResponse(response);
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(message: 'Gagal mengirim ulang OTP.', statusCode: 500);
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
          'email'                : email,
          'password'             : password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      return ApiHelper.handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal mengganti password.', statusCode: 500);
    }
  }
}
