// ============================================================
// va_widget.dart
// Widget instruksi Virtual Account (BCA, BNI, BRI, Mandiri)
// Letakkan di: lib/presentation/payment/widgets/va_widget.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/payment_model.dart';

class VaWidget extends StatelessWidget {
  final VaPaymentResult result;

  const VaWidget({super.key, required this.result});

  // ── Warna per bank ─────────────────────────────────────────
  Color get _bankColor {
    switch (result.bank.toLowerCase()) {
      case 'bca':     return const Color(0xFF0066AE);
      case 'bni':     return const Color(0xFFFF6600);
      case 'bri':     return const Color(0xFF1A7ECB);
      case 'mandiri': return const Color(0xFF003D79);
      default:        return const Color(0xFF2563EB);
    }
  }

  String get _bankName => result.bank.toUpperCase();

  // ── Instruksi ATM per bank ─────────────────────────────────
  List<String> get _instruksiAtm {
    switch (result.bank.toLowerCase()) {
      case 'bca':
        return [
          'Masukkan kartu ATM dan PIN BCA kamu',
          'Pilih menu "Transaksi Lainnya"',
          'Pilih "Transfer" → "BCA Virtual Account"',
          'Masukkan nomor Virtual Account di atas',
          'Periksa nominal dan konfirmasi pembayaran',
        ];
      case 'bni':
        return [
          'Masukkan kartu ATM dan PIN BNI kamu',
          'Pilih menu "Transfer"',
          'Pilih "Virtual Account Billing"',
          'Masukkan nomor Virtual Account di atas',
          'Periksa tagihan dan konfirmasi pembayaran',
        ];
      case 'bri':
        return [
          'Masukkan kartu ATM dan PIN BRI kamu',
          'Pilih menu "Transaksi Lain"',
          'Pilih "Pembayaran" → "BRIVA"',
          'Masukkan nomor Virtual Account di atas',
          'Periksa informasi dan konfirmasi pembayaran',
        ];
      case 'mandiri':
        return [
          'Masukkan kartu ATM dan PIN Mandiri kamu',
          'Pilih menu "Bayar/Beli"',
          'Pilih "Lainnya" → "Multi Payment"',
          'Masukkan kode perusahaan dan nomor VA',
          'Konfirmasi dan selesaikan pembayaran',
        ];
      default:
        return ['Lakukan transfer ke nomor Virtual Account di atas'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card VA Number ─────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo bank (atau text fallback)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _bankColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/banks/${result.bank}.png',
                  height: 36,
                  errorBuilder: (_, __, ___) => Text(
                    _bankName,
                    style: TextStyle(
                      color: _bankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Nomor Virtual Account',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
              const SizedBox(height: 8),

              // VA Number + tombol salin
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result.vaNumber,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _bankColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CopyButton(text: result.vaNumber),
                ],
              ),
              const SizedBox(height: 16),

              // Total bayar
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

        // ── Instruksi ATM ──────────────────────────────────
        _InstructionCard(
          title: 'Cara Bayar via ATM $_bankName',
          icon: Icons.atm,
          steps: _instruksiAtm,
        ),

        const SizedBox(height: 12),

        // ── Instruksi m-banking ────────────────────────────
        _InstructionCard(
          title: 'Cara Bayar via Mobile Banking',
          icon: Icons.phone_android,
          steps: [
            'Buka aplikasi mobile banking $_bankName',
            'Login dengan username dan password kamu',
            'Pilih menu "Transfer" atau "Pembayaran"',
            'Pilih "Virtual Account" dan masukkan nomor VA',
            'Periksa detail dan konfirmasi pembayaran',
          ],
        ),
      ],
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

// ── Widget: Tombol salin ───────────────────────────────────
class _CopyButton extends StatefulWidget {
  final String text;
  const _CopyButton({required this.text});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _copied
              ? const Color(0xFF22C55E).withOpacity(0.1)
              : const Color(0xFF2563EB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check : Icons.copy,
              size: 14,
              color: _copied ? const Color(0xFF22C55E) : const Color(0xFF2563EB),
            ),
            const SizedBox(width: 4),
            Text(
              _copied ? 'Tersalin' : 'Salin',
              style: TextStyle(
                fontSize: 12,
                color: _copied ? const Color(0xFF22C55E) : const Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Card instruksi ─────────────────────────────────
class _InstructionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> steps;

  const _InstructionCard({
    required this.title,
    required this.icon,
    required this.steps,
  });

  @override
  State<_InstructionCard> createState() => _InstructionCardState();
}

class _InstructionCardState extends State<_InstructionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (bisa di-tap untuk expand)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Steps (collapsible)
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}