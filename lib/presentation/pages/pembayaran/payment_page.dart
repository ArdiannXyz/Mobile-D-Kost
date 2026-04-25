// ============================================================
// FILE: lib/presentation/payment/payment_page.dart  
// Redirector — untuk backward compatibility route lama
// ============================================================

import 'package:flutter/material.dart';
import '../pembayaran/pembayaran_instruksi_page.dart';
import '../../../data/models/payment_model.dart';

/// Wrapper lama — langsung forward ke PaymentInstructionPage.
/// Gunakan ini hanya jika masih ada Navigator.pushNamed('/payment', ...)
/// di tempat lain yang belum diupdate.
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>?;

    // Jika dipanggil tanpa args yang benar, balik saja
    if (args == null ||
        args['result'] == null ||
        args['id_tagihan'] == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran')),
        body: const Center(
          child: Text('Data pembayaran tidak ditemukan.'),
        ),
      );
    }

    // Forward ke halaman baru
    return PaymentInstructionPage(
      result    : args['result'] as PaymentResult,
      idTagihan : args['id_tagihan'] as int,
    );
  }
}