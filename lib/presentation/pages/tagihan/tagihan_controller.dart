import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/helper/api_helper.dart';
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
  bool isLoading = true;
  bool isDeleting = false;
  String? errorMessage;

  List<TagihanUiModel> allTagihan = [];
  List<TagihanUiModel> filteredTagihan = [];

  String selectedFilter = 'Belum Bayar';
  final VoidCallback onStateChanged;

  TagihanController({required this.onStateChanged});

  // ── LOAD TAGIHAN ─────────────────────────
  Future<void> loadTagihan() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();

      if (userId == null) {
        errorMessage = 'Sesi tidak ditemukan';
        isLoading = false;
        onStateChanged();
        return;
      }

      final headers = await ApiHelper.authHeaders;
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
        double parseDouble(dynamic v) =>
            v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

        return TagihanUiModel(
          idTagihan: e['id_tagihan'] as int,
          idBooking: e['id_booking'] as int,
          namaKamar: e['nama_kamar'] as String?,
          fotoKamar: e['foto_kamar'] as String?,
          periodeAwal: e['tgl_mulai_sewa'] as String? ?? '',
          periodeAkhir: e['tgl_akhir_sewa'] as String? ?? '',
          periodeBulan: e['periode_bulan'] as String? ?? '',
          totalTagihan: parseDouble(e['total_tagihan']),
          nominalDenda: parseDouble(e['nominal_denda']),
          tglJatuhTempo: e['tgl_jatuh_tempo'] as String?,
          statusTagihan: e['status_tagihan'] as String,
          statusBooking: e['status_booking'] as String? ?? 'aktif',
          tglBooking: e['periode_bulan'] as String? ?? '',
        );
      }).toList();

      _applyFilter();
    } catch (e) {
      errorMessage = 'Gagal memuat tagihan';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── HAPUS TAGIHAN ────────────────────────
  Future<void> hapusTagihan(
      BuildContext context, TagihanUiModel tagihan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Tagihan?'),
        content: const Text(
            'Tagihan yang sudah lunas akan dihapus dari riwayat.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (konfirmasi != true) return;

    isDeleting = true;
    onStateChanged();

    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}tagihan/${tagihan.idTagihan}'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception();
      }

      final List list = data['data'] ?? [];

      allTagihan = list.map((e) {
        double parseDouble(dynamic v) =>
            v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

        return TagihanUiModel(
          idTagihan: e['id_tagihan'] as int,
          idBooking: e['id_booking'] as int,
          namaKamar: e['nama_kamar'] as String?,
          fotoKamar: e['foto_kamar'] as String?,
          periodeAwal: e['tgl_mulai_sewa'] as String? ?? '',
          periodeAkhir: e['tgl_akhir_sewa'] as String? ?? '',
          periodeBulan: e['periode_bulan'] as String? ?? '',
          totalTagihan: parseDouble(e['total_tagihan']),
          nominalDenda: parseDouble(e['nominal_denda']),
          tglJatuhTempo: e['tgl_jatuh_tempo'] as String?,
          statusTagihan: e['status_tagihan'] as String,
          statusBooking: e['status_booking'] as String? ?? 'aktif',
          tglBooking: e['periode_bulan'] as String? ?? '',
        );
      }).toList();

      _applyFilter();
    } catch (e) {
      errorMessage = 'Gagal hapus tagihan';
    } finally {
      isDeleting = false;
      onStateChanged();
    }
  }

  // ── FILTER ───────────────────────────────
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
              t.statusBooking != 'selesai' &&
              t.statusTagihan == 'belum_bayar')
          .toList();
      break;

    case 'Lunas':
      filteredTagihan = allTagihan
          .where((t) =>
              t.statusBooking != 'batal' &&
              t.statusBooking != 'selesai' &&  // ← tambah ini
              t.statusTagihan == 'lunas')
          .toList();
      break;

    case 'Batal':
      filteredTagihan =
          allTagihan.where((t) => t.statusBooking == 'batal').toList();
      break;

    case 'Selesai':
      filteredTagihan =
          allTagihan.where((t) => t.statusBooking == 'selesai').toList();
      break;

    default:
      filteredTagihan = List.from(allTagihan);
  }
  onStateChanged();
}

  // ── FORMAT ───────────────────────────────
  String formatHarga(double harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  // ── INFO ─────────────────────────────────
void showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Info Tagihan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Belum Bayar = tagihan aktif'),
            Text('• Lunas = sudah dibayar'),
            Text('• Batal = booking dibatalkan'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BBA8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('OK',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── GO TO DETAIL ─────────────────────────
  void goToDetail(BuildContext context, TagihanUiModel tagihan) {
    Navigator.pushNamed(
      context,
      '/detail-kamarku',
      arguments: {'booking_id': tagihan.idBooking},
    ).then((result) {
      if (result == 'selesai') loadTagihan(); // ✅ refresh jika akhiri sewa
    });
  }

  // ── ERROR ────────────────────────────────
  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}