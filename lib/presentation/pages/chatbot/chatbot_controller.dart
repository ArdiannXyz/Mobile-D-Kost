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
    final headers = await ApiHelper.authHeaders; // pakai token yang sudah login

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}chatbot/chat'), // ← pakai ApiConstants
    headers: headers,
    body: jsonEncode({
      'message': message,
      'user_id': _userId,
    }),
  ).timeout(const Duration(seconds: 15));

  return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Handle Response ────────────────────────────────────────
  void _handleResponse(Map<String, dynamic> res) {
    messages.removeWhere((m) => m.isLoading);
    isTyping = false;

    if (res['success'] == false && res['type'] == 'rate_limited') {
      final seconds = res['retry_after'] ?? 60;
      messages.add(ChatMessage(
        text: 'Terlalu banyak pesan nih 😅 Tunggu $seconds detik ya!',
        isUser: false,
        type: 'rate_limited',
      ));
      onStateChanged();
      return;
      
    }

  // ── Parse dataList biasa ──────────────────────────────────
  List<Map<String, dynamic>>? dataList;
  final rawData = res['data'];
  if (rawData is List && rawData.isNotEmpty) {
    dataList = rawData.whereType<Map<String, dynamic>>().toList();
  }

    List<Map<String, dynamic>>? kamarList;
    if (res['type'] == 'cek_kamar_tersedia' && rawData is List && rawData.isNotEmpty) {
      kamarList = rawData.whereType<Map<String, dynamic>>().toList();
      dataList = null; // jangan render sebagai dataList teks biasa
    }
      print('=== FULL RESPONSE ===');
      print(res.keys.toList());      // lihat semua field yang ada
      print(jsonEncode(res));        // lihat full JSON
      print('====================');

    messages.add(ChatMessage(
      text: res['message'] ?? 'Maaf, ada kesalahan 🙏',
      isUser: false,
      dataList: dataList,
      kamarList: kamarList,  // ← TAMBAH INI
      type: res['type'],
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