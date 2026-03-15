// ============================================================
// BACKEND LAYER — edit_profil_controller.dart
// Bertanggung jawab atas: validasi, update user via service,
// deteksi perubahan untuk dialog "Hapus Draft?", navigasi.
//
// Yang DIHAPUS dari versi lama:
// - SharedPreferences inline di onPressed
// - print('User ID tidak ditemukan')
// - Field alamat belum ada → sekarang ditambahkan
// - UserService.updateUser positional → sekarang named params
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/user_models.dart';

class EditProfilController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;

  // ── Text Controllers ───────────────────────────────────────
  late final TextEditingController namaController;
  late final TextEditingController emailController;
  late final TextEditingController noHpController;
  late final TextEditingController alamatController;

  // Simpan nilai awal untuk deteksi perubahan
  final String _initialNama;
  final String _initialNoHp;
  final String _initialAlamat;

  final VoidCallback onStateChanged;

  EditProfilController({
    required User user,
    required this.onStateChanged,
  })  : _initialNama = user.nama,
        _initialNoHp = user.noHp,
        _initialAlamat = user.alamat ?? '' {
    namaController = TextEditingController(text: user.nama);
    emailController = TextEditingController(text: user.email);
    noHpController = TextEditingController(text: user.noHp);
    alamatController = TextEditingController(text: user.alamat ?? '');
  }

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    alamatController.dispose();
  }

  // ── Deteksi perubahan (untuk dialog Hapus Draft) ───────────
  bool get hasChanges =>
      namaController.text != _initialNama ||
      noHpController.text != _initialNoHp ||
      alamatController.text != _initialAlamat;

  // ── Validasi ───────────────────────────────────────────────
  String? validate() {
    if (namaController.text.trim().isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    if (noHpController.text.trim().isEmpty) {
      return 'No. Handphone tidak boleh kosong.';
    }
    return null;
  }

  // ── Simpan Perubahan ───────────────────────────────────────
  Future<void> simpan(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        _showErrorSnackbar(context, 'Sesi tidak ditemukan. Silakan login ulang.');
        return;
      }

      final success = await UserService.updateUser(
        id: userId,
        nama: namaController.text.trim(),
        email: emailController.text.trim(),
        noHp: noHpController.text.trim(),
        alamat: alamatController.text.trim(),
      );

      if (!context.mounted) return;

      if (success) {
        _showSuccessSnackbar(context, 'Profil berhasil diperbarui');
        Navigator.pop(context);
      } else {
        _showErrorSnackbar(context, 'Gagal memperbarui profil.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Handle Back (cek perubahan dulu) ──────────────────────
  Future<bool> onWillPop(BuildContext context) async {
    if (!hasChanges) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _HapusDraftDialog(),
    );

    if (result == 'hapus') return true;   // buang draft, keluar
    if (result == 'simpan') {             // simpan dulu baru keluar
      await simpan(context);
      return false; // simpan sudah handle pop
    }
    return false; // batal, tetap di halaman
  }

  // ── Helper Snackbar ────────────────────────────────────────
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message),
        ]),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ── Dialog "Hapus Draft?" ──────────────────────────────────────
class _HapusDraftDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                // Hapus (buang perubahan)
                TextButton(
                  onPressed: () => Navigator.pop(context, 'hapus'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Hapus',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 10),
                // Simpan (save dulu baru keluar)
                TextButton(
                  onPressed: () => Navigator.pop(context, 'simpan'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
    );
  }
}