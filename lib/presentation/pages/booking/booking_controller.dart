// ============================================================
// BACKEND LAYER — booking_controller.dart
// Bertanggung jawab atas: load detail booking, kalkulasi
// biaya, submit booking baru (checkout), navigasi.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/booking_models.dart';
import '../../../data/models/kamar_models.dart';
import '../../../data/models/furnitur_models.dart';

// ── Controller: Detail Kamarku ────────────────────────────────
class DetailKamarkuController {
  bool isLoading = true;
  String? errorMessage;
  BookingModel? booking;
  final int bookingId;
  final VoidCallback onStateChanged;

  DetailKamarkuController({
    required this.bookingId,
    required this.onStateChanged,
  });

  Future<void> loadDetail() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();
    try {
      booking = await BookingService.getBookingDetail(bookingId);
      if (booking == null) errorMessage = 'Data booking tidak ditemukan.';
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat detail booking.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Kalkulasi ──────────────────────────────────────────────
  double get totalFurnitur => booking?.furniturList
          .fold(0, (sum, f) => sum! + f.subtotal * (booking?.durasiSewaBulan ?? 1)) ?? 0;

  double get totalBiaya => (booking?.totalBiayaBulanan ?? 0) + totalFurnitur;

  // ── Format helpers ─────────────────────────────────────────
  String formatHarga(double harga) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0);
    return formatter.format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d/M/yyyy').format(dt);
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

  void goToPayment(BuildContext context) {
    Navigator.pushNamed(context, '/pembayaran',
        arguments: {'booking_id': bookingId});
  }

  void goBack(BuildContext context) => Navigator.pop(context);
  Future<void> refresh() => loadDetail();
}

// ── Controller: Checkout (Buat Pesanan) ──────────────────────
class CheckoutController {
  bool isSubmitting = false;
  final KamarModel kamar;
  final int durasiSewa;
  final Map<int, int> selectedFurnitur;
  final List<FurniturModel> furniturList;
  final String tglMulaiSewa;
  final VoidCallback onStateChanged;

  CheckoutController({
    required this.kamar,
    required this.durasiSewa,
    required this.selectedFurnitur,
    required this.furniturList,
    required this.tglMulaiSewa,
    required this.onStateChanged,
  });

  // ── Kalkulasi ──────────────────────────────────────────────
  double get totalKamar => kamar.hargaPerBulan * durasiSewa;

  double get totalFurnitur {
    double total = 0;
    for (final entry in selectedFurnitur.entries) {
      final f = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '', jumlah: 0, hargaSewaTambahan: 0),
      );
      total += f.hargaSewaTambahan * entry.value * durasiSewa;
    }
    return total;
  }

  double get totalPembayaran => totalKamar + totalFurnitur;

  List<_FurniturCheckoutItem> get furniturItems {
    return selectedFurnitur.entries.map((entry) {
      final f = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '-', jumlah: 0, hargaSewaTambahan: 0),
      );
      return _FurniturCheckoutItem(
        nama: f.namaFurnitur,
        jumlah: entry.value,
        harga: f.hargaSewaTambahan,
        subtotal: f.hargaSewaTambahan * entry.value * durasiSewa,
      );
    }).toList();
  }

  // ── Submit Booking ─────────────────────────────────────────
  Future<void> buatPesanan(BuildContext context) async {
    isSubmitting = true;
    onStateChanged();

    try {
      final result = await BookingService.createBooking(
        idKamar: kamar.idKamar,
        tglMulaiSewa: tglMulaiSewa,
        durasiSewaBulan: durasiSewa,
        selectedFurnitur: selectedFurnitur,
      );

      if (!context.mounted) return;

      if (result['success'] == true) {
        final bookingId = result['data']['id_booking'];
        _showSuccess(context, 'Booking berhasil dibuat!');
        // Navigasi ke halaman pembayaran
        Navigator.pushReplacementNamed(
          context,
          '/pembayaran',
          arguments: {'booking_id': bookingId},
        );
      } else {
        _showError(context, result['message'] ?? 'Gagal membuat booking.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e.message);
    } catch (_) {
      if (context.mounted) _showError(context, 'Terjadi kesalahan. Coba lagi.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  // ── Format helpers ─────────────────────────────────────────
  String formatHarga(double harga) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0);
    return formatter.format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d/M/yyyy').format(dt);
    } catch (_) { return tgl; }
  }

  String get tglAkhirSewa {
    try {
      final tglMulai = DateTime.parse(tglMulaiSewa);
      final tglAkhir = DateTime(
          tglMulai.year, tglMulai.month + durasiSewa, tglMulai.day);
      return DateFormat('d/M/yyyy').format(tglAkhir);
    } catch (_) { return '-'; }
  }

  void goBack(BuildContext context) => Navigator.pop(context);

  void _showSuccess(BuildContext ctx, String msg) => _snack(ctx, msg, const Color(0xFF2ECC71));
  void _showError(BuildContext ctx, String msg) => _snack(ctx, msg, Colors.red);
  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

class _FurniturCheckoutItem {
  final String nama;
  final int jumlah;
  final double harga;
  final double subtotal;
  const _FurniturCheckoutItem({
    required this.nama,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
  });
}
