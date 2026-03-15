// ============================================================
// BACKEND LAYER — review_service.dart
// Sesuai ERD tabel `review` D'Kost.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_models.dart';
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';

class ReviewService {
  ReviewService._();

  // ── GET: Review by Kamar ───────────────────────────────────
  static Future<List<ReviewModel>> getReviewsByKamar(int kamarId) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.reviewList(kamarId)),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      if (data['success'] == true) {
        final List list = data['data'];
        return list.map((e) => ReviewModel.fromJson(e)).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gagal memuat ulasan.', statusCode: 500);
    }
  }

  // ── POST: Buat Review ──────────────────────────────────────
  static Future<bool> createReview({
    required int kamarId,
    required int rating,
    required String komentar,
  }) async {
    try {
      final userId = await ApiHelper.getUserId();
      final headers = await ApiHelper.authHeaders;
      final response = await http.post(
        Uri.parse(ApiConstants.reviewCreate),
        headers: headers,
        body: jsonEncode({
          'id_user': userId,
          'id_kamar': kamarId,
          'rating': rating,
          'komentar': komentar,
        }),
      );
      final data = ApiHelper.handleResponse(response);
      return data['success'] == true;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gagal mengirim ulasan.', statusCode: 500);
    }
  }

  // ── PUT: Update Review ─────────────────────────────────────
  static Future<bool> updateReview({
    required int reviewId,
    required int kamarId,
    required int rating,
    required String komentar,
  }) async {
    try {
      final userId = await ApiHelper.getUserId();
      final headers = await ApiHelper.authHeaders;
      final response = await http.put(
        Uri.parse(ApiConstants.reviewUpdate(reviewId)),
        headers: headers,
        body: jsonEncode({
          'id_user': userId,
          'id_kamar': kamarId,
          'rating': rating,
          'komentar': komentar,
        }),
      );
      final data = ApiHelper.handleResponse(response);
      return data['success'] == true;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gagal memperbarui ulasan.', statusCode: 500);
    }
  }

  // ── DELETE: Hapus Review ───────────────────────────────────
  static Future<bool> deleteReview({required int reviewId}) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.delete(
        Uri.parse(ApiConstants.reviewUpdate(reviewId)),
        headers: headers,
      );
      final data = ApiHelper.handleResponse(response);
      return data['success'] == true;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gagal menghapus ulasan.', statusCode: 500);
    }
  }
}