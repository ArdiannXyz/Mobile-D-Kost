// ============================================================
// api_constants.dart
// Semua URL dan endpoint API terpusat di sini.
// Ganti baseUrl sesuai environment (local / production).
// ============================================================

class ApiConstants {
  ApiConstants._(); // Prevent instantiation

  // ── Base URL ───────────────────────────────────────────────
  // Ganti ke IP lokal saat testing di device fisik
  // Ganti ke domain production saat deploy
// lib/data/helper/api_constants.dart
static const String baseUrl = 'http://127.0.0.1:8000/api/';
  // static const String baseUrl = 'https://dkost.example.com/api/';

  // ── Auth Endpoints ─────────────────────────────────────────
  static const String register   = '${baseUrl}register';
  static const String login      = '${baseUrl}login';
  static const String logout     = '${baseUrl}logout';
  static const String lupaPassword  = '${baseUrl}lupa-password';
  static const String cekOtp     = '${baseUrl}cek-otp';
  static const String gantiPassword = '${baseUrl}ganti-password';

  // ── User Endpoints ─────────────────────────────────────────
  static String userDetail(int id) => '${baseUrl}user/$id';
  static String updateUser(int id)  => '${baseUrl}user/$id';

  // ── Kamar Endpoints ────────────────────────────────────────
  static const String kamarList   = '${baseUrl}kamar';
  static String kamarDetail(int id) => '${baseUrl}kamar/$id';

  // ── Booking Endpoints ──────────────────────────────────────
  static const String bookingCreate = '${baseUrl}booking';
  static String bookingList(int userId) => '${baseUrl}booking/user/$userId';
  static String bookingDetail(int id)   => '${baseUrl}booking/$id';

  // ── Tagihan Endpoints ──────────────────────────────────────
  static String tagihanList(int bookingId) => '${baseUrl}tagihan/booking/$bookingId';
  static String tagihanDetail(int id)       => '${baseUrl}tagihan/$id';

  // ── Pembayaran Endpoints ───────────────────────────────────
  static const String pembayaranCreate = '${baseUrl}pembayaran';
  static String pembayaranStatus(int idTagihan) => '${baseUrl}pembayaran/status/$idTagihan';

  // ── Keluhan Endpoints ──────────────────────────────────────
  static const String keluhanCreate = '${baseUrl}keluhan';
  static String keluhanList(int userId) => '${baseUrl}keluhan/user/$userId';

  // ── Review Endpoints ───────────────────────────────────────
  static const String reviewCreate = '${baseUrl}review';
  static String reviewList(int kamarId) => '${baseUrl}review/kamar/$kamarId';
  static String reviewUpdate(int id)    => '${baseUrl}review/$id';
}