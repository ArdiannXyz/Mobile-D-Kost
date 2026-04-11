// ============================================================
// qris_widget.dart
// Widget instruksi QRIS
// Letakkan di: lib/presentation/payment/widgets/qris_widget.dart
// ============================================================
 
import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
 
class QrisWidget extends StatelessWidget {
  final QrisPaymentResult result;
 
  const QrisWidget({super.key, required this.result});
 
  @override
  Widget build(BuildContext context) {
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
 
              // QR Image
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: result.qrCodeUrl.isNotEmpty
                    ? Image.network(
                        result.qrCodeUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, __, ___) => const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Icon(Icons.qr_code, size: 80, color: Colors.grey),
                          ),
                        ),
                      )
                    : const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: Icon(Icons.qr_code, size: 80, color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
 
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
              // Supported apps
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
 
  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
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