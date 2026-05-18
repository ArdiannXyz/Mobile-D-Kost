// ============================================================
// BACKEND LAYER — chatbot_controller.dart
// Bertanggung jawab: kirim pesan, terima respons, rate limit UI
// ============================================================

import 'dart:convert';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dkost/data/helper/api_constants.dart';
import '../../../data/models/chatbot_model.dart';

class ChatbotController {
  // ── State ──────────────────────────────────────────────────
  final List<ChatMessage> messages = [];
  bool isTyping = false;
  final List<Map<String, String>> _history = []; // ← TAMBAH INI

  final VoidCallback onStateChanged;

  // Quick reply sesuai screenshot Sinora
  final List<Map<String, String>> quickReplies = [
    {'label': 'Keluhan',  'message': 'Bagaimana cara menyampaikan keluhan?'},
    {'label': 'Booking',  'message': 'Bagaimana cara booking kamar?'},
    {'label': 'Tagihan',  'message': 'Bagaimana cara cek tagihan?'},
    {'label': 'Review',   'message': 'Tampilkan review kos ini'},
  ];

  // User ID dari session
  String _userId = 'guest';

  ChatbotController({required this.onStateChanged});

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    // Ambil user ID dari session yang sudah ada di D'Kost
    final id = await ApiHelper.getUserId();
    _userId = id?.toString() ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // Pesan sambutan
    messages.add(ChatMessage(
      text:   'Halo aku Sinora yang siap bantu pertanyaanmu! 😊',
      isUser: false,
    ));

    onStateChanged();
  }

  // ── Kirim Pesan ────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isTyping) return;

    // Tambah bubble user
    messages.add(ChatMessage(text: text, isUser: true));

    // Tambah bubble loading (typing indicator)
    messages.add(ChatMessage(
      text:      '',
      isUser:    false,
      isLoading: true,
    ));

    isTyping = true;
    onStateChanged();

    try {
      final response = await _callApi(text);
      _handleResponse(response);
    } catch (e) {
      _handleError();
    }
  }

  // ── Call Laravel API ───────────────────────────────────────
Future<Map<String, dynamic>> _callApi(String message) async {
    final headers = await ApiHelper.authHeaders;
    final url = '${ApiConstants.baseUrl}chatbot/chat';
    
    debugPrint('=== SINORA URL: $url ==='); // ← tambah ini
    debugPrint('=== BODY: ${jsonEncode({'message': message, 'user_id': _userId})} ===');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        'message': message,
        'user_id': _userId,
        'history': _history,
      }),
    ).timeout(const Duration(seconds: 15));

    debugPrint('=== RESPONSE STATUS: ${response.statusCode} ==='); // ← tambah ini
    debugPrint('=== RESPONSE BODY: ${response.body} ==='); // ← tambah ini

    return jsonDecode(response.body) as Map<String, dynamic>;
}
  // ── Handle Response ────────────────────────────────────────
// SESUDAH
  void _handleResponse(Map<String, dynamic> res) {
      messages.removeWhere((m) => m.isLoading);
      isTyping = false;

      // Handle rate limit
      if (res['success'] == false && res['type'] == 'rate_limited') {
        final seconds = res['retry_after'] ?? 60;
        messages.add(ChatMessage(
          text:   'Terlalu banyak pesan nih 😅 Tunggu $seconds detik ya!',
          isUser: false,
          type:   'rate_limited',
        ));
        onStateChanged();
        return;
      }

      final rawData = res['data'];
      final String? type = res['type'] as String?;
      final String replyText = res['message'] ?? 'Maaf, ada kesalahan 🙏';

      // ── FIX 1: Simpan ke history agar percakapan nyambung ──
      // Ambil pesan user terakhir dari messages
      final lastUserMsg = messages.lastWhere(
        (m) => m.isUser,
        orElse: () => ChatMessage(text: '', isUser: true),
      );
      _history.add({'role': 'user',  'text': lastUserMsg.text});
      _history.add({'role': 'model', 'text': replyText});

      // Batasi history maksimal 10 pesan (5 bolak-balik)
      if (_history.length > 10) {
        _history.removeRange(0, _history.length - 10);
      }

      // ── FIX 2: Card kamar muncul untuk semua intent yang punya data kamar ──
      List<Map<String, dynamic>>? kamarList;
      List<Map<String, dynamic>>? dataList;

      // Intent yang menampilkan card kamar
      const kamarIntents = {'cek_kamar_tersedia', 'cek_kamar_review'};

      if (rawData is List && rawData.isNotEmpty) {
        final parsed = rawData.whereType<Map<String, dynamic>>().toList();

        // Cek apakah data mengandung field kamar
        final isKamarData = parsed.first.containsKey('id_kamar') ||
                            parsed.first.containsKey('nomor_kamar');

        if (kamarIntents.contains(type) || isKamarData) {
          kamarList = parsed; // tampilkan sebagai card
        } else {
          dataList = parsed;  // tampilkan sebagai list teks
        }
      }

      messages.add(ChatMessage(
        text:      replyText,
        isUser:    false,
        dataList:  dataList,
        kamarList: kamarList,
        type:      type,
        fromCache: res['from_cache'] ?? false,
      ));

      onStateChanged();
  }

  void goToKamarDetail(BuildContext context, int kamarId) {
    Navigator.pushNamed(context, '/kamar-detail', arguments: {'id': kamarId});
  }

  // ── Handle Error ───────────────────────────────────────────
  void _handleError() {
    messages.removeWhere((m) => m.isLoading);
    isTyping = false;

    messages.add(ChatMessage(
      text:   'Koneksi bermasalah, coba lagi ya 🙏',
      isUser: false,
    ));

    onStateChanged();
  }
}