// ============================================================
// FRONTEND LAYER — pembayaran_status_page.dart
// Halaman hasil setelah pembayaran Midtrans selesai
// ============================================================

import 'package:flutter/material.dart';

class PembayaranStatusPage extends StatelessWidget {
  const PembayaranStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;

    final status    = args['status'] as String? ?? 'unknown';
    final orderId   = args['order_id'] as String? ?? '-';
    final namaKamar = args['nama_kamar'] as String? ?? 'Kamar Kost';
    final total     = (args['total'] as num?)?.toDouble() ?? 0;

    final isSuccess = status == 'settlement' || status == 'capture';
    final isPending = status == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Status Icon ────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFFE8F5E9)
                      : isPending
                          ? const Color(0xFFFFF8E1)
                          : const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess
                      ? Icons.check_circle_outline_rounded
                      : isPending
                          ? Icons.access_time_rounded
                          : Icons.cancel_outlined,
                  size: 56,
                  color: isSuccess
                      ? const Color(0xFF2ECC71)
                      : isPending
                          ? const Color(0xFFF39C12)
                          : const Color(0xFFE74C3C),
                ),
              ),

              const SizedBox(height: 24),

              // ── Status Text ────────────────────────────
              Text(
                isSuccess
                    ? 'Pembayaran Berhasil!'
                    : isPending
                        ? 'Menunggu Pembayaran'
                        : 'Pembayaran Gagal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? const Color(0xFF2ECC71)
                      : isPending
                          ? const Color(0xFFF39C12)
                          : const Color(0xFFE74C3C),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                isSuccess
                    ? 'Booking kamu telah dikonfirmasi.\nSelamat menikmati kamar kost!'
                    : isPending
                        ? 'Selesaikan pembayaran sesuai\ninstruksi yang diberikan.'
                        : 'Pembayaran tidak berhasil diproses.\nSilakan coba lagi.',
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                    height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ── Detail ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow('Kamar', namaKamar),
                    const Divider(height: 20),
                    _buildRow('Order ID', orderId),
                    const Divider(height: 20),
                    _buildRow('Total', _formatHarga(total)),
                    const Divider(height: 20),
                    _buildRow(
                      'Status',
                      isSuccess
                          ? 'Lunas'
                          : isPending
                              ? 'Pending'
                              : 'Gagal',
                      valueColor: isSuccess
                          ? const Color(0xFF2ECC71)
                          : isPending
                              ? const Color(0xFFF39C12)
                              : const Color(0xFFE74C3C),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Tombol ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke home dan clear semua stack
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess
                        ? const Color(0xFF2ECC71)
                        : isPending
                            ? const Color(0xFFF39C12)
                            : const Color(0xFF9E9E9E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    isSuccess ? 'Kembali ke Beranda' : 'Kembali ke Beranda',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              if (!isSuccess && !isPending) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2ECC71),
                      side: const BorderSide(color: Color(0xFF2ECC71)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Coba Bayar Lagi',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9E9E9E))),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatHarga(double harga) {
    if (harga >= 1000000) {
      return 'Rp ${(harga / 1000000).toStringAsFixed(0)}.000.000';
    } else if (harga >= 1000) {
      return 'Rp ${(harga / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp ${harga.toStringAsFixed(0)}';
  }
}