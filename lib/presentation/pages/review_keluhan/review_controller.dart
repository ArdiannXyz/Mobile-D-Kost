// ============================================================
// FILE: lib/presentation/pages/review/review_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/review_service.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/review_models.dart';
import '../../../data/models/booking_models.dart';

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

// ── Enum state halaman tulis review ──────────────────────────
enum ReviewPageState { loading, noBooking, hasBooking }

// ── Controller: Tulis Review ──────────────────────────────────
class TulisReviewController {
  bool isSubmitting = false;
  int selectedRating = 0;
  final TextEditingController komentarController = TextEditingController();
  final int kamarId;
  final VoidCallback onStateChanged;

  ReviewPageState pageState = ReviewPageState.loading;
  List<BookingModel> bookingAktifList = [];
  BookingModel? bookingAktif;

  TulisReviewController({
    required this.kamarId,
    required this.onStateChanged,
  });

  void dispose() => komentarController.dispose();

  // ── Cek apakah user punya booking aktif ───────────────────
  Future<void> initForm() async {
    pageState = ReviewPageState.loading;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        pageState = ReviewPageState.noBooking;
        onStateChanged();
        return;
      }

      bookingAktifList = await BookingService.getBookingAktif(userId);

      // Hanya booking aktif untuk kamar yang sedang dilihat
      final bookingKamarIni = bookingAktifList
          .where((b) => b.idKamar == kamarId)
          .toList();

      if (bookingKamarIni.isNotEmpty) {
        bookingAktif = bookingKamarIni.first;
        pageState    = ReviewPageState.hasBooking;
      } else {
        pageState = ReviewPageState.noBooking;
      }
    } catch (e) {
      pageState = ReviewPageState.noBooking;
    }

    onStateChanged();
  }

  void setRating(int rating) {
    selectedRating = rating;
    onStateChanged();
  }

  String? validate() {
    if (selectedRating == 0) return 'Pilih rating bintang terlebih dahulu.';
    if (komentarController.text.trim().isEmpty)
      return 'Komentar tidak boleh kosong.';
    if (komentarController.text.trim().length < 5)
      return 'Komentar minimal 5 karakter.';
    return null;
  }

  // ── Dialog konfirmasi posting ─────────────────────────────
  Future<bool> _showKonfirmasiDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Posting ulasan?',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        content: const Text(
          'Ulasan Anda akan ditampilkan ke penghuni lain.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9E9E9E)),
            child: const Text('Batalkan',
                style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BBA8A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Posting',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> submit(BuildContext context) async {
    final err = validate();
    if (err != null) {
      _showErrorSnackbar(context, err);
      return;
    }

    final lanjut = await _showKonfirmasiDialog(context);
    if (!lanjut) return;

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
        _showSuccessSnackbar(context, 'Ulasan berhasil dikirim!');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(context, 'Gagal mengirim ulasan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted) _showErrorSnackbar(context, 'Terjadi kesalahan.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  void goBack(BuildContext context) => Navigator.pop(context);

  void _showSuccessSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ]),
        backgroundColor: const Color(0xFF1BBA8A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ));
  }

  void _showErrorSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.info_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ]),
        backgroundColor: const Color(0xFFE24B4A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
        elevation: 0,
      ));
  }
}

// ── Controller: Edit Review ───────────────────────────────────
// ── Controller: Edit Review ───────────────────────────────────
class EditReviewController {
  bool isSubmitting = false;
  bool isDeleting = false;
  int selectedRating;
  final TextEditingController komentarController;
  final int reviewId;
  final int kamarId;
  final VoidCallback onStateChanged;

  final int _originalRating;
  final String _originalKomentar;

  EditReviewController({
    required this.reviewId,
    required this.kamarId,
    required ReviewModel existingReview,
    required this.onStateChanged,
  })  : selectedRating = existingReview.rating,
        _originalRating = existingReview.rating,
        _originalKomentar = existingReview.komentar,
        komentarController =
            TextEditingController(text: existingReview.komentar);

  void dispose() => komentarController.dispose();

  bool get hasChanges =>
      selectedRating != _originalRating ||
      komentarController.text.trim() != _originalKomentar.trim();

  void setRating(int rating) {
    selectedRating = rating;
    onStateChanged();
  }

  String? validate() {
    if (selectedRating == 0) return 'Pilih rating bintang.';
    if (komentarController.text.trim().isEmpty)
      return 'Komentar tidak boleh kosong.';
    return null;
  }

Future<void> handleBackPressed(BuildContext context) async {
  if (!hasChanges) {
    Navigator.pop(context);
    return;
  }

  final result = await showDialog<String>(
    context: context,
    barrierColor: Colors.black45,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hapus Draf?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perubahan yang belum disimpan akan hilang.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'hapus'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Hapus',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'simpan'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1BBA8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (!context.mounted) return;

  if (result == 'hapus') {
    Navigator.pop(context);
  } else if (result == 'simpan') {
    await simpan(context);
  }
}

  Future<void> simpan(BuildContext context) async {
    final err = validate();
    if (err != null) {
      _showErrorSnackbar(context, err);
      return;
    }

    final lanjut = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Simpan perubahan?',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        content: const Text(
          'Ulasan Anda akan diperbarui.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9E9E9E)),
            child: const Text('Batal', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (lanjut != true) return;

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
        _showSuccessSnackbar(context, 'Ulasan berhasil diperbarui.');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(context, 'Gagal memperbarui ulasan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted) _showErrorSnackbar(context, 'Terjadi kesalahan.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  Future<void> hapus(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus ulasan?',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        content: const Text(
          'Ulasan ini akan dihapus secara permanen dan tidak bisa dikembalikan.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9E9E9E)),
            child: const Text('Batal', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Hapus',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    isDeleting = true;
    onStateChanged();
    try {
      final ok = await ReviewService.deleteReview(reviewId: reviewId);
      if (!context.mounted) return;
      if (ok) {
        _showSuccessSnackbar(context, 'Ulasan berhasil dihapus.');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(context, 'Gagal menghapus ulasan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted) _showErrorSnackbar(context, 'Terjadi kesalahan.');
    } finally {
      isDeleting = false;
      onStateChanged();
    }
  }

  // goBack sudah tidak dipakai langsung, tapi boleh dipertahankan
  void goBack(BuildContext context) => Navigator.pop(context);

  void _showSuccessSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ]),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ));
  }

  void _showErrorSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.info_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ]),
        backgroundColor: const Color(0xFFE24B4A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
        elevation: 0,
      ));
  }
}