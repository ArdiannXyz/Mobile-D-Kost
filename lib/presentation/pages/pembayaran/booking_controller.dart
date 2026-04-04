// ============================================================
// BACKEND LAYER — booking_controller.dart
// Letakkan di: lib/presentation/pages/pembayaran/
// ============================================================

import 'package:flutter/material.dart';
import 'package:dkost/data/services/booking_service.dart';
import 'package:dkost/data/services/kamar_service.dart';
import 'package:dkost/data/services/furnitur_service.dart';
import 'package:dkost/data/helper/api_exception.dart';
import 'package:dkost/data/models/kamar_models.dart';
import 'package:dkost/data/models/furnitur_models.dart';

// Nama class disesuaikan dengan import di booking_page.dart
class BookingController {
  // ── Args dari halaman sebelumnya ───────────────────────────
  final Map<String, dynamic> args;
  final VoidCallback onStateChanged;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  // ── Data ───────────────────────────────────────────────────
  KamarModel? kamar;
  List<FurniturModel> furniturList = [];

  BookingController({
    required this.args,
    required this.onStateChanged,
  });

  // ── Getters dari args ──────────────────────────────────────
  int get kamarId => args['kamar_id'] as int;
  int get durasi   => args['durasi'] as int;

  String get tglMulaiIso => args['tgl_mulai'] as String? ?? '';
  String get tglAkhirIso => args['tgl_akhir'] as String? ?? '';

  Map<int, int> get selectedFurnitur =>
      (args['furnitur'] as Map<int, int>? ?? {});

  double get totalBiaya => (args['total'] as num?)?.toDouble() ?? 0;

  // ── Formatted tanggal ──────────────────────────────────────
  String get tglMulaiFormatted => _formatTanggal(tglMulaiIso);
  String get tglAkhirFormatted => _formatTanggal(tglAkhirIso);

  String _formatTanggal(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const bln = ['','Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Agu','Sep','Okt','Nov','Des'];
      return '${dt.day} ${bln[dt.month]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  // ── Info kamar ─────────────────────────────────────────────
  String get namaKamar {
    if (kamar == null) return '-';
    final tipe = kamar!.tipeKamar.isEmpty
        ? ''
        : kamar!.tipeKamar[0].toUpperCase() + kamar!.tipeKamar.substring(1);
    return 'Kos $tipe ${kamar!.nomorKamar}';
  }

  String get tipeKamar {
    if (kamar == null) return '-';
    final t = kamar!.tipeKamar;
    return t.isEmpty ? '-' : t[0].toUpperCase() + t.substring(1);
  }

  double get hargaPerBulan => kamar?.hargaPerBulan ?? 0;

  // ── Kalkulasi biaya ────────────────────────────────────────
  double get totalBiayaKamar => hargaPerBulan * durasi;

  double get totalBiayaFurnitur {
    double total = 0;
    for (final entry in selectedFurnitur.entries) {
      final f = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '', jumlah: 0, hargaSewaTambahan: 0),
      );
      total += f.hargaSewaTambahan * entry.value * durasi;
    }
    return total;
  }

  // ── List furnitur yang dipilih (untuk ditampilkan) ─────────
  List<Map<String, dynamic>> get selectedFurniturList {
    final list = <Map<String, dynamic>>[];
    for (final entry in selectedFurnitur.entries) {
      final f = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '', jumlah: 0, hargaSewaTambahan: 0),
      );
      if (f.idFurnitur != 0) {
        list.add({
          'nama'    : f.namaFurnitur,
          'qty'     : entry.value,
          'subtotal': f.hargaSewaTambahan * entry.value * durasi,
        });
      }
    }
    return list;
  }

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    onStateChanged();
    try {
      await Future.wait([
        _loadKamar(),
        _loadFurnitur(),
      ]);
    } catch (_) {} finally {
      isLoading = false;
      onStateChanged();
    }
  }

  Future<void> _loadKamar() async {
    kamar = await KamarService.getKamarDetail(kamarId);
  }

  Future<void> _loadFurnitur() async {
    if (selectedFurnitur.isEmpty) return;
    furniturList = await FurniturService.getFurniturList();
  }

  // ── Konfirmasi & Submit Booking ────────────────────────────
  Future<void> konfirmasi(BuildContext context) async {
    isSubmitting = true;
    onStateChanged();

    try {
      // Format tanggal ke yyyy-MM-dd
      final tglMulaiDate = _toDateString(tglMulaiIso);

      // Sesuai signature BookingService.createBooking
      final result = await BookingService.createBooking(
        idKamar         : kamarId,
        tglMulaiSewa    : tglMulaiDate,
        durasiSewaBulan : durasi,
        selectedFurnitur: selectedFurnitur, // Map<int, int> langsung
      );

      if (!context.mounted) return;

      if (result['success'] == true) {
        final idBooking  = result['data']['id_booking'];
        final idTagihan  = result['data']['id_tagihan'];
        final totalBayar = (result['data']['total_biaya'] as num).toDouble();

        // Navigasi ke halaman pembayaran (booking_page.dart yang sudah ada)
        Navigator.pushReplacementNamed(
          context,
          '/pembayaran',
          arguments: {
            'id_booking' : idBooking,
            'id_tagihan' : idTagihan,
            'total_biaya': totalBayar,
            'nama_kamar' : namaKamar,
          },
        );
      } else {
        _showError(context, result['message'] ?? 'Gagal membuat booking.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e.message);
    } catch (e) {
      if (context.mounted) _showError(context, 'Terjadi kesalahan: $e');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  String _toDateString(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

String formatHarga(double harga) {
  // Format angka dengan pemisah titik ribuan
  final parts = harga.toStringAsFixed(0).split('');
  String result = '';
  int counter = 0;
  for (int i = parts.length - 1; i >= 0; i--) {
    if (counter > 0 && counter % 3 == 0) result = '.$result';
    result = parts[i] + result;
    counter++;
  }
  return 'Rp $result';
}

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}