<div align="center">

# 🏠 D'Kost Mobile

### Pencarian dan pengelolaan kost dalam genggaman.

Aplikasi Flutter untuk mendukung pengalaman penghuni kost, terhubung dengan backend Laravel melalui API.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Laravel-FF2D20?logo=laravel&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-D24939?logo=jenkins&logoColor=white)

</div>

---

## Tentang aplikasi

**D'Kost Mobile** adalah aplikasi manajemen kost lintas platform yang dibuat menggunakan Flutter. Aplikasi berkomunikasi dengan backend Laravel melalui HTTP API. Fitur yang tercermin pada model dan endpoint proyek meliputi akun pengguna, kamar, booking, tagihan, pembayaran, keluhan, dan review.

## Fitur aplikasi

- Autentikasi pengguna.
- Melihat kamar dan informasi kamar.
- Alur booking dan riwayat terkait.
- Melihat tagihan dan mengirim konfirmasi pembayaran.
- Mengirim keluhan serta ulasan.
- Penyimpanan lokal dan cache gambar.
- Push notification menggunakan OneSignal.

> Ketersediaan fitur dapat berbeda sesuai implementasi backend yang sedang digunakan. Daftar endpoint di bawah adalah gambaran integrasi, bukan jaminan semua endpoint aktif pada setiap environment.

## Teknologi

| Area | Teknologi |
|---|---|
| Aplikasi | Flutter, Dart |
| State management | GetX |
| HTTP | `http` |
| Penyimpanan lokal | Shared Preferences, SQLite (`sqflite`) |
| Gambar dan media | Cached Network Image, Flutter SVG, Image Picker |
| Notifikasi | OneSignal |
| Backend | Laravel API |
| CI/CD | Jenkins; konfigurasi pipeline berada di `Jenkinsfile` bila tersedia |

## Persyaratan

- Flutter SDK yang mendukung Dart `^3.6.1`
- Android Studio/Android SDK untuk Android
- Xcode di macOS untuk build iOS
- Backend Laravel yang dapat diakses dari perangkat/emulator

Periksa setup Flutter dengan:

```bash
flutter doctor
```

## Menjalankan secara lokal

```bash
# Clone repository
git clone https://github.com/ArdiannXyz/Mobile-D-Kost.git
cd Mobile-D-Kost

# Install dependency Flutter
flutter pub get

# Siapkan konfigurasi API lokal
cp .env.example .env
```

Sesuaikan `API_BASE_URL` di `.env` dengan alamat backend. Contoh untuk Android Emulator:

```env
API_BASE_URL=http://10.0.2.2:8000/api
APP_ENV=development
APP_DEBUG=true
```

`10.0.2.2` adalah alamat host komputer dari Android Emulator; `localhost` di emulator merujuk ke emulator itu sendiri. Untuk perangkat fisik, gunakan alamat IP lokal komputer yang dapat dijangkau melalui jaringan.

Jalankan backend Laravel terlebih dahulu. Kemudian jalankan aplikasi:

```bash
flutter devices
flutter run
```

## Perintah berguna

```bash
flutter pub get                  # Pasang dependency
flutter run                      # Jalankan aplikasi
flutter test                     # Jalankan test
flutter analyze                  # Analisis kode
 dart format .                   # Format kode
flutter build apk --release      # Build APK release
flutter build appbundle          # Build Android App Bundle
flutter build ios --release      # Build iOS (macOS)
```

## CI/CD

Repository menyertakan dokumentasi workflow GitHub Actions di `.github/workflows/README.md` dan konfigurasi Jenkins yang perlu dicek terhadap pipeline aktual. Sebelum mengandalkan proses rilis, pastikan secret signing, konfigurasi backend, dan target artifact sudah disiapkan sesuai workflow yang digunakan.

## Struktur ringkas

```text
lib/                 Kode aplikasi Flutter
assets/              Gambar dan aset UI
android/             Konfigurasi aplikasi Android
ios/                 Konfigurasi aplikasi iOS
test/                Unit dan widget test
pubspec.yaml         Dependency dan konfigurasi Flutter
Jenkinsfile          Pipeline Jenkins (jika tersedia)
```

## Keamanan konfigurasi

- Jangan commit `.env` atau credential API.
- Jangan gunakan URL development untuk build production.
- Pastikan backend melakukan autentikasi dan otorisasi; validasi di aplikasi mobile saja tidak cukup.
- Periksa konfigurasi layanan pihak ketiga sebelum mempublikasikan build.

---

<div align="center">

**D'Kost — pengalaman kost yang lebih mudah diakses.**

</div>
