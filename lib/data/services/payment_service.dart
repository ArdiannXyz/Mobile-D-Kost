// ============================================================
// payment_service.dart
// Ganti MidtransService + PembayaranService lama
// Letakkan di: lib/data/services/payment_service.dart
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/api_constants.dart';
import '../helper/api_helper.dart';
import '../helper/api_exception.dart';
import '../models/payment_model.dart';

class PaymentService {
  PaymentService._();

  // ── POST: Charge pembayaran (Core API) ─────────────────────
  // Backend kamu yang hit Midtrans, lalu return hasilnya
  //
  // Request body ke backend:
  // {
  //   "id_tagihan": 1,
  //   "payment_type": "bank_transfer",   // atau qris/gopay/shopeepay
  //   "bank": "bca"                      // hanya untuk bank_transfer
  // }
  //
  // Response dari backend (terusan dari Midtrans):
  // {
  //   "success": true,
  //   "data": { ...midtrans charge response... }
  // }
  static Future<PaymentResult> createPayment({
    required int idTagihan,
    required PaymentMethodType method,
  }) async {
    try {
      final headers = await ApiHelper.authHeaders;

      final body = <String, dynamic>{
        'id_tagihan'   : idTagihan,
        'payment_type' : method.paymentType,
      };

      // Tambahkan bank jika VA
      if (method.bank != null) {
        body['bank'] = method.bank;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.pembayaranCreate),
        headers: headers,
        body: jsonEncode(body),
      );

      final result = ApiHelper.handleResponse(response);

      if (result['success'] == true) {
        // data bisa langsung Midtrans response atau dibungkus di 'data'
        final midtransData = result['data'] ?? result;
        return parsePaymentResult(midtransData as Map<String, dynamic>);
      }

      throw ApiException(
        message: result['message'] ?? 'Gagal membuat pembayaran.',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Gagal membuat pembayaran: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // ── GET: Cek status pembayaran ─────────────────────────────
  // Return: 'settlement' | 'pending' | 'deny' | 'cancel' | 'expire'
  static Future<String> checkStatus(int idTagihan) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse(ApiConstants.pembayaranStatus(idTagihan)),
        headers: headers,
      );

      final result = ApiHelper.handleResponse(response);
      return result['data']?['transaction_status'] ??
             result['status'] ??
             'pending';
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        message: 'Gagal mengecek status pembayaran.',
        statusCode: 500,
      );
    }
  }

  // ── POST: Cancel pembayaran ────────────────────────────────
  static Future<bool> cancelPayment(int idTagihan) async {
    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}payment/cancel'),
        headers: headers,
        body: jsonEncode({'id_tagihan': idTagihan}),
      );

      final result = ApiHelper.handleResponse(response);
      return result['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Ambil data pembayaran pending yang sudah ada berdasarkan id_tagihan
    static Future<PaymentResult> getExistingPayment(int idTagihan) async {
      try {
        final headers  = await ApiHelper.authHeaders;
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}pembayaran/pending/$idTagihan'),
          headers: headers,
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          return parsePaymentResult(data['data'] as Map<String, dynamic>);
        }

        // Tidak ada pending → coba buat baru pakai metode terakhir
        final lastMethod = data['last_method'] as String?;
        final lastBank   = data['last_bank']   as String?;

        if (lastMethod == null) {
              throw ApiException(
                message   : 'no_previous_method',
                statusCode: 404,
              );
            }

        // Konversi ke PaymentMethodType
        final method = _resolveMethod(lastMethod, lastBank);

        return await createPayment(
          idTagihan: idTagihan,
          method   : method,
        );
      } on ApiException {
        rethrow;
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message   : 'Gagal memuat pembayaran: ${e.toString()}',
          statusCode: 500,
        );
      }
    }

    static PaymentMethodType _resolveMethod(String paymentType, String? bank) {
      switch (paymentType) {
        case 'bank_transfer':
          switch (bank) {
            case 'bca':     return PaymentMethodType.bcaVa;
            case 'bni':     return PaymentMethodType.bniVa;
            case 'bri':     return PaymentMethodType.briVa;
            case 'mandiri': return PaymentMethodType.mandiriVa;
            default:        return PaymentMethodType.bcaVa;
          }
        case 'qris':      return PaymentMethodType.qris;
        case 'gopay':     return PaymentMethodType.gopay;
        case 'shopeepay': return PaymentMethodType.shopeepay;
        default:          return PaymentMethodType.qris;
      }
    }
}

