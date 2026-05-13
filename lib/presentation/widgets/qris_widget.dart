// ============================================================
// qris_widget.dart
// Widget instruksi QRIS — QR generate lokal pakai qr_flutter
// Letakkan di: lib/presentation/payment/widgets/qris_widget.dart
// ============================================================
 
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../../../data/models/payment_model.dart';
 
class QrisWidget extends StatefulWidget {
  final QrisPaymentResult result;
 
  const QrisWidget({super.key, required this.result});

  @override
  State<QrisWidget> createState() => _QrisWidgetState();
}

class _QrisWidgetState extends State<QrisWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  Future<void> _downloadQr() async {
    setState(() => _isSaving = true);
    try {
      // Capture screenshot
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes != null) {
        // Save to gallery using gal
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan QR Code: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return Column(
      children: [
        // ── Card QR Code ───────────────────────────────────
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
              // Logo QRIS
              Image.asset(
                'assets/payment/qris.png',
                height: 32,
                errorBuilder: (_, __, ___) => const Text(
                  'QRIS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE31E26),
                  ),
                ),
              ),
              const SizedBox(height: 16),
 
              // ── QR Code ────────────────────────────────────
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQrCode(result.qrString),
                      const SizedBox(height: 8),
                      const Text(
                        'QRIS PAYMENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Download
              TextButton.icon(
                onPressed: _isSaving ? null : _downloadQr,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2563EB),
                        ),
                      )
                    : const Icon(Icons.download_rounded, size: 20),
                label: Text(_isSaving ? 'Menyimpan...' : 'Download QR Code'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
 
              Text(
                'Scan QR di atas menggunakan\naplikasi e-wallet atau m-banking apapun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
 
              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(result.grossAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
 
        const SizedBox(height: 16),
 
        // ── Cara penggunaan ────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 6),
                  Text(
                    'Cara Pembayaran QRIS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStep('1', 'Buka aplikasi e-wallet atau m-banking kamu'),
              _buildStep('2', 'Pilih menu "Scan QR" atau "Pay"'),
              _buildStep('3', 'Arahkan kamera ke QR Code di atas'),
              _buildStep('4', 'Periksa nominal dan konfirmasi pembayaran'),
              _buildStep('5', 'Pembayaran akan terkonfirmasi otomatis'),
              const SizedBox(height: 12),
              Text(
                'Didukung oleh: GoPay, OVO, DANA, ShopeePay, LinkAja, semua m-banking',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  // ── Generate QR dari qrString (lokal, tidak butuh internet) ─
  Widget _buildQrCode(String qrString) {
    // Prioritas: qrString (generate lokal) → fallback placeholder
    if (qrString.isNotEmpty) {
      return QrImageView(
        data           : qrString,
        version        : QrVersions.auto,
        size           : 200,
        eyeStyle       : const QrEyeStyle(
          eyeShape : QrEyeShape.square,
          color    : Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color          : Colors.black,
        ),
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );
    }
 
    // Fallback jika qrString kosong
    return const SizedBox(
      width : 200,
      height: 200,
      child : Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'QR tidak tersedia',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width : 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color     : Colors.white,
                  fontSize  : 10,
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