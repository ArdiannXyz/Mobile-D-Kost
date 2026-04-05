// // ============================================================
// // FRONTEND LAYER — chatbot_page.dart
// // Chatbot AI Sinora untuk D'Kost
// // Style: hijau 0xFF2ECC71, sesuai design system D'Kost
// // ============================================================

// import 'package:flutter/material.dart';
// import 'chatbot_controller.dart';
// import '../../../data/models/chatbot_model.dart';

// class ChatbotPage extends StatefulWidget {
//   const ChatbotPage({super.key});

//   @override
//   State<ChatbotPage> createState() => _ChatbotPageState();
// }

// class _ChatbotPageState extends State<ChatbotPage> {
//   late final ChatbotController _controller;
//   final _textController   = TextEditingController();
//   final _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _controller = ChatbotController(
//       onStateChanged: () {
//         if (mounted) {
//           setState(() {});
//           _scrollToBottom();
//         }
//       },
//     );
//     _controller.init();
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(child: _buildMessageList()),
//           _buildQuickReplies(),
//           _buildInputBar(),
//         ],
//       ),
//     );
//   }

//   // ── Header (sama style dengan SettingPage) ─────────────────
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Color(0xFF2ECC71),
//         borderRadius: BorderRadius.only(
//           bottomLeft:  Radius.circular(18),
//           bottomRight: Radius.circular(18),
//         ),
//       ),
//       padding: EdgeInsets.only(
//         top:    MediaQuery.of(context).padding.top + 12,
//         bottom: 16,
//         left:   16,
//         right:  16,
//       ),
//       child: Row(
//         children: [
//           // Tombol back
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: const Icon(Icons.arrow_back_ios_new,
//                 color: Colors.white, size: 20),
//           ),
//           const SizedBox(width: 12),

//           // Avatar bot
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ClipOval(
//               child: Image.asset(
//                 'assets/images/sinora_icon.png',
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const Icon(
//                   Icons.smart_toy_rounded,
//                   color: Color(0xFF2ECC71),
//                   size: 26,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Nama & status
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Sinora',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Container(
//                       width: 7,
//                       height: 7,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFB9F6CA),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       _controller.isTyping ? 'Sedang mengetik...' : 'Online',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Message List ───────────────────────────────────────────
//   Widget _buildMessageList() {
//     if (_controller.messages.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
//       );
//     }

//     return ListView.builder(
//       controller:  _scrollController,
//       padding:     const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       itemCount:   _controller.messages.length,
//       itemBuilder: (context, index) {
//         final msg = _controller.messages[index];
//         return _buildBubble(msg);
//       },
//     );
//   }

//   Widget _buildBubble(ChatMessage msg) {
//     final isUser = msg.isUser;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // Avatar bot (kiri)
//           if (!isUser) ...[
//             Container(
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF2ECC71),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.smart_toy_rounded,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//             const SizedBox(width: 8),
//           ],

//           // Bubble
//           Flexible(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.72,
//               ),
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isUser
//                     ? const Color(0xFF2ECC71)
//                     : Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft:     const Radius.circular(16),
//                   topRight:    const Radius.circular(16),
//                   bottomLeft:  Radius.circular(isUser ? 16 : 4),
//                   bottomRight: Radius.circular(isUser ? 4  : 16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: msg.isLoading
//                   ? _buildTypingIndicator()
//                   : _buildBubbleContent(msg, isUser),
//             ),
//           ),

//           // Space kanan untuk bot (biar simetris)
//           if (!isUser) const SizedBox(width: 38),
//         ],
//       ),
//     );
//   }

//   Widget _buildBubbleContent(ChatMessage msg, bool isUser) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Teks utama
//         Text(
//           msg.text,
//           style: TextStyle(
//             color: isUser ? Colors.white : const Color(0xFF1A1A2E),
//             fontSize: 14,
//             height: 1.4,
//           ),
//         ),

//         // Data dari DB (list kamar, harga, dll)
//         if (msg.dataList != null && msg.dataList!.isNotEmpty) ...[
//           const SizedBox(height: 8),
//           ...msg.dataList!.map((item) => _buildDataItem(item, isUser)),
//         ],

//         // Timestamp
//         const SizedBox(height: 4),
//         Align(
//           alignment: Alignment.bottomRight,
//           child: Text(
//             msg.timeStr,
//             style: TextStyle(
//               fontSize: 10,
//               color: isUser
//                   ? Colors.white.withOpacity(0.7)
//                   : const Color(0xFFB0B0C3),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDataItem(Map<String, dynamic> item, bool isUser) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: isUser
//             ? Colors.white.withOpacity(0.2)
//             : const Color(0xFFF0FFF4),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isUser
//               ? Colors.white.withOpacity(0.3)
//               : const Color(0xFF2ECC71).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: item.entries.map((e) {
//           return Text(
//             '${_formatKey(e.key)}: ${e.value}',
//             style: TextStyle(
//               fontSize: 12,
//               color: isUser ? Colors.white : const Color(0xFF2D3436),
//               height: 1.5,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   String _formatKey(String key) {
//     const map = {
//       'nomor'     : '🏠 Kamar',
//       'tipe'      : '📋 Tipe',
//       'harga'     : '💰 Harga',
//       'fasilitas' : '✨ Fasilitas',
//       'rating'    : '⭐ Rating',
//       'komentar'  : '💬 Komentar',
//       'tanggal'   : '📅 Tanggal',
//       'nama'      : '🛋️ Nama',
//       'jumlah'    : '📦 Jumlah',
//       'biaya'     : '💵 Biaya',
//     };
//     return map[key] ?? key;
//   }

//   Widget _buildTypingIndicator() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: List.generate(3, (i) {
//         return AnimatedContainer(
//           duration: Duration(milliseconds: 400 + (i * 150)),
//           curve: Curves.easeInOut,
//           margin: const EdgeInsets.symmetric(horizontal: 2),
//           width: 7,
//           height: 7,
//           decoration: BoxDecoration(
//             color: const Color(0xFF2ECC71).withOpacity(0.6),
//             shape: BoxShape.circle,
//           ),
//         );
//       }),
//     );
//   }

//   // ── Quick Reply Buttons (sesuai screenshot Sinora) ─────────
//   Widget _buildQuickReplies() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: _controller.quickReplies.map((qr) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: GestureDetector(
//                 onTap: () {
//                   _sendMessage(qr['message']!);
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2ECC71),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     qr['label']!,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   // ── Input Bar ──────────────────────────────────────────────
//   Widget _buildInputBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.fromLTRB(
//         16, 8, 16,
//         MediaQuery.of(context).padding.bottom + 12,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller:  _textController,
//               enabled:     !_controller.isTyping,
//               maxLength:   500,
//               buildCounter: (_, {required currentLength,
//                   required isFocused, maxLength}) => null,
//               decoration: InputDecoration(
//                 hintText:       'Tulis Pesan....',
//                 hintStyle:      const TextStyle(
//                     color: Color(0xFFB0B0C3), fontSize: 14),
//                 border:         OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide:   BorderSide.none,
//                 ),
//                 filled:         true,
//                 fillColor:      const Color(0xFFF5F7FA),
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 18, vertical: 10),
//               ),
//               onSubmitted: (_) => _sendMessage(_textController.text),
//             ),
//           ),
//           const SizedBox(width: 8),

//           // Tombol kirim
//           GestureDetector(
//             onTap: _controller.isTyping
//                 ? null
//                 : () => _sendMessage(_textController.text),
//             child: Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: _controller.isTyping
//                     ? const Color(0xFFB0B0C3)
//                     : const Color(0xFF2ECC71),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF2ECC71).withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.send_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Helpers ────────────────────────────────────────────────
//   void _sendMessage(String text) {
//     if (text.trim().isEmpty || _controller.isTyping) return;
//     _textController.clear();
//     _controller.sendMessage(text.trim());
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve:    Curves.easeOut,
//         );
//       }
//     });
//   }
// }

// ============================================================
// FRONTEND LAYER — chatbot_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'chatbot_controller.dart';
import '../../../data/models/chatbot_model.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late final ChatbotController _controller;
  final _textController   = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatbotController(
      onStateChanged: () {
        if (mounted) {
          setState(() {});
          _scrollToBottom();
        }
      },
    );
    _controller.init();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      padding: EdgeInsets.only(
        top:    MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left:   16,
        right:  16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // ── Avatar pakai sinora_icon.png ──────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sinora_icon.png', // ← sinora_icon.png
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF2ECC71),
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sinora',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB9F6CA),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _controller.isTyping ? 'Sedang mengetik...' : 'Online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Message List ───────────────────────────────────────────
  Widget _buildMessageList() {
    if (_controller.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
      );
    }

    return ListView.builder(
      controller:  _scrollController,
      padding:     const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount:   _controller.messages.length,
      itemBuilder: (context, index) {
        return _buildBubble(_controller.messages[index]);
      },
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar bot pakai sinora_icon.png
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/sinora_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF2ECC71),
                    child: const Icon(Icons.smart_toy_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF2ECC71) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: msg.isLoading
                  ? _buildTypingIndicator()
                  : _buildBubbleContent(msg, isUser),
            ),
          ),

          if (!isUser) const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(ChatMessage msg, bool isUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        if (msg.dataList != null && msg.dataList!.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...msg.dataList!.map((item) => _buildDataItem(item, isUser)),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            msg.timeStr,
            style: TextStyle(
              fontSize: 10,
              color: isUser
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFFB0B0C3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataItem(Map<String, dynamic> item, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withOpacity(0.2)
            : const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUser
              ? Colors.white.withOpacity(0.3)
              : const Color(0xFF2ECC71).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: item.entries.map((e) {
          return Text(
            '${_formatKey(e.key)}: ${e.value}',
            style: TextStyle(
              fontSize: 12,
              color: isUser ? Colors.white : const Color(0xFF2D3436),
              height: 1.5,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatKey(String key) {
    const map = {
      'nomor'     : '🏠 Kamar',
      'tipe'      : '📋 Tipe',
      'harga'     : '💰 Harga',
      'fasilitas' : '✨ Fasilitas',
      'rating'    : '⭐ Rating',
      'komentar'  : '💬 Komentar',
      'tanggal'   : '📅 Tanggal',
      'nama'      : '🛋️ Nama',
      'jumlah'    : '📦 Jumlah',
      'biaya'     : '💵 Biaya',
    };
    return map[key] ?? key;
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + (i * 150)),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  // ── Quick Reply — style pill hijau seperti gambar ──────────
  Widget _buildQuickReplies() {
    return Container(
      color: const Color(0xFFF5F7FA), // ← background abu muda
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _controller.quickReplies.map((qr) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _sendMessage(qr['message']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(24), // ← pill shape
                  ),
                  child: Text(
                    qr['label']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Input Bar — send icon transparan seperti gambar ────────
  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16, 8, 16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: TextField(
                controller:  _textController,
                enabled:     !_controller.isTyping,
                maxLength:   500,
                buildCounter: (_, {required currentLength,
                    required isFocused, maxLength}) => null,
                decoration: const InputDecoration(
                  hintText:       'Tulis Pesan....',
                  hintStyle:      TextStyle(
                      color: Color(0xFFB0B0C3), fontSize: 14),
                  border:         InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(_textController.text),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Tombol kirim — icon send tanpa lingkaran ──────
          GestureDetector(
            onTap: _controller.isTyping
                ? null
                : () => _sendMessage(_textController.text),
            child: Icon(
              Icons.send_rounded,  // ← icon send saja, tidak pakai Container
              color: _controller.isTyping
                  ? const Color(0xFFB0B0C3)
                  : const Color(0xFF2ECC71),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  void _sendMessage(String text) {
    if (text.trim().isEmpty || _controller.isTyping) return;
    _textController.clear();
    _controller.sendMessage(text.trim());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }
}