// ============================================================
// FRONTEND LAYER — payment_page.dart
// Menggunakan url_launcher (support Flutter Web & Mobile)
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dkost/data/services/pembayaran_service.dart';
import 'package:dkost/data/helper/api_exception.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading        = true;
  bool _isPaymentLoading = false;
  String? _snapToken;
  String? _errorMessage;

  late int    _idTagihan;
  late double _totalBiaya;
  late String _namaKamar;
  bool _argsInitialized = false;

  String get _snapUrl =>
      'https://app.sandbox.midtrans.com/snap/v2/vtweb/$_snapToken';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsInitialized) {
      _argsInitialized = true;
      final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
      _idTagihan  = args['id_tagihan'] as int;
      _totalBiaya = (args['total_biaya'] as num).toDouble();
      _namaKamar  = args['nama_kamar'] as String? ?? 'Kamar';
      _getSnapToken();
    }
  }

  Future<void> _getSnapToken() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final result = await PembayaranService.createPembayaran(_idTagihan);
      if (result['success'] == true) {
        setState(() {
          _snapToken = result['data']['snap_token'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading    = false;
          _errorMessage = result['message'] ?? 'Gagal membuat pembayaran.';
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = e.message; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Error: $e'; });
    }
  }

Future<void> _bayarSekarang() async {
  if (_snapToken == null) return;
  setState(() => _isPaymentLoading = true);
  final uri = Uri.parse(_snapUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);

    // ← Setelah kembali dari Midtrans, langsung ke home
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa membuka halaman pembayaran.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  if (mounted) setState(() => _isPaymentLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A2E), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pembayaran',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),
      bottomNavigationBar:
          (!_isLoading && _errorMessage == null) ? _buildBottomBar() : null,
    );
  }

  Widget _buildLoading() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2ECC71)),
            SizedBox(height: 16),
            Text('Menyiapkan pembayaran...',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 56, color: Color(0xFFB0B0C3)),
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF9E9E9E), fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getSnapToken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payment_outlined,
                      color: Color(0xFF2ECC71), size: 36),
                ),
                const SizedBox(height: 16),
                Text(_namaKamar,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Total Tagihan',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 4),
                Text(_formatHarga(_totalBiaya),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metode Pembayaran Tersedia',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 12),
                _buildPaymentMethod(Icons.account_balance_outlined,
                    'Virtual Account', 'BCA, BNI, BRI, Mandiri, dll'),
                _buildPaymentMethod(Icons.qr_code_outlined,
                    'QRIS', 'Semua aplikasi dompet digital'),
                _buildPaymentMethod(
                    Icons.account_balance_wallet_outlined,
                    'GoPay', 'Bayar dengan saldo GoPay'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB7EAC8)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.open_in_new_outlined,
                    size: 16, color: Color(0xFF2ECC71)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kamu akan diarahkan ke halaman pembayaran Midtrans yang aman.',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF2ECC71), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomBar() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(
              color: Color(0x15000000), blurRadius: 12, offset: Offset(0, -3))],
        ),
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_snapToken != null && !_isPaymentLoading)
                ? _bayarSekarang : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              disabledBackgroundColor: const Color(0xFF2ECC71).withOpacity(0.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isPaymentLoading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Bayar Sekarang',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      );

  Widget _buildCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: child,
      );

  Widget _buildPaymentMethod(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2ECC71), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
                Text(subtitle, style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHarga(double harga) {
    final parts = harga.toStringAsFixed(0).split('');
    String result = '';
    int counter = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) result = '.$result';
      result = parts[i] + result;
      counter++;
    }
    return 'Rp $result';
  }
}