import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';
import '../models/booking_models.dart';

class BookingService {
  BookingService._();

  static Future<List<BookingModel>> getBookingList(int userId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.bookingList(userId)),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);

      if (data['success'] == true) {
        final list = data['data'];
        if (list == null || list is! List) return [];

        return list.map((e) => BookingModel.fromJson(e)).toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        message: 'Gagal memuat riwayat booking.',
        statusCode: 500,
      );
    }
  }

  static Future<List<BookingModel>> getBookingAktif(int userId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}booking/aktif/$userId'),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);

      if (data['success'] == true) {
        final list = data['data'];
        if (list == null || list is! List) return [];

        return list.map((e) => BookingModel.fromJson(e)).toList();
      }

      return [];
    } catch (_) {
      throw ApiException(
        message: 'Gagal memuat booking aktif.',
        statusCode: 500,
      );
    }
  }

  // ── GET: Detail booking ────────────────────────────────────
  static Future<BookingModel?> getBookingDetail(int id) async {
    final headers = await ApiHelper.authHeaders;
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}booking/$id'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return BookingModel.fromJson(data['data']);
    }
    if (response.statusCode == 404) return null;
    throw ApiException(
      message: data['message'] ?? 'Gagal memuat detail booking.',
      statusCode: response.statusCode,
    );
  }

  // ── POST: Buat booking baru ────────────────────────────────
  static Future<Map<String, dynamic>> createBooking({
    required int idKamar,
    required String tglMulaiSewa,
    required int durasiSewaBulan,
    required Map<int, int> selectedFurnitur,
  }) async {
    final headers = await ApiHelper.authHeaders;
    final userId = await ApiHelper.getUserId();

    final furniturList = selectedFurnitur.entries
        .map((e) => {'id_furnitur': e.key, 'jumlah': e.value})
        .toList();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}booking'),
      headers: headers,
      body: jsonEncode({
        'id_user': userId,
        'id_kamar': idKamar,
        'tgl_mulai_sewa': tglMulaiSewa,
        'durasi_sewa_bulan': durasiSewaBulan,
        'furnitur': furniturList,
      }),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── PUT: Batalkan booking ──────────────────────────────────
  static Future<Map<String, dynamic>> batalBooking(int id) async {
    final headers = await ApiHelper.authHeaders;
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}booking/$id/batal'),
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── POST: Tambah furnitur mid-sewa ─────────────────────────
  static Future<Map<String, dynamic>> tambahFurnitur({
    required int idBooking,
    required Map<int, int> furnitur,
  }) async {
    final headers = await ApiHelper.authHeaders;

    final furniturList = furnitur.entries
        .map((e) => {'id_furnitur': e.key, 'jumlah': e.value})
        .toList();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}booking/$idBooking/furnitur'),
      headers: headers,
      body: jsonEncode({'furnitur': furniturList}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data as Map<String, dynamic>;
    }
    throw ApiException(
      message: data['message'] ?? 'Gagal menambah furnitur.',
      statusCode: response.statusCode,
    );
  }

  // ── POST: Akhiri sewa sekarang ─────────────────────────────
  static Future<Map<String, dynamic>> akhiriSewa(int idBooking) async {
    final headers = await ApiHelper.authHeaders;
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}booking/$idBooking/selesai'),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data as Map<String, dynamic>;
    }
    throw ApiException(
      message: data['message'] ?? 'Gagal mengakhiri sewa.',
      statusCode: response.statusCode,
    );
  }
}
