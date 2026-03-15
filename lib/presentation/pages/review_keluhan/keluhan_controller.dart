// ============================================================
// BACKEND LAYER — keluhan_controller.dart
// Bertanggung jawab atas: load daftar keluhan, form lapor
// keluhan (validasi, upload foto, submit), dialog konfirmasi.
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/keluhan_service.dart';
import '../../../data/services/kamar_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/keluhan_models.dart';
import '../../../data/models/kamar_models.dart';
import 'package:intl/intl.dart';

class KeluhanController {
  // ── State daftar keluhan ───────────────────────────────────
  bool isLoadingList = true;
  List<KeluhanModel> keluhanList = [];
  String? errorList;

  // ── State form lapor ───────────────────────────────────────
  bool isSubmitting = false;
  KamarModel? kamarAktif; // kamar yang sedang disewa user

  final TextEditingController nomorKamarController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  File? fotoBukti;
  String? fotoBuktiNama;
  DateTime selectedDate = DateTime.now();

  final VoidCallback onStateChanged;

  KeluhanController({required this.onStateChanged});

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    nomorKamarController.dispose();
    tanggalController.dispose();
    deskripsiController.dispose();
  }

  // ── Init daftar keluhan ────────────────────────────────────
  Future<void> loadKeluhanList() async {
    isLoadingList = true;
    errorList = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        errorList = 'Sesi tidak ditemukan.';
        return;
      }
      keluhanList = await KeluhanService.getKeluhanList(userId);
    } on ApiException catch (e) {
      errorList = e.message;
    } catch (_) {
      errorList = 'Gagal memuat daftar keluhan.';
    } finally {
      isLoadingList = false;
      onStateChanged();
    }
  }

  // ── Init form lapor ────────────────────────────────────────
  Future<void> initForm() async {
    // Set tanggal hari ini
    tanggalController.text = DateFormat('dd/MM/yyyy').format(selectedDate);

    // Coba ambil kamar aktif user dari booking
    try {
      final userId = await ApiHelper.getUserId();
      if (userId != null) {
        final kamarList = await KamarService.getKamarList();
        // Ambil kamar pertama sebagai default (idealnya dari booking aktif)
        if (kamarList.isNotEmpty) {
          kamarAktif = kamarList.first;
          nomorKamarController.text = kamarAktif!.nomorKamar;
        }
      }
    } catch (_) {}
    onStateChanged();
  }

  // ── Pilih Tanggal ──────────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2ECC71),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedDate = picked;
      tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
      onStateChanged();
    }
  }

  // ── Pilih Foto Bukti ───────────────────────────────────────
  Future<void> pickFoto(BuildContext context) async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog(context);
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      fotoBukti = File(picked.path);
      fotoBuktiNama = picked.name;
      onStateChanged();
    }
  }

  void removeFoto() {
    fotoBukti = null;
    fotoBuktiNama = null;
    onStateChanged();
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) {
    return showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Pilih Sumber Foto',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF2ECC71)),
            label: const Text('Kamera',
                style: TextStyle(color: Color(0xFF2ECC71))),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined,
                color: Color(0xFF2ECC71)),
            label: const Text('Galeri',
                style: TextStyle(color: Color(0xFF2ECC71))),
          ),
        ],
      ),
    );
  }

  // ── Validasi Form ──────────────────────────────────────────
  String? validate() {
    if (nomorKamarController.text.trim().isEmpty) {
      return 'Nomor kamar tidak boleh kosong.';
    }
    if (deskripsiController.text.trim().isEmpty) {
      return 'Deskripsi keluhan tidak boleh kosong.';
    }
    if (deskripsiController.text.trim().length < 10) {
      return 'Deskripsi keluhan minimal 10 karakter.';
    }
    return null;
  }

  // ── Dialog Konfirmasi "Lanjutkan Pengisian?" ───────────────
  Future<bool> showKonfirmasiDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lanjutkan pengisian ?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Batalkan
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Batalkan',
                        style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  // Lanjut
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Lanjut',
                        style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  // ── Submit Keluhan ─────────────────────────────────────────
  Future<void> laporkan(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    // Tampilkan dialog konfirmasi
    final lanjut = await showKonfirmasiDialog(context);
    if (!lanjut) return;

    isSubmitting = true;
    onStateChanged();

    try {
      final success = await KeluhanService.createKeluhan(
        idKamar: kamarAktif?.idKamar ?? 0,
        deskripsiMasalah: deskripsiController.text.trim(),
        fotoBukti: fotoBukti,
      );

      if (!context.mounted) return;

      if (success) {
        _showSuccessSnackbar(context, 'Keluhan berhasil dilaporkan.');
        Navigator.pop(context, true); // kembali ke daftar, refresh
      } else {
        _showErrorSnackbar(context, 'Gagal mengirim keluhan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToLaporKeluhan(BuildContext context) {
    Navigator.pushNamed(context, '/lapor-keluhan').then((result) {
      if (result == true) loadKeluhanList();
    });
  }

  void goBack(BuildContext context) => Navigator.pop(context);

  // ── Status Label & Color ───────────────────────────────────
  String statusLabel(String status) {
    switch (status) {
      case 'pending':    return 'Menunggu';
      case 'diproses':   return 'Diproses';
      case 'selesai':    return 'Selesai';
      default:           return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':    return const Color(0xFFF39C12);
      case 'diproses':   return const Color(0xFF3498DB);
      case 'selesai':    return const Color(0xFF2ECC71);
      default:           return const Color(0xFF9E9E9E);
    }
  }

  // ── Snackbar helpers ───────────────────────────────────────
  void _showSuccessSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(msg),
      ]),
      backgroundColor: const Color(0xFF2ECC71),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showErrorSnackbar(BuildContext context, String msg) {
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
