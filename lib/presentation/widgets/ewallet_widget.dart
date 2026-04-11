// ============================================================
// ewallet_widget.dart
// Widget instruksi GoPay / ShopeePay
// Letakkan di: lib/presentation/payment/widgets/ewallet_widget.dart
// ============================================================
import 'package:dkost/data/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
 
class EwalletWidget extends StatelessWidget {
  final EwalletPaymentResult result;
 
  const EwalletWidget({super.key, required this.result});
 
  bool get _isGopay => result.methodType == PaymentMethodType.gopay;
 
  Color get _color => _isGopay
      ? const Color(0xFF00AED6)
      : const Color(0xFFEE4D2D);
 
  String get _appName => _isGopay ? 'GoPay' : 'ShopeePay';
 
  String get _logoPath =>
      _isGopay ? 'assets/payment/gopay.png' : 'assets/payment/shopeepay.png';
 
  Future<void> _openApp() async {
    if (result.deeplinkUrl.isEmpty) return;
    final uri = Uri.parse(result.deeplinkUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Card utama ─────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo
              Image.asset(
                _logoPath,
                height: 48,
                errorBuilder: (_, __, ___) => Text(
                  _appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _color,
                  ),
                ),
              ),
              const SizedBox(height: 20),
 
              // Total
              Text(
                _formatRupiah(result.grossAmount),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Order: ${result.orderId}',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
              const SizedBox(height: 20),
 
              // Tombol buka app
              if (result.deeplinkUrl.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _openApp,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text('Bayar dengan $_appName'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
 
              // Atau via QR (jika ada)
              if (result.qrCodeUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau scan QR', style: TextStyle(fontSize: 12, color: Colors.black38)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    result.qrCodeUrl,
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.qr_code, size: 80, color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
 
        const SizedBox(height: 16),
 
        // ── Instruksi ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: _color),
                  const SizedBox(width: 6),
                  Text(
                    'Cara Pembayaran $_appName',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStep('1', 'Pastikan saldo $_appName kamu mencukupi'),
              _buildStep('2', 'Tekan tombol "Bayar dengan $_appName" di atas'),
              _buildStep('3', 'Aplikasi $_appName akan terbuka otomatis'),
              _buildStep('4', 'Konfirmasi pembayaran di aplikasi'),
              _buildStep('5', 'Kembali ke sini dan tekan "Cek Status"'),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
 
  String _formatRupiah(double amount) {
    final formatted = amount
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }
}