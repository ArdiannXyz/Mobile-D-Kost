import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';
import '../models/booking_models.dart';
import 'cache_service.dart';

class BookingService {
  BookingService._();

  // ── GET: List riwayat booking ──────────────────────────────
  static Future<List<BookingModel>> getBookingList(
    int userId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${CacheService.keyBookingPrefix}$userId';

    if (!forceRefresh) {
      final cached = CacheService.get<List<BookingModel>>(cacheKey);
      if (cached != null) return cached;
    }

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

        final result = list.map((e) => BookingModel.fromJson(e)).toList();

        // Cache booking list 2 menit
        CacheService.set(cacheKey, result, ttl: CacheService.ttlBooking);
        return result;
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

  // ── GET: Booking aktif ─────────────────────────────────────
  static Future<List<BookingModel>> getBookingAktif(
    int userId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${CacheService.keyBookingAktifPrefix}$userId';

    if (!forceRefresh) {
      final cached = CacheService.get<List<BookingModel>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.bookingAktif(userId)),
        headers: headers,
      );

      final data = ApiHelper.handleResponse(response);

      if (data['success'] == true) {
        final list = data['data'];
        if (list == null || list is! List) return [];

        final result = list.map((e) => BookingModel.fromJson(e)).toList();

        // Cache booking aktif 2 menit
        CacheService.set(cacheKey, result, ttl: CacheService.ttlBooking);
        return result;
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        message: 'Gagal memuat booking aktif.',
        statusCode: 500,
      );
    }
  }

  // ── GET: Detail booking ────────────────────────────────────
  // Detail tidak di-cache karena statusnya bisa berubah kapan saja
  static Future<BookingModel?> getBookingDetail(int id) async {
    final headers = await ApiHelper.authHeaders;
    final response = await http.get(
      Uri.parse(ApiConstants.bookingDetail(id)),
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
  // Setelah berhasil → invalidate cache booking user ini
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
      Uri.parse(ApiConstants.bookingCreate),
      headers: headers,
      body: jsonEncode({
        'id_user': userId,
        'id_kamar': idKamar,
        'tgl_mulai_sewa': tglMulaiSewa,
        'durasi_sewa_bulan': durasiSewaBulan,
        'furnitur': furniturList,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Booking baru → cache booking sudah tidak valid
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (userId != null) {
        CacheService.invalidatePrefix(CacheService.keyBookingPrefix);
        CacheService.invalidatePrefix(CacheService.keyBookingAktifPrefix);
      }
      // Cache kamar juga perlu di-refresh (status kamar bisa berubah)
      CacheService.invalidate(CacheService.keyKamarList);
    }

    return data;
  }

  // ── PUT: Batalkan booking ──────────────────────────────────
  static Future<Map<String, dynamic>> batalBooking(int id) async {
    final headers = await ApiHelper.authHeaders;
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}booking/$id/batal'), // endpoint batal belum di ApiConstants
      headers: headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Batal booking → invalidate semua cache booking
    if (response.statusCode == 200) {
      CacheService.invalidatePrefix(CacheService.keyBookingPrefix);
      CacheService.invalidatePrefix(CacheService.keyBookingAktifPrefix);
      CacheService.invalidate(CacheService.keyKamarList);
    }

    return data;
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
      Uri.parse('${ApiConstants.baseUrl}booking/$idBooking/furnitur'), // endpoint furnitur belum di ApiConstants
      headers: headers,
      body: jsonEncode({'furnitur': furniturList}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      // Detail booking berubah → invalidate cache booking
      CacheService.invalidatePrefix(CacheService.keyBookingPrefix);
      CacheService.invalidatePrefix(CacheService.keyBookingAktifPrefix);
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
      Uri.parse('${ApiConstants.baseUrl}booking/$idBooking/selesai'), // endpoint selesai belum di ApiConstants
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      // Sewa selesai → invalidate semua cache terkait booking & kamar
      CacheService.invalidatePrefix(CacheService.keyBookingPrefix);
      CacheService.invalidatePrefix(CacheService.keyBookingAktifPrefix);
      CacheService.invalidate(CacheService.keyKamarList);
      return data as Map<String, dynamic>;
    }
    throw ApiException(
      message: data['message'] ?? 'Gagal mengakhiri sewa.',
      statusCode: response.statusCode,
    );
  }
}
