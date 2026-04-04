// ============================================================
// FILE: lib/presentation/pages/kamarku/kamarku_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/services/booking_service.dart';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:dkost/data/helper/api_exception.dart';
import 'package:dkost/data/helper/api_constants.dart';
import 'package:dkost/data/models/booking_models.dart';

class KamarkuController {
  bool isLoading = true;
  String? errorMessage;
  List<BookingModel> bookings = [];
  final VoidCallback onStateChanged;

  KamarkuController({required this.onStateChanged});

Future<void> loadBookings() async {
  isLoading    = true;
  errorMessage = null;
  onStateChanged();

  try {
    final userId = await ApiHelper.getUserId();
    if (userId == null) {
      errorMessage = 'Sesi tidak ditemukan.';
      return;
    }
    bookings = await BookingService.getBookingAktif(userId);

    // ── DEBUG ──────────────────────────────────────────────
    print('=== KAMARKU DEBUG ===');
    print('Total bookings: ${bookings.length}');
    for (var b in bookings) {
      print('ID: ${b.idBooking}');
      print('fotoKamar: ${b.fotoKamar}');
      print('nomorKamar: ${b.nomorKamar}');
      print('tipeKamar: ${b.tipeKamar}');
    }
    print('=====================');
    // ── END DEBUG ──────────────────────────────────────────

  } on ApiException catch (e) {
    errorMessage = e.message;
  } catch (_) {
    errorMessage = 'Gagal memuat data kamarku.';
  } finally {
    isLoading = false;
    onStateChanged();
  }
}

  // ── Bangun URL foto dari path relatif ──────────────────────
  String? buildFotoUrl(String? fotoPath) {
    if (fotoPath == null || fotoPath.isEmpty) return null;
    // Jika sudah URL lengkap, return as-is
    if (fotoPath.startsWith('http')) return fotoPath;
    // Path relatif → gabung dengan storageUrl
    return '${ApiConstants.storageUrl}$fotoPath';
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
      case 'aktif':               return 'Aktif';
      case 'selesai':             return 'Selesai';
      case 'batal':               return 'Dibatalkan';
      case 'expired':             return 'Kadaluarsa';
      default:                    return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return const Color(0xFFF39C12);
      case 'aktif':               return const Color(0xFF2ECC71);
      case 'selesai':             return const Color(0xFF3498DB);
      case 'batal':               return const Color(0xFFE74C3C);
      case 'expired':             return const Color(0xFF9E9E9E);
      default:                    return const Color(0xFF9E9E9E);
    }
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToDetail(BuildContext context, int bookingId) {
    Navigator.pushNamed(context, '/detail-kamarku',
        arguments: {'booking_id': bookingId});
  }
}