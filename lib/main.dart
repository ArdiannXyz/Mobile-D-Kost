import 'package:dkost/presentation/pages/home/detail_kamar_page.dart';
import 'presentation/pages/home/search_page.dart';
import 'package:dkost/presentation/pages/review_keluhan/lapor_keluhan_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';                          
import 'data/helper/api_helper.dart';
import 'presentation/pages/kamar/kamarku_page.dart';
import 'data/services/midtrans_service.dart';

// ── Auth ───────────────────────────────────────────────────────
import 'presentation/pages/auth/welcome_screen.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/auth/lupa_password_page.dart';
import 'presentation/pages/auth/masuk_otp_page.dart';
import 'presentation/pages/auth/ganti_password_page.dart';

// ── Home ───────────────────────────────────────────────────────
import 'presentation/pages/home/home_page.dart';

// ── Booking ────────────────────────────────────────────────────
import 'presentation/pages/booking/booking_page.dart';

// ── Tagihan ────────────────────────────────────────────────────
import 'presentation/pages/tagihan/tagihan_page.dart';                     

// ── Keluhan ────────────────────────────────────────────────────
import 'presentation/pages/review_keluhan/keluhan_page.dart';

// ── Review ─────────────────────────────────────────────────────
import 'presentation/pages/review_keluhan/semua_review_page.dart';
import 'presentation/pages/review_keluhan/tulis_review_page.dart';
import 'presentation/pages/review_keluhan/edit_review_page.dart';

// ── Setting ────────────────────────────────────────────────────
import 'presentation/pages/profil_setting/setting_page.dart';
import 'presentation/pages/profil_setting/detail_akun_page.dart';
import 'presentation/pages/profil_setting/edit_akun_page.dart';
import 'presentation/pages/profil_setting/panduan_page.dart';

// ── Model ──────────────────────────────────────────────────────
import 'data/models/kamar_models.dart';
import 'data/models/furnitur_models.dart';
import 'data/models/review_models.dart';
import 'data/models/user_models.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting('id_ID', null);

  final isLoggedIn = await ApiHelper.isLoggedIn();

  // ← TAMBAHKAN INI
  if (isLoggedIn) {
    final token = await ApiHelper.getToken();
    if (token != null) {
      MidtransService.setToken(token);
    }
  }

  FlutterNativeSplash.remove();
  runApp(DKostApp(isLoggedIn: isLoggedIn));
}

class DKostApp extends StatelessWidget {
  final bool isLoggedIn;
  const DKostApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "D'Kost",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71),
          primary: const Color(0xFF2ECC71),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),

      home: isLoggedIn ? const HomePage() : const WelcomeScreen(),
      routes: _buildRoutes(),
      onGenerateRoute: _generateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const _NotFoundPage(),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/welcome':        (_) => const WelcomeScreen(),
      '/login':          (_) => const LoginPage(),
      '/register':       (_) => const RegisterPage(),
      '/lupa-password':  (_) => const LupaPasswordPage(),
      '/masuk-otp':      (_) => const MasukOtpPage(),
      '/ganti-password': (_) => const GantiPasswordPage(),
      '/home':           (_) => const HomePage(),
      '/kamar-search':   (_) => const SearchPage(),
      '/keluhan-list':   (_) => const KeluhanListPage(),
      '/lapor-keluhan':  (_) => const LaporKeluhanPage(),
      '/setting':        (_) => const SettingPage(),
      '/detail-akun':    (_) => const DetailAkunPage(),
      '/panduan':        (_) => const PanduanPage(),
      '/kamarku':        (_) => const KamarkuPage(),
      '/tagihan':        (_) => const TagihanPage(),                   
    };
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {

      case '/kamar-detail':
        final kamarId = args?['id'] as int? ?? 0;
        return _route(KamarDetailPage(kamarId: kamarId), settings);

      case '/detail-kamarku':
        final bookingId = args?['booking_id'] as int? ?? 0;
        return _route(DetailKamarkuPage(bookingId: bookingId), settings);

      case '/checkout':
        final kamar        = args?['kamar'] as KamarModel;
        final durasi       = args?['durasi'] as int? ?? 1;
        final furnitur     = args?['furnitur'] as Map<int, int>? ?? {};
        final listFurnitur = args?['furnitur_list'] as List<FurniturModel>? ?? [];
        final tglMulai     = args?['tgl_mulai'] as String? ?? '';
        return _route(
          CheckoutPage(
            kamar: kamar,
            durasiSewa: durasi,
            selectedFurnitur: furnitur,
            furniturList: listFurnitur,
            tglMulaiSewa: tglMulai,
          ),
          settings,
        );

      case '/semua-review':
        final kamarId = args?['kamar_id'] as int? ?? 0;
        return _route(SemuaReviewPage(kamarId: kamarId), settings);

      case '/tulis-review':
        final kamarId = args?['kamar_id'] as int? ?? 0;
        return _route(TulisReviewPage(kamarId: kamarId), settings);

      case '/edit-review':
        final review = args?['review'] as ReviewModel;
        return _route(EditReviewPage(existingReview: review), settings);

      case '/edit-profil':
        final user = args?['user'] as User;
        return _route(EditProfilPage(user: user), settings);

      case '/masuk-otp':
        return _route(const MasukOtpPage(), settings);

      case '/ganti-password':
        return _route(const GantiPasswordPage(), settings);

      default:
        return null;
    }
  }

  MaterialPageRoute _route(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 16),
            const Text('Halaman tidak ditemukan',
                style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}