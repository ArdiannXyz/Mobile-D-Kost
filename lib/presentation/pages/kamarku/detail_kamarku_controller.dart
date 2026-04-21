// ============================================================
// FILE: lib/presentation/pages/kamarku/detail_kamarku_controller.dart
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/services/furnitur_service.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/helper/api_constants.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/models/booking_models.dart';
import '../../../data/models/kamar_models.dart';
import '../../../data/models/furnitur_models.dart';
import '../../../data/services/kamar_service.dart';
// Tambah import ini di bagian atas file
import '../pembayaran/pembayaran_instruksi_page.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/services/payment_service.dart';

// ── Controller: Detail Kamarku ────────────────────────────────
class DetailKamarkuController {
  bool isLoading    = true;
  bool isSubmitting = false;
  String? errorMessage;
  BookingModel? booking;
  final int bookingId;
  final VoidCallback onStateChanged;

  // ── Timer countdown ────────────────────────────────────────
  Timer?   _countdownTimer;
  Duration remainingTime = Duration.zero;
  bool get isExpired => remainingTime.inSeconds <= 0;

  DetailKamarkuController({
    required this.bookingId,
    required this.onStateChanged,
  });

  Future<void> loadDetail() async {
    isLoading    = true;
    errorMessage = null;
    onStateChanged();
    try {
      booking = await BookingService.getBookingDetail(bookingId);
      if (booking == null) {
        errorMessage = 'Data booking tidak ditemukan.';
      } else {
        try {
          final kamar = await KamarService.getKamarDetail(booking!.idKamar);
          if (kamar?.fotoPrimary != null) {
            booking = BookingModel(
              idBooking        : booking!.idBooking,
              idUser           : booking!.idUser,
              idKamar          : booking!.idKamar,
              tglBooking       : booking!.tglBooking,
              expiredAt        : booking!.expiredAt,
              durasiSewaBulan  : booking!.durasiSewaBulan,
              tglMulaiSewa     : booking!.tglMulaiSewa,
              tglAkhirSewa     : booking!.tglAkhirSewa,
              totalBiayaBulanan: booking!.totalBiayaBulanan,
              statusBooking    : booking!.statusBooking,
              nomorKamar       : booking!.nomorKamar,
              tipeKamar        : booking!.tipeKamar,
              fotoKamar        : kamar!.fotoPrimary,
              furniturList     : booking!.furniturList,
              tagihan          : booking!.tagihan,
            );
          }
        } catch (_) {}
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat detail booking.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Timer countdown ────────────────────────────────────────
  void startCountdown(VoidCallback onExpired) {
    final b = booking;
    if (b == null || b.statusBooking != 'menunggu_pembayaran') return;

    final expiredAt = b.expiredAt;
    if (expiredAt == null) return;

    remainingTime = expiredAt.difference(DateTime.now());

    if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
      remainingTime = Duration.zero;
      onStateChanged();
      onExpired();
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remainingTime -= const Duration(seconds: 1);
      onStateChanged();
      if (remainingTime.inSeconds <= 0) {
        remainingTime = Duration.zero;
        _countdownTimer?.cancel();
        onExpired();
      }
    });
  }

  void stopCountdown() => _countdownTimer?.cancel();

  String get countdownText {
    if (isExpired) return '00:00:00';
    final h = remainingTime.inHours.toString().padLeft(2, '0');
    final m = (remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final s = (remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color get countdownColor {
    if (isExpired || remainingTime.inSeconds < 60) return const Color(0xFFE74C3C);
    if (remainingTime.inMinutes < 5)               return const Color(0xFFF39C12);
    return const Color(0xFF2ECC71);
  }

  // ── Batalkan booking ───────────────────────────────────────
Future<void> batalBooking(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Batalkan Booking?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: const Text(
            'Booking akan dibatalkan dan kamar kembali tersedia.',
            style: TextStyle(fontSize: 13)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BBA8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      final headers  = await ApiHelper.authHeaders;
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}booking/$bookingId/batal'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (!context.mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        _snack(context, 'Booking berhasil dibatalkan.', const Color(0xFF2ECC71));
        Navigator.pop(context, true);
      } else {
        _snack(context, data['message'] ?? 'Gagal membatalkan booking.', Colors.red);
      }
    } catch (e) {
      if (context.mounted) _snack(context, 'Terjadi kesalahan: $e', Colors.red);
    }
  }

  // ══════════════════════════════════════════════════════════
  // FITUR B: TAMBAH FURNITUR MID-SEWA
  // ══════════════════════════════════════════════════════════
  Future<void> showTambahFurniturDialog(BuildContext context) async {
    List<FurniturModel> furniturList = [];
    try {
      furniturList = await FurniturService.getFurniturList();
    } catch (_) {
      if (context.mounted) {
        _snack(context, 'Gagal memuat daftar furnitur.', Colors.red);
      }
      return;
    }

    // Filter hanya furnitur yang stoknya > 0
    final furniturTersedia = furniturList.where((f) => f.jumlah > 0).toList();

    if (!context.mounted) return;

    if (furniturTersedia.isEmpty) {
      _snack(context, 'Tidak ada furnitur yang tersedia saat ini.', Colors.orange);
      return;
    }

    await showModalBottomSheet(
      context           : context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TambahFurniturSheet(
        furniturList: furniturTersedia,
        onKonfirmasi: (Map<int, int> dipilih) async {
          Navigator.pop(ctx);
          await _submitTambahFurnitur(context, dipilih);
        },
      ),
    );
  }

  Future<void> _submitTambahFurnitur(
      BuildContext context, Map<int, int> furnitur) async {
    if (furnitur.isEmpty) return;

    isSubmitting = true;
    onStateChanged();

    try {
      final result = await BookingService.tambahFurnitur(
        idBooking: bookingId,
        furnitur : furnitur,
      );

      if (!context.mounted) return;

      _snack(
        context,
        'Furnitur berhasil ditambahkan! +${formatHarga((result['data']['total_tambahan_biaya'] as num).toDouble())}',
        const Color(0xFF2ECC71),
      );

      await loadDetail();
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message, Colors.red);
    } catch (e) {
      if (context.mounted) _snack(context, 'Terjadi kesalahan: $e', Colors.red);
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  // ══════════════════════════════════════════════════════════
  // FITUR C: AKHIRI SEWA SEKARANG
  // ══════════════════════════════════════════════════════════
  Future<void> akhiriSewa(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Akhiri Sewa?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Kamar akan langsung dikembalikan dan menjadi tersedia. '
          'Tagihan bulan depan yang belum dibayar akan dibatalkan.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak',
                style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Ya, Akhiri Sekarang'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    isSubmitting = true;
    onStateChanged();

    try {
      await BookingService.akhiriSewa(bookingId);

      if (!context.mounted) return;
      _snack(context, 'Sewa berhasil diakhiri. Kamar kembali tersedia.',
          const Color(0xFF2ECC71));
      Navigator.pop(context, 'selesai');
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message, Colors.red);
    } catch (e) {
      if (context.mounted) _snack(context, 'Terjadi kesalahan: $e', Colors.red);
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  // ── Kalkulasi ──────────────────────────────────────────────
  double get totalFurnitur =>
      booking?.furniturList.fold(0.0, (sum, f) => sum! + f.subtotal) ?? 0;

  double get totalBiaya => booking?.totalBiayaBulanan ?? 0;

  // ── Format helpers ─────────────────────────────────────────
  String formatHarga(double harga) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0)
        .format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d/M/yyyy').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return 'Menunggu Pembayaran';
      case 'aktif':               return 'Aktif';
      case 'selesai':             return 'Selesai';
      case 'batal':               return 'Dibatalkan';
      case 'expired':             return 'Kadaluarsa';
      default:                    return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return const Color(0xFFF39C12);
      case 'aktif':               return const Color(0xFF2ECC71);
      case 'selesai':             return const Color(0xFF3498DB);
      case 'batal':               return const Color(0xFFE74C3C);
      case 'expired':             return const Color(0xFF9E9E9E);
      default:                    return const Color(0xFF9E9E9E);
    }
  }

// Ganti method goToPayment yang lama
// Hapus _showPilihMetode dari controller
// Ubah goToPayment jadi terima parameter onNeedMethod

void goToPayment(
  BuildContext context, {
  required int idTagihan,
  required double totalBayar,
  required String namaKamar,
  required Future<PaymentMethodType?> Function() onNeedMethod, // ← tambah ini
}) async {
  isSubmitting = true;
  onStateChanged();

  try {
    PaymentResult paymentResult;

    try {
      paymentResult = await PaymentService.getExistingPayment(idTagihan);
    } on ApiException catch (e) {
      if (e.message == 'no_previous_method') {
        isSubmitting = false;
        onStateChanged();

        final method = await onNeedMethod(); // ← panggil dari page
        if (method == null || !context.mounted) return;

        isSubmitting = true;
        onStateChanged();

        paymentResult = await PaymentService.createPayment(
          idTagihan: idTagihan,
          method   : method,
        );
      } else {
        rethrow;
      }
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentInstructionPage(
          result    : paymentResult,
          idTagihan : idTagihan,
        ),
      ),
    ).then((_) async {
      await loadDetail();
    });
  } on ApiException catch (e) {
    if (context.mounted) _snack(context, e.message, Colors.red);
  } catch (e) {
    if (context.mounted) _snack(context, 'Gagal memuat pembayaran: $e', Colors.red);
  } finally {
    isSubmitting = false;
    onStateChanged();
  }
}



  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content        : Text(msg),
      backgroundColor: color,
      behavior       : SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin         : const EdgeInsets.all(16),
    ));
  }

  void goBack(BuildContext context) => Navigator.pop(context);
  Future<void> refresh() => loadDetail();
}

// ══════════════════════════════════════════════════════════════
// WIDGET: Bottom Sheet Tambah Furnitur
// ══════════════════════════════════════════════════════════════
class _TambahFurniturSheet extends StatefulWidget {
  final List<FurniturModel> furniturList;
  final void Function(Map<int, int>) onKonfirmasi;

  const _TambahFurniturSheet({
    required this.furniturList,
    required this.onKonfirmasi,
  });

  @override
  State<_TambahFurniturSheet> createState() => _TambahFurniturSheetState();
}

class _TambahFurniturSheetState extends State<_TambahFurniturSheet> {
  final Map<int, int> _selected = {};

  double get _total {
    double t = 0;
    for (final e in _selected.entries) {
      final f = widget.furniturList.firstWhere(
        (f) => f.idFurnitur == e.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '', jumlah: 0, hargaSewaTambahan: 0),
      );
      t += f.hargaSewaTambahan * e.value;
    }
    return t;
  }

  String _fmt(double v) => NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0)
      .format(v);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize    : 0.95,
      minChildSize    : 0.4,
      expand          : false,
      builder: (_, scrollController) => Column(
        children: [
          // ── Handle bar ─────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width : 40,
            height: 4,
            decoration: BoxDecoration(
              color       : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Tambah Furnitur',
                    style: TextStyle(
                        fontSize  : 16,
                        fontWeight: FontWeight.bold,
                        color     : Color(0xFF1A1A2E))),
                const Spacer(),
                IconButton(
                  icon     : const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color    : const Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── List furnitur ───────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding   : const EdgeInsets.all(16),
              itemCount : widget.furniturList.length,
              itemBuilder: (_, i) {
                final f      = widget.furniturList[i];
                final qty    = _selected[f.idFurnitur] ?? 0;
                final stok   = f.jumlah; // stok tersedia
                final habis  = stok <= 0;

                return Opacity(
                  opacity: habis ? 0.5 : 1.0,
                  child: Container(
                    margin   : const EdgeInsets.only(bottom: 10),
                    padding  : const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color       : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: qty > 0
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE0E0E0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                            color     : Color(0x08000000),
                            blurRadius: 4,
                            offset    : Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ── Icon furnitur ──────────────────────
                        Container(
                          width : 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color       : habis
                                ? const Color(0xFFF5F5F5)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.chair_outlined,
                              color: habis
                                  ? const Color(0xFFBDBDBD)
                                  : const Color(0xFF2ECC71),
                              size: 22),
                        ),
                        const SizedBox(width: 12),

                        // ── Nama + harga + stok ────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.namaFurnitur,
                                  style: const TextStyle(
                                      fontSize  : 13,
                                      fontWeight: FontWeight.w600,
                                      color     : Color(0xFF1A1A2E))),
                              const SizedBox(height: 2),
                              Text('${_fmt(f.hargaSewaTambahan)}/bln',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color   : Color(0xFF9E9E9E))),
                              const SizedBox(height: 2),
                              // ── Info stok tersedia ─────────────
                              Row(
                                children: [
                                  Icon(
                                    habis
                                        ? Icons.do_not_disturb_alt_outlined
                                        : Icons.inventory_2_outlined,
                                    size : 11,
                                    color: habis
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFF2ECC71),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    habis
                                        ? 'Stok habis'
                                        : 'Tersedia: $stok',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color   : habis
                                          ? const Color(0xFFE74C3C)
                                          : const Color(0xFF2ECC71),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Qty counter ────────────────────────
                        Row(
                          children: [
                            _QtyBtn(
                              icon: Icons.remove,
                              onPressed: qty > 0
                                  ? () => setState(() {
                                        if (qty == 1) {
                                          _selected.remove(f.idFurnitur);
                                        } else {
                                          _selected[f.idFurnitur] = qty - 1;
                                        }
                                      })
                                  : null,
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                qty.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize  : 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            _QtyBtn(
                              icon: Icons.add,
                              // Batasi maksimum sesuai stok tersedia
                              onPressed: (!habis && qty < stok)
                                  ? () => setState(
                                        () => _selected[f.idFurnitur] = qty + 1,
                                      )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Bottom bar total + tombol konfirmasi ────────────
          Container(
            padding: EdgeInsets.only(
              left  : 16,
              right : 16,
              top   : 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color     : Color(0x15000000),
                    blurRadius: 8,
                    offset    : Offset(0, -3)),
              ],
            ),
            child: Row(
              children: [
                if (_total > 0) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize      : MainAxisSize.min,
                    children: [
                      const Text('Tambahan/bln:',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9E9E9E))),
                      Text(_fmt(_total),
                          style: const TextStyle(
                              fontSize  : 14,
                              fontWeight: FontWeight.bold,
                              color     : Color(0xFF1A1A2E))),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () => widget.onKonfirmasi(_selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor        : const Color(0xFF2ECC71),
                        disabledBackgroundColor: const Color(0xFFBDBDBD),
                        foregroundColor        : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Tambahkan',
                          style: TextStyle(
                              fontSize  : 15,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData      icon;
  final VoidCallback? onPressed;
  const _QtyBtn({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap       : onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width : 28,
        height: 28,
        decoration: BoxDecoration(
          color       : onPressed != null
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size : 16,
            color: onPressed != null
                ? const Color(0xFF2ECC71)
                : const Color(0xFFBDBDBD)),
      ),
    );
  }
}

// ── Controller: Checkout (Buat Pesanan) ──────────────────────
class CheckoutController {
  bool isSubmitting = false;
  final KamarModel kamar;
  final int durasiSewa;
  final Map<int, int> selectedFurnitur;
  final List<FurniturModel> furniturList;
  final String tglMulaiSewa;
  final VoidCallback onStateChanged;

  CheckoutController({
    required this.kamar,
    required this.durasiSewa,
    required this.selectedFurnitur,
    required this.furniturList,
    required this.tglMulaiSewa,
    required this.onStateChanged,
  });

  double get totalKamar => kamar.hargaPerBulan * durasiSewa;

  double get totalFurnitur {
    double total = 0;
    for (final entry in selectedFurnitur.entries) {
      final f = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '', jumlah: 0, hargaSewaTambahan: 0),
      );
      total += f.hargaSewaTambahan * entry.value * durasiSewa;
    }
    return total;
  }

  double get totalPembayaran => totalKamar + totalFurnitur;

  List<_FurniturCheckoutItem> get furniturItems {
    return selectedFurnitur.entries.map((entry) {
      final f = furniturList.firstWhere(
        (f) => f.idFurnitur == entry.key,
        orElse: () => FurniturModel(
            idFurnitur: 0, namaFurnitur: '-', jumlah: 0, hargaSewaTambahan: 0),
      );
      return _FurniturCheckoutItem(
        nama    : f.namaFurnitur,
        jumlah  : entry.value,
        harga   : f.hargaSewaTambahan,
        subtotal: f.hargaSewaTambahan * entry.value * durasiSewa,
      );
    }).toList();
  }

  Future<void> buatPesanan(BuildContext context) async {
    isSubmitting = true;
    onStateChanged();

    try {
      final result = await BookingService.createBooking(
        idKamar         : kamar.idKamar,
        tglMulaiSewa    : tglMulaiSewa,
        durasiSewaBulan : durasiSewa,
        selectedFurnitur: selectedFurnitur,
      );

      if (!context.mounted) return;

      if (result['success'] == true) {
        final idBooking  = result['data']['id_booking'] as int?;
        final idTagihan  = result['data']['id_tagihan'] as int;
        final totalBayar = (result['data']['total_biaya'] as num).toDouble();
        final namaKamar  = 'Kos ${_cap(kamar.tipeKamar)} ${kamar.nomorKamar}';

        final expiredAtRaw = result['data']['expired_at'] as String?;
        final expiredAtDt  = expiredAtRaw != null
            ? DateTime.tryParse(expiredAtRaw)?.toLocal()
            : null;

        _showSuccess(context, 'Booking berhasil dibuat!');

        Navigator.pushReplacementNamed(
          context,
          '/pembayaran',
          arguments: {
            'id_booking' : idBooking,
            'id_tagihan' : idTagihan,
            'total_biaya': totalBayar,
            'nama_kamar' : namaKamar,
            'expired_at' : expiredAtDt,
          },
        );
      } else {
        _showError(context, result['message'] ?? 'Gagal membuat booking.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e.message);
    } catch (_) {
      if (context.mounted) _showError(context, 'Terjadi kesalahan. Coba lagi.');
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }

  String formatHarga(double harga) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0)
        .format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d/M/yyyy').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  String get tglAkhirSewa {
    try {
      final tglMulai = DateTime.parse(tglMulaiSewa);
      final tglAkhir =
          DateTime(tglMulai.year, tglMulai.month + durasiSewa, tglMulai.day);
      return DateFormat('d/M/yyyy').format(tglAkhir);
    } catch (_) {
      return '-';
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void goBack(BuildContext context) => Navigator.pop(context);

  void _showSuccess(BuildContext ctx, String msg) =>
      _snack(ctx, msg, const Color(0xFF2ECC71));
  void _showError(BuildContext ctx, String msg) =>
      _snack(ctx, msg, Colors.red);
  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content        : Text(msg),
      backgroundColor: color,
      behavior       : SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin         : const EdgeInsets.all(16),
    ));
  }
}

class _FurniturCheckoutItem {
  final String nama;
  final int    jumlah;
  final double harga;
  final double subtotal;
  const _FurniturCheckoutItem({
    required this.nama,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
  });
}