// ============================================================
// BACKEND LAYER — booking_service.dart
// Semua HTTP request terkait booking.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class BookingService {
  BookingService._();

  // ── GET: List booking user ─────────────────────────────────
  static Future<List<BookingModel>> getBookingList(int userId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.bookingList(userId)),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        final List list = data['data'];
        return list.map((e) => BookingModel.fromJson(e)).toList();
      }
      return [];
    } on ApiException { rethrow; }
    catch (_) { throw ApiException(message: 'Gagal memuat riwayat booking.', statusCode: 500); }
  }

  // ── GET: Detail booking ────────────────────────────────────
  static Future<BookingModel?> getBookingDetail(int bookingId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.bookingDetail(bookingId)),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) return BookingModel.fromJson(data['data']);
      return null;
    } on ApiException { rethrow; }
    catch (_) { throw ApiException(message: 'Gagal memuat detail booking.', statusCode: 500); }
  }

  // ── POST: Buat booking baru ────────────────────────────────
  static Future<Map<String, dynamic>> createBooking({
    required int idKamar,
    required String tglMulaiSewa,
    required int durasiSewaBulan,
    required Map<int, int> selectedFurnitur, // {id_furnitur: jumlah}
  }) async {
    try {
      final userId = await ApiHelper.getUserId();
      final headers = await ApiHelper.authHeaders;

      final furniturItems = selectedFurnitur.entries
          .map((e) => {'id_furnitur': e.key, 'jumlah': e.value})
          .toList();

      final response = await http.post(
        Uri.parse(ApiConstants.bookingCreate),
        headers: headers,
        body: jsonEncode({
          'id_user': userId,
          'id_kamar': idKamar,
          'tgl_mulai_sewa': tglMulaiSewa,
          'durasi_sewa_bulan': durasiSewaBulan,
          'furnitur': furniturItems,
        }),
      );
      return ApiHelper.handleResponse(response);
    } on ApiException { rethrow; }
    catch (_) { throw ApiException(message: 'Gagal membuat booking.', statusCode: 500); }
  }

  // ── PUT: Batalkan booking ──────────────────────────────────
  static Future<bool> batalkanBooking(int bookingId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.put(
        Uri.parse('${ApiConstants.bookingDetail(bookingId)}/batal'),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      return data['success'] == true;
    } on ApiException { rethrow; }
    catch (_) { throw ApiException(message: 'Gagal membatalkan booking.', statusCode: 500); }
  }
}