// ============================================================
// BACKEND LAYER — kamar_detail_controller.dart
// Bertanggung jawab atas: load detail kamar, galeri foto,
// fasilitas, furnitur, review, dan booking dengan furnitur.
//
// Yang DIHAPUS dari versi lama (detail_produk_page):
// - base64 image, CartService, ProductItem, CheckoutModel
// - toggleFavorite, auto-refresh Timer
// - stok & berat produk
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/kamar_service.dart';
import '../../../data/services/review_service.dart';
import '../../../data/services/furnitur_service.dart';
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
  List<Map<String, dynamic>> fasilitasList = [];
  List<ReviewModel> reviewList = [];
  List<ReviewModel> displayedReviews = [];
  List<FurniturModel> furniturList = [];
  bool showAllReviews = false;
  static const int maxDisplayedReviews = 3;

  // Data booking
  int durasiSewa = 1; // bulan
  final int kamarId;

  // Furnitur yang dipilih: Map<id_furnitur, jumlah>
  Map<int, int> selectedFurnitur = {};

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  KamarDetailController({
    required this.kamarId,
    required this.onStateChanged,
  });

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    onStateChanged();

    try {
      await Future.wait([
        _loadKamarDetail(),
        _loadFurnitur(),
      ]);
      _loadReviews(); // Load review tidak perlu await
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
    if (kamar == null) throw ApiException(message: 'Kamar tidak ditemukan.', statusCode: 404);
  }

  Future<void> _loadFurnitur() async {
    furniturList = await FurniturService.getFurniturList();
  }

  Future<void> _loadReviews() async {
    isLoadingReviews = true;
    onStateChanged();
    try {
      reviewList = await ReviewService.getReviewsByKamar(kamarId);
      displayedReviews = reviewList.take(maxDisplayedReviews).toList();
    } catch (_) {
      reviewList = [];
    } finally {
      isLoadingReviews = false;
      onStateChanged();
    }
  }

  // ── Toggle Show All Reviews ────────────────────────────────
  void toggleShowAllReviews() {
    showAllReviews = !showAllReviews;
    displayedReviews = showAllReviews
        ? reviewList
        : reviewList.take(maxDisplayedReviews).toList();
    onStateChanged();
  }

  // ── Durasi Sewa ────────────────────────────────────────────
  void setDurasi(int bulan) {
    durasiSewa = bulan;
    onStateChanged();
  }

  // ── Furnitur Selection ─────────────────────────────────────
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
        orElse: () => FurniturModel(idFurnitur: 0, namaFurnitur: '', jumlah: 0, hargaSewaTambahan: 0),
      );
      total += furnitur.hargaSewaTambahan * entry.value * durasiSewa;
    }
    return total;
  }

  double get totalBiaya => totalBiayaKamar + totalBiayaFurnitur;

  // ── Navigasi ───────────────────────────────────────────────
  void goToBookingForm(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/booking-form',
      arguments: {
        'kamar_id': kamarId,
        'durasi': durasiSewa,
        'furnitur': selectedFurnitur,
        'total': totalBiaya,
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

  void goToTulisReview(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/tulis-review',
      arguments: {'kamar_id': kamarId},
    );
  }

  void goBack(BuildContext context) => Navigator.pop(context);

  // ── Format Harga ──────────────────────────────────────────
  String formatHarga(double harga) {
    if (harga >= 1000000) {
      return 'Rp.${(harga / 1000000).toStringAsFixed(0)}.000.000';
    } else if (harga >= 1000) {
      return 'Rp.${(harga / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp.${harga.toStringAsFixed(0)}';
  }
}