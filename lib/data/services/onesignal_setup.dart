import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notifikasi_service.dart';

class OneSignalSetup {
  static const String _appId = '2a99cc5f-1669-4a7d-913a-ffc2cb9cd6a2';

  // ── Panggil di main.dart sebelum runApp() ─────────────────
  static Future<void> init() async {
    // Log verbose (hapus saat release/production)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Inisialisasi dengan App ID
    OneSignal.initialize(_appId);

    // Minta izin notifikasi dari user
    await OneSignal.Notifications.requestPermission(true);

    // Handler saat notifikasi masuk & app sedang terbuka (foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display(); // tetap tampilkan notifikasi
    });

    // Handler saat user tap notifikasi
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null) {
        debugPrint('Notifikasi di-tap: $data');
        // navigasi bisa ditambahkan di sini sesuai kebutuhan
        // contoh: navigatorKey.currentState?.pushNamed('/notifikasi');
      }
    });

    debugPrint('OneSignal berhasil diinisialisasi');
  }

  // ── Panggil setelah login berhasil & token sudah disimpan ─
  static Future<void> kirimPlayerIdKeBackend() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;

      debugPrint('=== ONESIGNAL DEBUG ===');
      debugPrint('Token: ${NotifikasiService.authToken}');
      debugPrint('Player ID: $playerId');

      if (playerId == null || playerId.isEmpty) {
        debugPrint('OneSignal: Player ID belum tersedia');
        return;
      }

      debugPrint('OneSignal Player ID: $playerId');

      final berhasil = await NotifikasiService.simpanPlayerId(playerId);
      debugPrint('Kirim Player ID berhasil: $berhasil');
      debugPrint('======================');

      if (berhasil) {
        debugPrint('OneSignal: Player ID berhasil disimpan ke backend');
      } else {
        debugPrint('OneSignal: Gagal simpan Player ID ke backend');
      }
    } catch (e) {
      debugPrint('OneSignalSetup.kirimPlayerIdKeBackend error: $e');
    }
  }
}
