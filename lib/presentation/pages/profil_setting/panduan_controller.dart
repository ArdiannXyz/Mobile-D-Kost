// ============================================================
// BACKEND LAYER — panduan_controller.dart
// Bertanggung jawab atas: logika chatbot lokal D'Kost,
// parsing pesan user, generate respons bot.
//
// Yang DIHAPUS dari versi lama:
// - ProductService.sendMessage (API chatbot batik)
// - Quick replies batik (stok, bayar, resi, kontak, tentang)
// → Diganti konten relevan D'Kost
// ============================================================

import 'package:flutter/material.dart';

// Model pesan chat
class ChatMessageData {
  final String text;
  final bool isBot;
  final List<String>? steps;
  final String? content;
  final List<Map<String, dynamic>>? contacts;

  const ChatMessageData({
    required this.text,
    required this.isBot,
    this.steps,
    this.content,
    this.contacts,
  });
}

class PanduanController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  final List<ChatMessageData> messages = [];

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Quick replies sesuai D'Kost
  static const List<String> quickReplies = [
    'booking',
    'tagihan',
    'keluhan',
    'furnitur',
    'kontak',
    'tentang',
  ];

  final VoidCallback onStateChanged;

  PanduanController({required this.onStateChanged});

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
  }

  // ── Init: pesan sambutan ───────────────────────────────────
  void init() {
    _addBotMessage(
      'Halo! Saya asisten D\'Kost yang siap membantu Anda.',
      content:
          'Anda bisa bertanya tentang:\n\n'
          '• Cara booking kamar\n'
          '• Cara cek & bayar tagihan\n'
          '• Cara lapor keluhan\n'
          '• Informasi furnitur tambahan\n'
          '• Kontak & informasi D\'Kost',
    );
  }

  // ── Kirim Pesan ────────────────────────────────────────────
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _addUserMessage(message);
    messageController.clear();

    isLoading = true;
    onStateChanged();

    // Simulasi delay respons bot
    await Future.delayed(const Duration(milliseconds: 600));

    final response = _generateResponse(message.toLowerCase().trim());
    _addBotMessage(
      response['text'] as String,
      steps: response['steps'] as List<String>?,
      content: response['content'] as String?,
      contacts: response['contacts'] as List<Map<String, dynamic>>?,
    );

    isLoading = false;
    onStateChanged();
  }

  // ── Generate Respons Bot (lokal, tanpa API) ────────────────
  Map<String, dynamic> _generateResponse(String query) {
    // Booking kamar
    if (query.contains('booking') || query.contains('pesan') ||
        query.contains('kamar') || query.contains('sewa')) {
      return {
        'text': 'Berikut cara memesan kamar di D\'Kost:',
        'steps': [
          'Buka halaman Dashboard dan pilih kamar yang diinginkan',
          'Tap tombol "Learn more" untuk melihat detail kamar',
          'Pilih durasi sewa (1–12 bulan) dari dropdown',
          'Tambahkan furnitur tambahan jika diperlukan',
          'Tap "Pesan Sekarang" dan konfirmasi pemesanan',
          'Lakukan pembayaran sesuai tagihan yang dikirimkan',
        ],
      };
    }

    // Tagihan & pembayaran
    if (query.contains('tagihan') || query.contains('bayar') ||
        query.contains('pembayaran') || query.contains('cicil')) {
      return {
        'text': 'Informasi tagihan dan pembayaran D\'Kost:',
        'steps': [
          'Buka menu "Riwayat Kos" di bottom navigation',
          'Pilih booking aktif Anda',
          'Tap "Lihat Tagihan" untuk melihat detail tagihan bulanan',
          'Pilih metode pembayaran yang tersedia',
          'Selesaikan pembayaran sebelum tanggal jatuh tempo',
          'Konfirmasi pembayaran akan dikirim via notifikasi',
        ],
      };
    }

    // Keluhan
    if (query.contains('keluhan') || query.contains('lapor') ||
        query.contains('masalah') || query.contains('rusak')) {
      return {
        'text': 'Cara melaporkan keluhan di D\'Kost:',
        'steps': [
          'Tap ikon "Keluhan" di bottom navigation',
          'Tap tombol "Lapor keluhan" di pojok kanan atas',
          'Nomor kamar akan terisi otomatis',
          'Isi tanggal lapor dan deskripsi masalah dengan jelas',
          'Unggah foto bukti jika ada (opsional)',
          'Tap "Laporkan" dan konfirmasi pengiriman',
          'Status keluhan dapat dipantau di daftar keluhan',
        ],
      };
    }

    // Furnitur
    if (query.contains('furnitur') || query.contains('furniture') ||
        query.contains('tambah') || query.contains('lemari') ||
        query.contains('kasur') || query.contains('meja')) {
      return {
        'text': 'Informasi furnitur tambahan D\'Kost:',
        'steps': [
          'Furnitur tambahan dapat dipilih saat proses pemesanan kamar',
          'Buka detail kamar dan tap "Pesan Sekarang"',
          'Di bagian "Penambahan Furnitur", pilih item yang diinginkan',
          'Gunakan tombol + dan − untuk mengatur jumlah',
          'Total biaya furnitur akan otomatis terhitung',
          'Biaya furnitur dihitung per bulan sesuai durasi sewa',
        ],
      };
    }

    // Kontak
    if (query.contains('kontak') || query.contains('hubungi') ||
        query.contains('nomor') || query.contains('telpon') ||
        query.contains('admin') || query.contains('cs')) {
      return {
        'text': 'Informasi kontak D\'Kost:',
        'contacts': [
          {
            'name': 'Admin D\'Kost',
            'phone': '+62 812 3456 7890',
            'email': 'admin@dkost.com',
            'hours': 'Senin–Jumat, 08.00–17.00 WIB',
          },
          {
            'name': 'Customer Service',
            'phone': '+62 811 9876 5432',
            'email': 'cs@dkost.com',
            'hours': 'Setiap hari, 07.00–21.00 WIB',
          },
        ],
      };
    }

    // Tentang D'Kost
    if (query.contains('tentang') || query.contains('dkost') ||
        query.contains('aplikasi') || query.contains('info')) {
      return {
        'text': 'Tentang D\'Kost',
        'content':
            'D\'Kost adalah aplikasi manajemen kost digital yang memudahkan penyewa dalam:\n\n'
            '• Mencari dan memesan kamar kost\n'
            '• Mengelola tagihan bulanan\n'
            '• Melaporkan keluhan fasilitas\n'
            '• Memberikan ulasan kamar\n\n'
            'Versi: 1.0.0\n'
            'Dikembangkan untuk kemudahan penyewa kost.',
      };
    }

    // Menu / help
    if (query.contains('menu') || query.contains('help') ||
        query.contains('bantuan') || query.contains('panduan')) {
      return {
        'text': 'Pilih topik yang ingin Anda ketahui:',
        'content':
            '• booking  — Cara memesan kamar\n'
            '• tagihan  — Cara cek & bayar tagihan\n'
            '• keluhan  — Cara lapor masalah\n'
            '• furnitur — Info furnitur tambahan\n'
            '• kontak   — Hubungi admin\n'
            '• tentang  — Info aplikasi D\'Kost',
      };
    }

    // Default
    return {
      'text':
          'Maaf, saya belum mengerti pertanyaan Anda. Silakan ketik salah satu topik: '
          'booking, tagihan, keluhan, furnitur, kontak, atau tentang.',
    };
  }

  // ── Helper: tambah pesan ───────────────────────────────────
  void _addBotMessage(
    String text, {
    List<String>? steps,
    String? content,
    List<Map<String, dynamic>>? contacts,
  }) {
    messages.add(ChatMessageData(
      text: text,
      isBot: true,
      steps: steps,
      content: content,
      contacts: contacts,
    ));
    onStateChanged();
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    messages.add(ChatMessageData(text: text, isBot: false));
    onStateChanged();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void goBack(BuildContext context) => Navigator.pop(context);
}