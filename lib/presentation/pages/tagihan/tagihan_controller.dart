import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:dkost/data/helper/api_exception.dart';
import 'package:dkost/data/services/booking_service.dart';
import 'package:dkost/data/services/midtrans_service.dart';       
import 'package:dkost/presentation/pages/payment/midtrans_page.dart'; 

// Model sederhana untuk tagihan di UI
class TagihanUiModel {
  final int idTagihan;
  final int idBooking;
  final String? namaKamar;
  final String? fotoKamar;
  final String periodeAwal;
  final String periodeAkhir;
  final double totalTagihan;
  final String statusTagihan;

  const TagihanUiModel({
    required this.idTagihan,
    required this.idBooking,
    this.namaKamar,
    this.fotoKamar,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.totalTagihan,
    required this.statusTagihan,
  });
}

class TagihanController {
  bool isLoading = true;
  String? errorMessage;
  List<TagihanUiModel> allTagihan = [];
  List<TagihanUiModel> filteredTagihan = [];
  String selectedFilter = 'Belum Bayar';
  final VoidCallback onStateChanged;

  TagihanController({required this.onStateChanged});

  Future<void> loadTagihan() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        errorMessage = 'Sesi tidak ditemukan.';
        return;
      }

      final bookings = await BookingService.getBookingList(userId);
      final List<TagihanUiModel> result = [];

      for (final booking in bookings) {
        if (booking.tagihan != null) {
          result.add(TagihanUiModel(
            idTagihan:    booking.tagihan!.idTagihan,
            idBooking:    booking.idBooking,
            namaKamar:    'Kos ${_cap(booking.tipeKamar ?? '')} ${booking.nomorKamar ?? ''}',
            fotoKamar:    booking.fotoKamar,
            periodeAwal:  booking.tglMulaiSewa,
            periodeAkhir: booking.tglAkhirSewa,
            totalTagihan: booking.tagihan!.totalTagihan,
            statusTagihan: booking.tagihan!.statusTagihan,
          ));
        }
      }

      allTagihan = result;
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

  void filterTagihan(String filter) {
    selectedFilter = filter;
    _applyFilter();
  }

  void _applyFilter() {
    switch (selectedFilter) {
      case 'Belum Bayar':
        filteredTagihan = allTagihan
            .where((t) => t.statusTagihan == 'belum_bayar')
            .toList();
        break;
      case 'Telat':
        filteredTagihan = allTagihan
            .where((t) => t.statusTagihan == 'terlambat')
            .toList();
        break;
      case 'Lunas':
        filteredTagihan = allTagihan
            .where((t) => t.statusTagihan == 'lunas')
            .toList();
        break;
      default:
        filteredTagihan = List.from(allTagihan);
    }
    onStateChanged();
  }

  // ── Bayar via Midtrans ─────────────────────────────────────
  Future<void> bayar(BuildContext context, TagihanUiModel tagihan) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
      ),
    );

    // Request snap token ke Laravel
    final result = await MidtransService.createSnapToken(tagihan.idTagihan);

    // Tutup loading
    if (context.mounted) Navigator.pop(context);
    if (!context.mounted) return;

    if (result['status'] == 'success') {
      final paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MidtransPage(
            snapUrl: result['snap_url'],
            orderId: result['order_id'],
          ),
        ),
      );

      if (!context.mounted) return;

      switch (paymentResult) {
        case 'success':
          _snack(context, '✅ Pembayaran berhasil!', const Color(0xFF2ECC71));
          await loadTagihan(); // Refresh list
          break;
        case 'pending':
          _snack(context, '⏳ Menunggu konfirmasi pembayaran',
              const Color(0xFFF39C12));
          break;
        case 'failed':
          _snack(context, '❌ Pembayaran gagal', Colors.red);
          break;
        case 'cancelled':
          _snack(context, 'Pembayaran dibatalkan', Colors.grey);
          break;
      }
    } else {
      _snack(
        context,
        result['message'] ?? 'Gagal memproses pembayaran',
        Colors.red,
      );
    }
  }

  // ── Format helpers ─────────────────────────────────────────
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
      return DateFormat('dd - MM - yyyy').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  void showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                color: Color(0xFFE74C3C),
                label: 'Telat - melewati jatuh tempo'),
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

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}