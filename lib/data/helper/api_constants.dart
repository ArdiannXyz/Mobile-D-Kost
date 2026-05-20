import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // ── Base URL (auto-detect environment) ─────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://kitadkost.my.id/api/';
    } else if (Platform.isAndroid) {
      return 'https://kitadkost.my.id/api/'; // Emulator Android
    } else {
      return 'https://kitadkost.my.id/api/'; // Device fisik
    }
  }

  static String get storageUrl {
    if (kIsWeb) {
      return 'https://kitadkost.my.id/storage/';
    } else if (Platform.isAndroid) {
      return 'https://kitadkost.my.id/storage/';
    } else {
      return 'https://kitadkost.my.id/storage/';
    }
  }

  // ── Auth Endpoints ─────────────────────────────────────────
  static String get register => '${baseUrl}register';
  static String get login => '${baseUrl}login';
  static String get logout => '${baseUrl}logout';
  static String get lupaPassword => '${baseUrl}lupa-password';
  static String get cekOtp => '${baseUrl}cek-otp';
  static String get gantiPassword => '${baseUrl}ganti-password';
  static String get googleLogin => '${baseUrl}google-login';
  static String get verifikasiEmail => '${baseUrl}verifikasi-email';
  static String get resendOtpRegister => '${baseUrl}resend-otp-register';

  // ── User Endpoints ─────────────────────────────────────────
  static String userDetail(int id) => '${baseUrl}user/$id';
  static String updateUser(int id) => '${baseUrl}user/$id';

  // ── Kamar Endpoints ────────────────────────────────────────
  static String get kamarList => '${baseUrl}kamar';
  static String kamarDetail(int id) => '${baseUrl}kamar/$id';

  // ── Booking Endpoints ──────────────────────────────────────
  static String get bookingCreate => '${baseUrl}booking';
  static String bookingList(int userId) => '${baseUrl}booking/user/$userId';
  static String bookingDetail(int id) => '${baseUrl}booking/$id';
  static String bookingAktif(int userId) => '${baseUrl}booking/aktif/$userId';

  // ── Tagihan Endpoints ──────────────────────────────────────
  static String tagihanList(int bookingId) =>
      '${baseUrl}tagihan/booking/$bookingId';
  static String tagihanDetail(int id) => '${baseUrl}tagihan/$id';

  // ── Pembayaran Endpoints ───────────────────────────────────
  static String get pembayaranCreate => '${baseUrl}pembayaran';
  static String pembayaranStatus(int idTagihan) =>
      '${baseUrl}pembayaran/status/$idTagihan';

  // ── Keluhan Endpoints ──────────────────────────────────────
  static String get keluhanCreate => '${baseUrl}keluhan';
  static String keluhanList(int userId) => '${baseUrl}keluhan/user/$userId';

  // ── Review Endpoints ───────────────────────────────────────
  static String get reviewCreate => '${baseUrl}review';
  static String reviewList(int kamarId) => '${baseUrl}review/kamar/$kamarId';
  static String reviewUpdate(int id) => '${baseUrl}review/$id';

  // ── Notifikasi Endpoints ───────────────────────────────────
  static String get notifikasiList => '${baseUrl}notifikasi';
  static String get notifikasiBacaSemua => '${baseUrl}notifikasi/baca-semua';
  static String notifikasiBaca(int id) => '${baseUrl}notifikasi/$id/baca';
  static String get oneSignalPlayerId => '${baseUrl}onesignal-player-id';
}
