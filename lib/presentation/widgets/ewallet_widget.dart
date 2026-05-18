// ============================================================
// ewallet_widget.dart
// Widget instruksi GoPay / ShopeePay
// Letakkan di: lib/presentation/payment/widgets/ewallet_widget.dart
// ============================================================
import 'package:dkost/data/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

class EwalletWidget extends StatefulWidget {
  final EwalletPaymentResult result;

  const EwalletWidget({super.key, required this.result});

  @override
  State<EwalletWidget> createState() => _EwalletWidgetState();
}

class _EwalletWidgetState extends State<EwalletWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;
 
  bool get _isGopay => widget.result.methodType == PaymentMethodType.gopay;

  Color get _color => _isGopay ? const Color(0xFF00AED6) : const Color(0xFFEE4D2D);

  String get _appName => _isGopay ? 'GoPay' : 'ShopeePay';

  String get _logoPath => _isGopay ? 'assets/payment/gopay.png' : 'assets/payment/shopeepay.png';

  Future<void> _openApp() async {
    final url = widget.result.deeplinkUrl;
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      // Mode externalApplication lebih paksa untuk buka app luar
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!launched && mounted) {
        _showError('Tidak dapat membuka aplikasi $_appName. Pastikan aplikasi sudah terinstal.');
      }
    } catch (e) {
      if (mounted) _showError('Gagal membuka $_appName: $e');
    }
  }

  Future<void> _downloadQr() async {
    if (widget.result.qrCodeUrl.isEmpty) return;
    
    setState(() => _isSaving = true);
    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes != null) {
        await Gal.putImageBytes(imageBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code berhasil disimpan ke galeri'),
              backgroundColor: Color(0xFF1BBA8A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) _showError('Gagal menyimpan QR Code: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
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
                _formatRupiah(widget.result.grossAmount),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Order: ${widget.result.orderId}',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
              const SizedBox(height: 20),
 
              // Tombol buka app
              if (widget.result.deeplinkUrl.isNotEmpty)
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
              if (widget.result.qrCodeUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau scan QR',
                          style: TextStyle(fontSize: 12, color: Colors.black38)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      widget.result.qrCodeUrl,
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.qr_code, size: 80, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _isSaving ? null : _downloadQr,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2563EB),
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Download QR'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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