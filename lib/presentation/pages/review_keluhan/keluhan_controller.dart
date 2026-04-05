// ============================================================
// FILE: lib/presentation/pages/keluhan/keluhan_controller.dart
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/services/keluhan_service.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_constants.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/keluhan_models.dart';
import '../../../data/models/booking_models.dart';

enum KeluhanPageState { loading, noBooking, hasBooking }

class KeluhanController {
  bool isLoadingList = true;
  List<KeluhanModel> keluhanList = [];
  String? errorList;
  bool isSubmitting = false;

  KeluhanPageState pageState = KeluhanPageState.loading;

  List<BookingModel> bookingAktifList = [];
  BookingModel? bookingAktif;

  final TextEditingController tanggalController   = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  XFile?     fotoBuktiXFile;
  Uint8List? fotoBuktiBytes;
  String?    fotoBuktiNama;

  DateTime selectedDate = DateTime.now();
  final VoidCallback onStateChanged;

  KeluhanController({required this.onStateChanged});

  void dispose() {
    tanggalController.dispose();
    deskripsiController.dispose();
  }

  // ── Load daftar keluhan ────────────────────────────────────
  Future<void> loadKeluhanList() async {
    isLoadingList = true;
    errorList = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      debugPrint('=== [Keluhan] userId: $userId');
      if (userId == null) {
        errorList = 'Sesi tidak ditemukan. Silakan login ulang.';
        return;
      }

      final token = await ApiHelper.getToken();
      final url   = ApiConstants.keluhanList(userId);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept'      : 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List list = data['data'] ?? [];
          keluhanList = list
              .map((e) => KeluhanModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          errorList = data['message'] ?? 'Gagal memuat keluhan.';
        }
      } else {
        errorList = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      debugPrint('=== [Keluhan] ERROR: $e');
      debugPrint('=== [Keluhan] STACK: $stack');
      errorList = 'Gagal memuat daftar keluhan.';
    } finally {
      isLoadingList = false;
      onStateChanged();
    }
  }

  // ── Init form lapor baru ───────────────────────────────────
  Future<void> initForm() async {
    pageState = KeluhanPageState.loading;
    tanggalController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        pageState = KeluhanPageState.noBooking;
        onStateChanged();
        return;
      }

      bookingAktifList = await BookingService.getBookingAktif(userId);

      if (bookingAktifList.isNotEmpty) {
        bookingAktif = bookingAktifList.first;
        pageState    = KeluhanPageState.hasBooking;
      } else {
        pageState = KeluhanPageState.noBooking;
      }
    } catch (e) {
      debugPrint('=== [Keluhan] ERROR initForm: $e');
      pageState = KeluhanPageState.noBooking;
    }

    onStateChanged();
  }

  // ── Pilih kamar dari dropdown ──────────────────────────────
  void selectBooking(BookingModel booking) {
    bookingAktif = booking;
    onStateChanged();
  }

  // ── Init form edit ─────────────────────────────────────────
  void initEditForm(KeluhanModel keluhan) {
    deskripsiController.text = keluhan.deskripsiMasalah;
    try {
      selectedDate = DateTime.parse(keluhan.tglLapor.replaceAll(' ', 'T'));
    } catch (_) {
      selectedDate = DateTime.now();
    }
    tanggalController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    onStateChanged();
  }

  // ── Pilih Tanggal ──────────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context    : context,
      initialDate: selectedDate,
      firstDate  : DateTime(2020),
      lastDate   : DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary  : Color(0xFF2ECC71),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedDate           = picked;
      tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
      onStateChanged();
    }
  }

  // ── Pilih Foto ─────────────────────────────────────────────
  Future<void> pickFoto(BuildContext context) async {
    final picker = ImagePicker();
    ImageSource? source;

    if (kIsWeb) {
      source = ImageSource.gallery;
    } else {
      source = await _showImageSourceDialog(context);
    }
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final bytes    = await picked.readAsBytes();
    fotoBuktiXFile = picked;
    fotoBuktiBytes = bytes;
    fotoBuktiNama  = picked.name;
    onStateChanged();
  }

  void removeFoto() {
    fotoBuktiXFile = null;
    fotoBuktiBytes = null;
    fotoBuktiNama  = null;
    onStateChanged();
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) {
    return showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pilih Sumber Foto',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon : const Icon(Icons.camera_alt_outlined, color: Color(0xFF2ECC71)),
            label: const Text('Kamera', style: TextStyle(color: Color(0xFF2ECC71))),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon : const Icon(Icons.photo_library_outlined, color: Color(0xFF2ECC71)),
            label: const Text('Galeri', style: TextStyle(color: Color(0xFF2ECC71))),
          ),
        ],
      ),
    );
  }

  // ── Validasi lapor baru (butuh bookingAktif) ───────────────
  String? validate() {
    if (bookingAktif == null) return 'Pilih kamar terlebih dahulu.';
    if (deskripsiController.text.trim().isEmpty)
      return 'Deskripsi keluhan tidak boleh kosong.';
    if (deskripsiController.text.trim().length < 10)
      return 'Deskripsi keluhan minimal 10 karakter.';
    return null;
  }

  // ── Validasi edit (tidak butuh bookingAktif) ───────────────
  String? validateEdit() {
    if (deskripsiController.text.trim().isEmpty)
      return 'Deskripsi keluhan tidak boleh kosong.';
    if (deskripsiController.text.trim().length < 10)
      return 'Deskripsi keluhan minimal 10 karakter.';
    return null;
  }

  // ── Dialog Konfirmasi Submit ───────────────────────────────
  Future<bool> showKonfirmasiDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Lanjutkan?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        content: const Text(
          'Pastikan data yang Anda masukkan sudah benar.',
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
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Lanjut',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Dialog saat klik card keluhan ──────────────────────────
  Future<void> showEditDialog(
      BuildContext context, KeluhanModel keluhan) async {
    if (keluhan.statusKeluhan != 'pending') {
      // Dialog: tidak bisa diedit
      await showDialog(
        context: context,
        barrierColor: Colors.black45,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tidak bisa diedit',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          content: Text(
            'Keluhan yang sudah berstatus "${statusLabel(keluhan.statusKeluhan)}" tidak dapat diubah lagi.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK, mengerti',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      return;
    }

    // Dialog: konfirmasi edit
    final konfirmasi = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit keluhan?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        content: const Text(
          'Anda akan mengedit keluhan yang masih berstatus Menunggu.',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Edit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (konfirmasi == true && context.mounted) {
      final result = await Navigator.pushNamed(
        context,
        '/edit-keluhan',
        arguments: {'keluhan': keluhan},
      );
      if (result == true || result == 'deleted') loadKeluhanList();
    }
  }

  // ── Submit lapor baru ──────────────────────────────────────
  Future<void> laporkan(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    final lanjut = await showKonfirmasiDialog(context);
    if (!lanjut) return;

    isSubmitting = true;
    onStateChanged();

    try {
      final success = await KeluhanService.createKeluhan(
        idKamar         : bookingAktif!.idKamar,
        deskripsiMasalah: deskripsiController.text.trim(),
        fotoBuktiXFile  : fotoBuktiXFile,
      );
      if (!context.mounted) return;
      if (success) {
        _showSuccessSnackbar(context, 'Keluhan berhasil dilaporkan.');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(context, 'Gagal mengirim keluhan.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted)
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  // ── Submit edit keluhan ────────────────────────────────────
  Future<void> editKeluhan(BuildContext context, int idKeluhan) async {
    final errorMsg = validateEdit();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    final lanjut = await showKonfirmasiDialog(context);
    if (!lanjut) return;

    isSubmitting = true;
    onStateChanged();

    try {
      final token  = await ApiHelper.getToken();
      final userId = await ApiHelper.getUserId();
      final url    = '${ApiConstants.baseUrl}keluhan/$idKeluhan';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept'       : 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['_method']           = 'PUT';
      request.fields['deskripsi_masalah'] = deskripsiController.text.trim();
      if (userId != null) request.fields['id_user'] = userId.toString();

      if (fotoBuktiXFile != null && fotoBuktiBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto_bukti',
          fotoBuktiBytes!,
          filename: fotoBuktiNama ?? 'foto.jpg',
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!context.mounted) return;

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSuccessSnackbar(context, 'Keluhan berhasil diperbarui.');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(
            context, data['message'] ?? 'Gagal memperbarui keluhan.');
      }
    } catch (e) {
      if (context.mounted)
        _showErrorSnackbar(context, 'Terjadi kesalahan: $e');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  // ── Hapus keluhan ──────────────────────────────────────────
  Future<void> hapusKeluhan(BuildContext context, int idKeluhan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFEECEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFE24B4A), size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Hapus keluhan?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Keluhan ini akan dihapus secara permanen dan tidak bisa dikembalikan.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE0E0E0)),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF9E9E9E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20)),
                        ),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const VerticalDivider(
                      width: 0.5, thickness: 0.5, color: Color(0xFFE0E0E0)),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE24B4A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20)),
                        ),
                      ),
                      child: const Text('Hapus',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (konfirmasi != true) return;

    isSubmitting = true;
    onStateChanged();

    try {
      final token    = await ApiHelper.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}keluhan/$idKeluhan'),
        headers: {
          'Accept'       : 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!context.mounted) return;

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSuccessSnackbar(context, 'Keluhan berhasil dihapus.');
        Navigator.pop(context, 'deleted');
      } else {
        _showErrorSnackbar(
            context, data['message'] ?? 'Gagal menghapus keluhan.');
      }
    } catch (e) {
      if (context.mounted)
        _showErrorSnackbar(context, 'Terjadi kesalahan: $e');
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

  String statusLabel(String status) {
    switch (status) {
      case 'pending':  return 'Menunggu';
      case 'diproses': return 'Diproses';
      case 'selesai':  return 'Selesai';
      default:         return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':  return const Color(0xFFF39C12);
      case 'diproses': return const Color(0xFF3498DB);
      case 'selesai':  return const Color(0xFF2ECC71);
      default:         return const Color(0xFF9E9E9E);
    }
  }

  // ── Snackbar sukses ────────────────────────────────────────
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
        backgroundColor: const Color(0xFF1DB954),
        behavior       : SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ));
  }

  // ── Snackbar error ─────────────────────────────────────────
  void _showErrorSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.info_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ]),
        backgroundColor: const Color(0xFFE24B4A),
        behavior       : SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
        elevation: 0,
      ));
  }
}