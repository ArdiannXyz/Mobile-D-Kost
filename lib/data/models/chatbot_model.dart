// ============================================================
// MODEL — chatbot_model.dart
// ============================================================

class ChatMessage {
  final String text;
  final bool   isUser;
  final bool   isLoading;
  final List<Map<String, dynamic>>? dataList;
  final List<Map<String, dynamic>>? kamarList; // ← TAMBAH INI
  final String? type;
  final bool   fromCache;
  final DateTime createdAt;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.dataList,
    this.kamarList, // ← TAMBAH INI
    this.type,
    this.fromCache = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get timeStr {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}