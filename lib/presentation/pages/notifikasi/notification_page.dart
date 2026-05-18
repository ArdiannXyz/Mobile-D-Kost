// import 'package:flutter/material.dart';
// import '../../../data/models/notifikasi_model.dart';
// import 'notifikasi_manager.dart';

// class NotifikasiPage extends StatefulWidget {
//   const NotifikasiPage({super.key});

//   @override
//   State<NotifikasiPage> createState() => _NotifikasiPageState();
// }

// class _NotifikasiPageState extends State<NotifikasiPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final _manager = NotifikasiManager();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() => setState(() {}));

//     // Fetch notifikasi dari API
//     _manager.muat().then((_) {
//       if (mounted) setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _handleTap(NotifikasiItem item) async {
//     await _manager.tandaiDibaca(item.id);
//     setState(() {});

//     if (item.tipe == NotifikasiTipe.tagihan) {
//       Navigator.pop(context, 'tagihan');
//     } else if (item.tipe == NotifikasiTipe.keluhan) {
//       Navigator.pop(context, 'keluhan');
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: Column(
//         children: [
//           _buildAppBar(context, _manager.jumlahBelumDibaca),
//           Expanded(
//             child: _manager.isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF1BBA8A),
//                     ),
//                   )
//                 : _manager.errorMessage != null
//                     ? Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.wifi_off_rounded,
//                               size: 56,
//                               color: Color(0xFFB0B0C3),
//                             ),
//                             const SizedBox(height: 12),
//                             Text(
//                               _manager.errorMessage!,
//                               style: const TextStyle(
//                                 color: Color(0xFF9E9E9E),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: () {
//                                 _manager.muat().then((_) {
//                                   if (mounted) setState(() {});
//                                 });
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF1BBA8A),
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: const Text('Coba Lagi'),
//                             ),
//                           ],
//                         ),
//                       )
//                     : TabBarView(
//                         controller: _tabController,
//                         children: [
//                           _buildList(
//                             _manager.belumDibaca,
//                             isBelumDibaca: true,
//                           ),
//                           _buildList(
//                             _manager.sudahDibaca,
//                             isBelumDibaca: false,
//                           ),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar(BuildContext context, int belumDibacaCount) {
//     return Container(
//       color: const Color(0xFF1BBA8A),
//       child: SafeArea(
//         bottom: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const Expanded(
//                     child: Text(
//                       'Notifikasi',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   if (belumDibacaCount > 0)
//                     TextButton(
//                       onPressed: () async {
//                         await _manager.tandaiSemuaDibaca();
//                         if (mounted) setState(() {});
//                       },
//                       child: const Text(
//                         'Baca semua',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),
//                     )
//                   else
//                     const SizedBox(width: 48),
//                 ],
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
//               height: 44,
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   _buildTab(0, 'Belum dibaca', belumDibacaCount),
//                   _buildTab(1, 'Dibaca', null),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(int index, String label, int? badgeCount) {
//     final isActive = _tabController.index == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           _tabController.animateTo(index);
//           setState(() {});
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           margin: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: isActive ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(9),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: isActive
//                       ? const Color(0xFF1BBA8A)
//                       : Colors.white,
//                 ),
//               ),
//               if (badgeCount != null && badgeCount > 0) ...[
//                 const SizedBox(width: 6),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isActive
//                         ? const Color(0xFF1BBA8A)
//                         : Colors.white.withValues(alpha: 0.3),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     '$badgeCount',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildList(
//     List<NotifikasiItem> items, {
//     required bool isBelumDibaca,
//   }) {
//     if (items.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isBelumDibaca
//                   ? Icons.notifications_none_rounded
//                   : Icons.done_all_rounded,
//               size: 60,
//               color: const Color(0xFFB0B0C3),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               isBelumDibaca
//                   ? 'Tidak ada notifikasi baru'
//                   : 'Belum ada notifikasi dibaca',
//               style: const TextStyle(
//                 color: Color(0xFF9E9E9E),
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       color: const Color(0xFF1BBA8A),
//       onRefresh: () async {
//         await _manager.muat();
//         if (mounted) setState(() {});
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//         itemCount: items.length,
//         itemBuilder: (_, index) => _buildNotifCard(items[index]),
//       ),
//     );
//   }

//   Widget _buildNotifCard(NotifikasiItem item) {
//     return GestureDetector(
//       onTap: () => _handleTap(item),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: !item.sudahDibaca
//                 ? const Color(0xFF1BBA8A).withValues(alpha: 0.4)
//                 : const Color(0xFFE8E8E8),
//             width: 1.2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Icon tipe notifikasi ───────────────────────
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1BBA8A).withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 _getIcon(item.tipe),
//                 color: const Color(0xFF1BBA8A),
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 12),

//             // ── Judul & pesan ──────────────────────────────
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.judul,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: item.sudahDibaca
//                           ? FontWeight.w500
//                           : FontWeight.w700,
//                       color: const Color(0xFF1BBA8A),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     item.pesan,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF666666),
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   // ── Waktu ──────────────────────────────
//                   Text(
//                     _formatWaktu(item.waktu),
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: Color(0xFFB0B0C3),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Dot belum dibaca ──────────────────────────
//             if (!item.sudahDibaca) ...[
//               const SizedBox(width: 8),
//               Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.only(top: 4),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF1BBA8A),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getIcon(NotifikasiTipe tipe) {
//     switch (tipe) {
//       case NotifikasiTipe.tagihan:
//         return Icons.receipt_long_rounded;
//       case NotifikasiTipe.keluhan:
//         return Icons.person_outline_rounded;
//       case NotifikasiTipe.umum:
//         return Icons.notifications_outlined;
//     }
//   }

//   String _formatWaktu(DateTime waktu) {
//     final now = DateTime.now();
//     final diff = now.difference(waktu);

//     if (diff.inMinutes < 1) return 'Baru saja';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
//     if (diff.inHours < 24) return '${diff.inHours} jam lalu';
//     if (diff.inDays < 7) return '${diff.inDays} hari lalu';

//     return '${waktu.day}/${waktu.month}/${waktu.year}';
//   }
// }
