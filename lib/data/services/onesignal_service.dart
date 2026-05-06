// // lib/data/services/onesignal_service.dart
// //
// // Setup OneSignal:
// //   - foreground listener  → tampilkan InAppNotifOverlay popup
// //   - background/click     → sudah ditangani OS (push biasa)
// //   - login user           → set externalId ke backend

// import 'package:flutter/material.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import '../../data/models/notifikasi_model.dart';
// import '../../../presentation/pages/notifikasi/notifikasi_manager.dart';
// import '../../../presentation/widgets/in_app_notif_overlay.dart';
// import 'notifikasi_api_service.dart';
// import 'package:dkost/presentation/widgets/in_app_notif_overlay.dart';

// class OneSignalService {
//   static final OneSignalService _instance = OneSignalService._internal();
//   factory OneSignalService() => _instance;
//   OneSignalService._internal();

//   final _manager = NotifikasiManager();

//   // ── Init: panggil sekali di main() ────────────────────────
//   Future<void> init() async {
//     // Ganti dengan App ID OneSignal kamu
//     OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');

//     // Minta permission notifikasi
//     await OneSignal.Notifications.requestPermission(true);

//     // ── Foreground listener: tampilkan in-app popup ─────────
//     OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//       // Biarkan notifikasi tetap tampil sebagai push juga
//       event.preventDefault();
//       event.notification.display();

//       // Buat NotifikasiItem dari payload
//       final item = _notifFromPayload(event.notification);
//       if (item != null) {
//         // Update badge counter
//         _manager.tambah(item);
//         // Tampilkan popup in-app
//         InAppNotifOverlay.show(item);
//       }
//     });

//     // ── Click listener: navigasi berdasarkan tipe ──────────
//     OneSignal.Notifications.addClickListener((event) {
//       final data = event.notification.additionalData;
//       if (data != null) {
//         final tipe = data['tipe'] as String?;
//         debugPrint('OneSignal click tipe: $tipe');
//         // Navigasi ditangani oleh handler di main_page atau home_page
//         // Gunakan GlobalKey<NavigatorState> atau event bus jika perlu
//       }
//     });
//   }

//   // ── Set external ID setelah login ─────────────────────────
//   Future<void> loginUser(int userId) async {
//     final externalId = 'dkost_$userId';
//     OneSignal.login(externalId);

//     // Sinkron ke backend supaya subscription terasosiasi
//     try {
//       final subscriptionId = OneSignal.User.pushSubscription.id;
//       if (subscriptionId != null) {
//       }
//     } catch (e) {
//       debugPrint('OneSignal loginUser error: $e');
//     }

//     debugPrint('OneSignal login: $externalId');
//   }

//   // ── Logout (saat user sign out) ───────────────────────────
//   void logoutUser() {
//     OneSignal.logout();
//   }

//   // ── Parse payload OneSignal ke NotifikasiItem ─────────────
//   NotifikasiItem? _notifFromPayload(OSNotification notif) {
//     try {
//       final data = notif.additionalData ?? {};
//       final tipeStr = data['tipe'] as String? ?? 'umum';
//       final notifId = int.tryParse(data['notifId'] as String? ?? '') ?? 0;

//       return NotifikasiItem(
//         id: notifId,
//         judul: notif.title ?? 'Notifikasi',
//         pesan: notif.body ?? '',
//         tipe: _parseTipe(tipeStr),
//         sudahDibaca: false,
//         waktu: DateTime.now(),
//       );
//     } catch (e) {
//       debugPrint('_notifFromPayload error: $e');
//       return null;
//     }
//   }

//   NotifikasiTipe _parseTipe(String tipe) {
//     switch (tipe) {
//       case 'tagihan':
//         return NotifikasiTipe.tagihan;
//       case 'keluhan':
//         return NotifikasiTipe.keluhan;
//       default:
//         return NotifikasiTipe.umum;
//     }
//   }
// }
