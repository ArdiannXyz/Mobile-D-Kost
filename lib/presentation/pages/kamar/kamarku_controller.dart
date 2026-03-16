// ============================================================
// BACKEND LAYER — kamarku_controller.dart
// Load daftar booking user, format data, navigasi.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/services/booking_service.dart';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:dkost/data/helper/api_exception.dart';
import 'package:dkost/data/models/booking_models.dart';

class KamarkuController {
  bool isLoading = true;
  String? errorMessage;
  List<BookingModel> bookings = [];
  final VoidCallback onStateChanged;

  KamarkuController({required this.onStateChanged});

  Future<void> loadBookings() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        errorMessage = 'Sesi tidak ditemukan.';
        return;
      }
      bookings = await BookingService.getBookingList(userId);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat data kamarku.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Format helpers ─────────────────────────────────────────
  String formatHarga(double harga) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0)
        .format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      return DateFormat('d/M/yyyy').format(DateTime.parse(tgl));
    } catch (_) {
      return tgl;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return 'Menunggu Pembayaran';
      case 'aktif':    return 'Aktif';
      case 'selesai':  return 'Selesai';
      case 'batal':    return 'Dibatalkan';
      case 'expired':  return 'Kadaluarsa';
      default:         return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return const Color(0xFFF39C12);
      case 'aktif':    return const Color(0xFF2ECC71);
      case 'selesai':  return const Color(0xFF3498DB);
      case 'batal':    return const Color(0xFFE74C3C);
      case 'expired':  return const Color(0xFF9E9E9E);
      default:         return const Color(0xFF9E9E9E);
    }
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToDetail(BuildContext context, int bookingId) {
    Navigator.pushNamed(context, '/detail-kamarku',
        arguments: {'booking_id': bookingId});
  }
}