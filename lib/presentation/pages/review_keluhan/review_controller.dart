// ============================================================
// BACKEND LAYER — review_controller.dart
// Bertanggung jawab atas: load review, tulis, edit, hapus,
// filter rating. Dipakai oleh 3 halaman:
// - SemuaReviewPage
// - TulisReviewPage
// - EditReviewPage
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/review_service.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/review_models.dart';

// ── Controller: Semua Review ──────────────────────────────────
class SemuaReviewController {
  bool isLoading = true;
  String? errorMessage;
  List<ReviewModel> allReviews = [];
  List<ReviewModel> filteredReviews = [];
  int? selectedRating; // null = semua
  final int kamarId;
  final VoidCallback onStateChanged;

  SemuaReviewController({
    required this.kamarId,
    required this.onStateChanged,
  });

  Future<void> loadReviews() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();
    try {
      allReviews = await ReviewService.getReviewsByKamar(kamarId);
      _applyFilter();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat ulasan.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void filterByRating(int? rating) {
    selectedRating = rating;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedRating == null) {
      filteredReviews = List.from(allReviews);
    } else {
      filteredReviews =
          allReviews.where((r) => r.rating == selectedRating).toList();
    }
    onStateChanged();
  }

  double get avgRating => allReviews.isEmpty
      ? 0
      : allReviews.map((r) => r.rating).reduce((a, b) => a + b) /
          allReviews.length;

  void goBack(BuildContext context) => Navigator.pop(context);
}

// ── Controller: Tulis Review ──────────────────────────────────
class TulisReviewController {
  bool isLoading = false;
  bool isSubmitting = false;
  int selectedRating = 0;
  final TextEditingController komentarController = TextEditingController();
  final int kamarId;
  final VoidCallback onStateChanged;

  TulisReviewController({
    required this.kamarId,
    required this.onStateChanged,
  });

  void dispose() => komentarController.dispose();

  void setRating(int rating) {
    selectedRating = rating;
    onStateChanged();
  }

  String? validate() {
    if (selectedRating == 0) return 'Pilih rating bintang terlebih dahulu.';
    if (komentarController.text.trim().isEmpty) return 'Komentar tidak boleh kosong.';
    if (komentarController.text.trim().length < 5) return 'Komentar minimal 5 karakter.';
    return null;
  }

  Future<void> submit(BuildContext context) async {
    final err = validate();
    if (err != null) { _showError(context, err); return; }

    isSubmitting = true;
    onStateChanged();
    try {
      final ok = await ReviewService.createReview(
        kamarId: kamarId,
        rating: selectedRating,
        komentar: komentarController.text.trim(),
      );
      if (!context.mounted) return;
      if (ok) {
        _showSuccess(context, 'Ulasan berhasil dikirim!');
        Navigator.pop(context, true);
      } else {
        _showError(context, 'Gagal mengirim ulasan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e.message);
    } catch (_) {
      if (context.mounted) _showError(context, 'Terjadi kesalahan.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
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

// ── Controller: Edit Review ───────────────────────────────────
class EditReviewController {
  bool isSubmitting = false;
  bool isDeleting = false;
  int selectedRating;
  final TextEditingController komentarController;
  final int reviewId;
  final int kamarId;
  final VoidCallback onStateChanged;

  EditReviewController({
    required this.reviewId,
    required this.kamarId,
    required ReviewModel existingReview,
    required this.onStateChanged,
  })  : selectedRating = existingReview.rating,
        komentarController =
            TextEditingController(text: existingReview.komentar);

  void dispose() => komentarController.dispose();

  void setRating(int rating) {
    selectedRating = rating;
    onStateChanged();
  }

  String? validate() {
    if (selectedRating == 0) return 'Pilih rating bintang.';
    if (komentarController.text.trim().isEmpty) return 'Komentar tidak boleh kosong.';
    return null;
  }

  Future<void> simpan(BuildContext context) async {
    final err = validate();
    if (err != null) { _showError(context, err); return; }

    isSubmitting = true;
    onStateChanged();
    try {
      final ok = await ReviewService.updateReview(
        reviewId: reviewId,
        kamarId: kamarId,
        rating: selectedRating,
        komentar: komentarController.text.trim(),
      );
      if (!context.mounted) return;
      if (ok) {
        _showSuccess(context, 'Ulasan berhasil diperbarui.');
        Navigator.pop(context, true);
      } else {
        _showError(context, 'Gagal memperbarui ulasan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e.message);
    } catch (_) {
      if (context.mounted) _showError(context, 'Terjadi kesalahan.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  Future<void> hapus(BuildContext context) async {
    // Dialog "Hapus Draf?" sesuai Figma
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hapus Draf?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      // User pilih "Simpan" → simpan dulu
      await simpan(context);
      return;
    }
    if (confirm == false) {
      // User pilih "Hapus" → hapus ulasan
      isDeleting = true;
      onStateChanged();
      try {
        final ok = await ReviewService.deleteReview(reviewId: reviewId);
        if (!context.mounted) return;
        if (ok) {
          _showSuccess(context, 'Ulasan berhasil dihapus.');
          Navigator.pop(context, true);
        } else {
          _showError(context, 'Gagal menghapus ulasan.');
        }
      } on ApiException catch (e) {
        if (context.mounted) _showError(context, e.message);
      } catch (_) {
        if (context.mounted) _showError(context, 'Terjadi kesalahan.');
      } finally {
        isDeleting = false;
        onStateChanged();
      }
    }
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