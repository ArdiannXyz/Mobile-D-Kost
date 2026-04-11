// ============================================================
// payment_instruction_page.dart
// Router dinamis → tampilkan widget sesuai metode
// Letakkan di: lib/presentation/payment/payment_instruction_page.dart
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/services/payment_service.dart';
import '../../widgets/va_widget.dart';
import '../../widgets/qris_widget.dart';
import '../../widgets/ewallet_widget.dart';

class PaymentInstructionPage extends StatefulWidget {
  final PaymentResult result;
  final int idTagihan;

  const PaymentInstructionPage({
    super.key,
    required this.result,
    required this.idTagihan,
  });

  @override
  State<PaymentInstructionPage> createState() =>
      _PaymentInstructionPageState();
}

class _PaymentInstructionPageState extends State<PaymentInstructionPage> {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  bool _isCheckingStatus = false;
  String _paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.result.timeRemaining;
    _startCountdown();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Countdown timer ────────────────────────────────────────
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final rem = widget.result.expiredAt.difference(DateTime.now());
      setState(() {
        _timeRemaining = rem.isNegative ? Duration.zero : rem;
      });
      if (_timeRemaining == Duration.zero) {
        _countdownTimer?.cancel();
        _pollingTimer?.cancel();
        setState(() => _paymentStatus = 'expire');
      }
    });
  }

  // ── Polling status setiap 5 detik ─────────────────────────
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);

    try {
      final status = await PaymentService.checkStatus(widget.idTagihan);
      if (!mounted) return;

      setState(() {
        _paymentStatus = status;
        _isCheckingStatus = false;
      });

      if (status == 'settlement' || status == 'capture') {
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();
        _showSuccessDialog();
      } else if (status == 'deny' || status == 'cancel' || status == 'expire') {
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();
      }
    } catch (_) {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tagihan kamu sudah lunas.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();          // tutup dialog
                Navigator.of(context).pop('success'); // kembali ke halaman tagihan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Selesai', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Instruksi Pembayaran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Status bar ─────────────────────────────────────
          if (_paymentStatus == 'expire' || _paymentStatus == 'cancel' ||
              _paymentStatus == 'deny')
            _StatusBanner(status: _paymentStatus)
          else if (_paymentStatus == 'settlement')
            _StatusBanner(status: _paymentStatus),

          // ── Konten dinamis sesuai metode ───────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildInstructionWidget(),
            ),
          ),

          // ── Footer: countdown + tombol cek status ──────────
          _PaymentFooter(
            timeRemaining    : _timeRemaining,
            isCheckingStatus : _isCheckingStatus,
            onCekStatus      : _checkStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionWidget() {
    final result = widget.result;

    if (result is VaPaymentResult) {
      return VaWidget(result: result);
    } else if (result is QrisPaymentResult) {
      return QrisWidget(result: result);
    } else if (result is EwalletPaymentResult) {
      return EwalletWidget(result: result);
    }

    return const Center(child: Text('Metode tidak dikenal'));
  }
}

// ── Widget: Status banner ──────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String message;

    switch (status) {
      case 'settlement':
        color   = const Color(0xFF22C55E);
        icon    = Icons.check_circle;
        message = 'Pembayaran berhasil!';
        break;
      case 'expire':
        color   = Colors.orange;
        icon    = Icons.timer_off;
        message = 'Waktu pembayaran habis.';
        break;
      default:
        color   = Colors.red;
        icon    = Icons.cancel;
        message = 'Pembayaran dibatalkan.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Widget: Footer countdown + tombol ─────────────────────
class _PaymentFooter extends StatelessWidget {
  final Duration timeRemaining;
  final bool isCheckingStatus;
  final VoidCallback onCekStatus;

  const _PaymentFooter({
    required this.timeRemaining,
    required this.isCheckingStatus,
    required this.onCekStatus,
  });

  String _formatDuration(Duration d) {
    final h  = d.inHours.toString().padLeft(2, '0');
    final m  = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s  = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = timeRemaining == Duration.zero;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: isExpired ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                isExpired
                    ? 'Waktu habis'
                    : 'Bayar dalam ${_formatDuration(timeRemaining)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isExpired ? Colors.red : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tombol cek status
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isCheckingStatus ? null : onCekStatus,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isCheckingStatus
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : const Text('Cek Status Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}