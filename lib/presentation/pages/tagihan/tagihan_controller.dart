import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:dkost/data/helper/api_exception.dart';
import 'package:dkost/data/helper/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TagihanUiModel {
  final int idTagihan;
  final int idBooking;
  final String? namaKamar;
  final String? fotoKamar;
  final String periodeAwal;
  final String periodeAkhir;
  final String periodeBulan;
  final double totalTagihan;
  final double nominalDenda;
  final String? tglJatuhTempo;
  final String statusTagihan;
  final String statusBooking;
  final String tglBooking;

  const TagihanUiModel({
    required this.idTagihan,
    required this.idBooking,
    this.namaKamar,
    this.fotoKamar,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.periodeBulan,
    required this.totalTagihan,
    required this.nominalDenda,
    this.tglJatuhTempo,
    required this.statusTagihan,
    required this.statusBooking,
    required this.tglBooking,
  });
}

class TagihanController {
  bool isLoading  = true;
  bool isDeleting = false;
  String? errorMessage;
  List<TagihanUiModel> allTagihan      = [];
  List<TagihanUiModel> filteredTagihan = [];
  String selectedFilter = 'Belum Bayar';
  final VoidCallback onStateChanged;

  TagihanController({required this.onStateChanged});

  // ── Load tagihan langsung dari endpoint tagihan/user ───────
  // Tidak lagi lewat booking — supaya semua tagihan tampil,
  // bukan hanya tagihan terakhir per booking
  Future<void> loadTagihan() async {
    isLoading    = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        errorMessage = 'Sesi tidak ditemukan.';
        return;
      }

      final headers  = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}tagihan/user/$userId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        errorMessage = data['message'] ?? 'Gagal memuat tagihan.';
        return;
      }

      final List list = data['data'] ?? [];

      allTagihan = list.map((e) {
        // Backend mengembalikan nominal sebagai String ("325000.00")
        // sehingga perlu double.parse, bukan cast as num
        double parseDouble(dynamic v) =>
            v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

        return TagihanUiModel(
          idTagihan    : e['id_tagihan']      as int,
          idBooking    : e['id_booking']      as int,
          namaKamar    : e['nama_kamar']      as String?,
          fotoKamar    : e['foto_kamar']      as String?,
          periodeAwal  : e['tgl_mulai_sewa']  as String? ?? '',
          periodeAkhir : e['tgl_akhir_sewa']  as String? ?? '',
          periodeBulan : e['periode_bulan']   as String? ?? '',
          totalTagihan : parseDouble(e['total_tagihan']),
          nominalDenda : parseDouble(e['nominal_denda']),
          tglJatuhTempo: e['tgl_jatuh_tempo'] as String?,
          statusTagihan: e['status_tagihan']  as String,
          statusBooking: e['status_booking']  as String? ?? 'aktif',
          tglBooking   : e['periode_bulan']   as String? ?? '',
        );
      }).toList();

      _applyFilter();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat tagihan.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Hapus tagihan ──────────────────────────────────────────
  Future<void> hapusTagihan(
      BuildContext context, TagihanUiModel tagihan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Tagihan?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: const Text(
            'Tagihan yang sudah lunas akan dihapus dari riwayat.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    isDeleting = true;
    onStateChanged();

    try {
      final headers  = await ApiHelper.authHeaders;
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}tagihan/${tagihan.idTagihan}'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (!context.mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        allTagihan.removeWhere((t) => t.idTagihan == tagihan.idTagihan);
        _applyFilter();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tagihan berhasil dihapus.'),
            backgroundColor: const Color(0xFF2ECC71),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        _showError(context, data['message'] ?? 'Gagal menghapus tagihan.');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Terjadi kesalahan: $e');
    } finally {
      isDeleting = false;
      onStateChanged();
    }
  }

  // ── Filter ─────────────────────────────────────────────────
  void filterTagihan(String filter) {
    selectedFilter = filter;
    _applyFilter();
  }

  void _applyFilter() {
    switch (selectedFilter) {
      case 'Belum Bayar':
        filteredTagihan = allTagihan
            .where((t) =>
                t.statusBooking != 'batal' &&
                t.statusTagihan == 'belum_bayar')
            .toList();
        break;
      case 'Batal':
        filteredTagihan = allTagihan
            .where((t) => t.statusBooking == 'batal')
            .toList();
        break;
      case 'Lunas':
        filteredTagihan = allTagihan
            .where((t) =>
                t.statusBooking != 'batal' &&
                t.statusTagihan == 'lunas')
            .toList();
        break;
      default:
        filteredTagihan = List.from(allTagihan);
    }
    onStateChanged();
  }

  // ── Format helpers ─────────────────────────────────────────
  String formatHarga(double harga) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('dd - MM - yyyy').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  void showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Info Tagihan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
                color: Color(0xFFF39C12),
                label: 'Belum Bayar - tagihan aktif'),
            SizedBox(height: 6),
            _InfoRow(
                color: Color(0xFF9E9E9E),
                label: 'Batal - booking dibatalkan'),
            SizedBox(height: 6),
            _InfoRow(
                color: Color(0xFF2ECC71),
                label: 'Lunas - sudah dibayar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF2ECC71))),
          ),
        ],
      ),
    );
  }

  void goToDetail(BuildContext context, TagihanUiModel tagihan) {
    Navigator.pushNamed(context, '/detail-kamarku',
        arguments: {'booking_id': tagihan.idBooking});
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

class _InfoRow extends StatelessWidget {
  final Color color;
  final String label;
  const _InfoRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}