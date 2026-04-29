import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // ── Base URL (auto-detect environment) ─────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/';      // Web
    } else if (Platform.isAndroid) {
      //return 'http://10.0.2.2:8000/api/';       // Emulator Android
      return 'http://10.113.107.109:8000/api/'; 
    } else {
      return 'http://10.73.161.109:8000/api/';  // Device fisik
    }
  }

  static String get storageUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/storage/';
    } else if (Platform.isAndroid) {
      //return 'http://10.0.2.2:8000/storage/';
      return 'http://10.113.107.109:8000/storage/';
    } else {
      return 'http://10.73.161.109:8000/storage/';
    }
  }

  // ── Auth Endpoints ─────────────────────────────────────────
  static String get register      => '${baseUrl}register';
  static String get login         => '${baseUrl}login';
  static String get logout        => '${baseUrl}logout';
  static String get lupaPassword  => '${baseUrl}lupa-password';
  static String get cekOtp        => '${baseUrl}cek-otp';
  static String get gantiPassword => '${baseUrl}ganti-password';

  // ── User Endpoints ─────────────────────────────────────────
  static String userDetail(int id) => '${baseUrl}user/$id';
  static String updateUser(int id)  => '${baseUrl}user/$id';

  // ── Kamar Endpoints ────────────────────────────────────────
  static String get kamarList        => '${baseUrl}kamar';
  static String kamarDetail(int id)  => '${baseUrl}kamar/$id';

  // ── Booking Endpoints ──────────────────────────────────────
  static String get bookingCreate          => '${baseUrl}booking';
  static String bookingList(int userId)    => '${baseUrl}booking/user/$userId';
  static String bookingDetail(int id)      => '${baseUrl}booking/$id';
  static String bookingAktif(int userId)   => '${baseUrl}booking/aktif/$userId';

  // ── Tagihan Endpoints ──────────────────────────────────────
  static String tagihanList(int bookingId) => '${baseUrl}tagihan/booking/$bookingId';
  static String tagihanDetail(int id)      => '${baseUrl}tagihan/$id';

  // ── Pembayaran Endpoints ───────────────────────────────────
  static String get pembayaranCreate              => '${baseUrl}pembayaran';
  static String pembayaranStatus(int idTagihan)   => '${baseUrl}pembayaran/status/$idTagihan';

  // ── Keluhan Endpoints ──────────────────────────────────────
  static String get keluhanCreate          => '${baseUrl}keluhan';
  static String keluhanList(int userId)    => '${baseUrl}keluhan/user/$userId';

  // ── Review Endpoints ───────────────────────────────────────
  static String get reviewCreate          => '${baseUrl}review';
  static String reviewList(int kamarId)   => '${baseUrl}review/kamar/$kamarId';
  static String reviewUpdate(int id)      => '${baseUrl}review/$id';
}