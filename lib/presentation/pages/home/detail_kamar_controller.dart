// ============================================================
// BACKEND LAYER — kamar_detail_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/kamar_service.dart';
import '../../../data/services/review_service.dart';
import '../../../data/services/furnitur_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/kamar_models.dart';
import '../../../data/models/review_models.dart';
import '../../../data/models/furnitur_models.dart';

class KamarDetailController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  bool isLoadingReviews = true;
  String? errorMessage;

  // ── Data ───────────────────────────────────────────────────
  KamarModel? kamar;
  List<String> galeriUrls = [];
  List<ReviewModel> reviewList = [];
  List<ReviewModel> displayedReviews = [];
  List<FurniturModel> furniturList = [];
  bool showAllReviews = false;
  static const int maxDisplayedReviews = 3;

  // ── Review milik user yang login ───────────────────────────
  ReviewModel? _myExistingReview;
  ReviewModel? get myExistingReview => _myExistingReview;
  bool get sudahReview => _myExistingReview != null;

  // ── Data Booking ───────────────────────────────────────────
  int durasiSewa = 1;
  DateTime? tglMulaiSewa;
  final int kamarId;
  Map<int, int> selectedFurnitur = {};

  final VoidCallback onStateChanged;

  KamarDetailController({
    required this.kamarId,
    required this.onStateChanged,
  });

  // ── Tanggal Akhir Sewa (otomatis) ─────────────────────────
  DateTime? get tglAkhirSewa {
    if (tglMulaiSewa == null) return null;
    return DateTime(
      tglMulaiSewa!.year,
      tglMulaiSewa!.month + durasiSewa,
      tglMulaiSewa!.day,
    );
  }

  void setTglMulai(DateTime date) {
    tglMulaiSewa = date;
    onStateChanged();
  }

  String formatTanggal(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      await Future.wait([
        _loadKamarDetail(),
        _loadFurnitur(),
      ]);
      _loadReviews(); // tidak di-await agar tidak block UI
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat detail kamar.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  Future<void> _loadKamarDetail() async {
    kamar = await KamarService.getKamarDetail(kamarId);
    if (kamar == null) {
      throw ApiException(message: 'Kamar tidak ditemukan.', statusCode: 404);
    }
  }

  Future<void> _loadFurnitur() async {
    furniturList = await FurniturService.getFurniturList();
  }

  // ── Load Reviews + cek apakah user sudah review ────────────
  Future<void> _loadReviews() async {
    isLoadingReviews = true;
    onStateChanged();
    try {
      reviewList = await ReviewService.getReviewsByKamar(kamarId);
      displayedReviews = reviewList.take(maxDisplayedReviews).toList();

      // Cek review milik user yang sedang login
      final userId = await ApiHelper.getUserId();
      if (userId != null) {
        _myExistingReview = reviewList
            .where((r) => r.idUser == userId)
            .firstOrNull;
      }
    } catch (_) {
      reviewList = [];
      _myExistingReview = null;
    } finally {
      isLoadingReviews = false;
      onStateChanged();
    }
  }

  void toggleShowAllReviews() {
    showAllReviews = !showAllReviews;
    displayedReviews = showAllReviews
        ? reviewList
        : reviewList.take(maxDisplayedReviews).toList();
    onStateChanged();
  }

  // ── Durasi & Furnitur ──────────────────────────────────────
  void setDurasi(int bulan) {
    durasiSewa = bulan;
    onStateChanged();
  }

  void tambahFurnitur(int furniturId) {
    selectedFurnitur[furniturId] = (selectedFurnitur[furniturId] ?? 0) + 1;
    onStateChanged();
  }

  void kurangFurnitur(int furniturId) {
    final current = selectedFurnitur[furniturId] ?? 0;
    if (current <= 1) {
      selectedFurnitur.remove(furniturId);
    } else {
      selectedFurnitur[furniturId] = current - 1;
    }
    onStateChanged();
  }

  int getFurniturQty(int furniturId) => selectedFurnitur[furniturId] ?? 0;

  // ── Kalkulasi Total Biaya ──────────────────────────────────
  double get totalBiayaKamar => (kamar?.hargaPerBulan ?? 0) * durasiSewa;

  double get totalBiayaFurnitur {
    double total = 0;
    for (final entry in selectedFurnitur.entries) {
      final furnitur = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
          idFurnitur: 0,
          namaFurnitur: '',
          jumlah: 0,
          hargaSewaTambahan: 0,
        ),
      );
      total += furnitur.hargaSewaTambahan * entry.value * durasiSewa;
    }
    return total;
  }

  double get totalBiaya => totalBiayaKamar + totalBiayaFurnitur;

  // ── Validasi sebelum booking ───────────────────────────────
  String? validateBooking() {
    if (tglMulaiSewa == null) {
      return 'Pilih tanggal mulai sewa terlebih dahulu.';
    }
    return null;
  }

  // ── Format Harga ───────────────────────────────────────────
  String formatHarga(double harga) {
    if (harga >= 1000000) {
      final juta = (harga / 1000000).floor();
      final sisa = (harga % 1000000 / 1000).floor();
      if (sisa == 0) {
        return 'Rp.${juta}.000.000';
      } else {
        return 'Rp.${juta}.${sisa.toString().padLeft(3, '0')}.000';
      }
    } else if (harga >= 1000) {
      return 'Rp.${(harga / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp.${harga.toStringAsFixed(0)}';
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToBookingForm(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/booking-form',
      arguments: {
        'kamar_id'  : kamarId,
        'durasi'    : durasiSewa,
        'tgl_mulai' : tglMulaiSewa?.toIso8601String(),
        'tgl_akhir' : tglAkhirSewa?.toIso8601String(),
        'furnitur'  : selectedFurnitur,
        'total'     : totalBiaya,
      },
    );
  }

  void goToSemuaReview(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/semua-review',
      arguments: {'kamar_id': kamarId},
    );
  }

  // ← Sudah review → edit, belum review → tulis
  void goToTulisReview(BuildContext context) {
    if (sudahReview && _myExistingReview != null) {
      Navigator.pushNamed(
        context,
        '/edit-review',
        arguments: {'review': _myExistingReview},
      );
    } else {
      Navigator.pushNamed(
        context,
        '/tulis-review',
        arguments: {'kamar_id': kamarId},
      );
    }
  }

  void goBack(BuildContext context) => Navigator.pop(context);
}