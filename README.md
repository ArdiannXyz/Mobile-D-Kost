# WebDkost Mobile 📱

Aplikasi manajemen kost berbasis mobile menggunakan Flutter & Dart, dengan backend Laravel 11 dan CI/CD Jenkins.

---

## 📋 Persyaratan

Pastikan sudah terinstall di komputer kamu:

| Tools | Versi | Link |
|---|---|---|
| Git | Latest | https://git-scm.com |
| Flutter SDK | ^3.x.x | https://flutter.dev/docs/get-started/install |
| Dart SDK | ^3.x.x | Sudah termasuk dalam Flutter SDK |
| Android Studio | Latest | https://developer.android.com/studio |
| VSCode | Latest | https://code.visualstudio.com |
| VSCode Extension | Flutter + Dart | Install dari VSCode Marketplace |
| Android Emulator / Device | API 21+ | Setup via Android Studio AVD Manager |
| Xcode (macOS only) | Latest | Untuk build iOS |

---

## 🚀 Langkah Setup dari Awal

### 1 — Clone Repository

Buka terminal, lalu:

```bash
cd ~/projects
https://github.com/ArdiannXyz/Mobile-D-Kost.git
cd Mobile-D-Kost
```

### 2 — Buka dengan VSCode

```bash
code .
```

> ⚠️ Pastikan ekstensi **Flutter** dan **Dart** sudah aktif di VSCode.
> Jika belum, buka Extensions (`Ctrl+Shift+X`) → cari "Flutter" → Install.

### 3 — Install Dependencies

```bash
flutter pub get
```

### 4 — Salin File Environment

```bash
cp .env.example .env
```

Buka `.env` lalu sesuaikan konfigurasi API:

```env
API_BASE_URL=http://10.0.2.2:8000/api
APP_ENV=development
APP_DEBUG=true
```

> ⚠️ Gunakan `10.0.2.2` (bukan `localhost`) agar emulator Android bisa mengakses backend lokal.
> ⚠️ Untuk device fisik, gunakan IP lokal mesin kamu (contoh: `192.168.1.x`).

### 5 — Cek Setup Flutter

```bash
flutter doctor
```

Pastikan semua item berstatus **✅** atau tidak ada masalah kritis:

```
[✓] Flutter (Channel stable)
[✓] Android toolchain
[✓] Android Studio
[✓] VS Code
[✓] Connected device
```

### 6 — Jalankan Aplikasi

```bash
# Jalankan di emulator/device yang terdeteksi
flutter run

# Jalankan di device spesifik
flutter run -d emulator-5554

# Jalankan di mode release
flutter run --release
```

### 7 — Akses Aplikasi

Aplikasi akan otomatis terbuka di emulator/device yang terhubung.

> 📡 Pastikan backend Laravel sudah berjalan di `http://localhost:8000` sebelum menjalankan aplikasi.

---

## 🗄️ Struktur API

Semua permintaan ke backend menggunakan base URL dari `.env`:

```
http://10.0.2.2:8000/api
```

Contoh endpoint yang digunakan:

| Endpoint | Method | Keterangan |
|---|---|---|
| `/auth/login` | POST | Login pengguna |
| `/auth/register` | POST | Registrasi pengguna |
| `/kamar` | GET | Daftar semua kamar |
| `/kamar/{id}` | GET | Detail kamar |
| `/booking` | POST | Buat booking baru |
| `/tagihan` | GET | Daftar tagihan |
| `/pembayaran` | POST | Konfirmasi pembayaran |
| `/keluhan` | POST | Kirim keluhan |
| `/review` | POST | Kirim ulasan |

---

## 🔧 Perintah Berguna

### Flutter CLI

```bash
# Install dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Bersihkan build cache
flutter clean

# Jalankan aplikasi (debug mode)
flutter run

# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build App Bundle (untuk Play Store)
flutter build appbundle

# Build iOS (macOS only)
flutter build ios --release
```

### Testing

```bash
# Jalankan semua test
flutter test

# Test spesifik file
flutter test test/features/kamar_test.dart

# Test dengan coverage
flutter test --coverage

# Lihat coverage di browser
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Analisis Kode

```bash
# Cek masalah kode
flutter analyze

# Format kode otomatis
dart format .
```

### Melihat Log

```bash
# Log real-time dari device
flutter logs

# Log dari Android device
adb logcat | grep flutter
```

---

## 🌿 Git Workflow

### Alur Branch

```
main           → Production (protected, butuh review)
develop        → Staging/Testing
fix/branch     → Perbaikan bug
feature/branch → Fitur baru
```

### Alur Kerja Harian

```bash
# 1. Mulai dari develop terbaru
git checkout develop
git pull origin develop

# 2. Buat branch baru
git checkout -b feature/nama-fitur

# 3. Kerjakan perubahan...

# 4. Test di lokal WAJIB sebelum push
flutter test
flutter analyze

# 5. Commit dan push
git add .
git commit -m "feat: deskripsi perubahan"
git push origin feature/nama-fitur

# 6. Buat Pull Request ke develop di GitHub
# 7. Minta review dari anggota tim
# 8. Setelah approve, merge ke develop
# 9. Develop ke main melalui PR
```

### ⚠️ Penting Setelah Merge Branch

Setelah merge branch ke develop, selalu update dependencies:

```bash
git checkout develop
git pull origin develop

flutter clean
flutter pub get
flutter run
```

### Format Pesan Commit

```
feat     : tambah fitur baru
fix      : perbaiki bug
chore    : update dependencies / pubspec
docs     : update dokumentasi
test     : tambah/update test
refactor : refactor kode
style    : perubahan UI/styling
```

### Aturan Branch Protection

- Branch `main` dilindungi — tidak bisa push langsung
- Wajib buat Pull Request untuk merge ke `main`
- Minimal 1 approval dari anggota tim (kecuali owner)
- Owner bisa merge tanpa approval

> ⚠️ **Selalu `flutter test` dan `flutter analyze` sebelum push** — jangan sampai pipeline CI/CD gagal karena kode belum ditest.

---

## 🔄 CI/CD dengan Jenkins

### Stage Pipeline

```
Build → Test → Analyze → Build APK → Deploy
```

### Akses Jenkins

```
http://localhost:8080
```

### Cara Kerja

```
Push ke GitHub
      ↓
Jenkins otomatis trigger (jika webhook aktif)
atau Build Now manual
      ↓
Build       → flutter pub get
      ↓
Test        → flutter test
      ↓
Analyze     → flutter analyze
      ↓
Build APK   → flutter build apk --release
      ↓
Deploy      → Upload artifact / distribusi ke tester
```

### Menjalankan Build Manual

1. Buka `http://localhost:8080`
2. Klik job **webdkost-mobile**
3. Klik **Build Now**
4. Klik **Open Blue Ocean** untuk melihat progress

---

## 📁 Struktur Project

```
WebDkost/
├── android/                    → Konfigurasi native Android
├── ios/                        → Konfigurasi native iOS
├── lib/
│   ├── main.dart               → Entry point aplikasi
│   ├── app/
│   │   ├── routes/             → Konfigurasi routing (GoRouter / AutoRoute)
│   │   └── themes/             → Tema dan styling global
│   ├── core/
│   │   ├── api/                → HTTP client & interceptor
│   │   ├── constants/          → Konstanta aplikasi
│   │   ├── errors/             → Error handling & exceptions
│   │   └── utils/              → Helper functions
│   ├── data/
│   │   ├── models/             → Model data (Kamar, Booking, dll)
│   │   │   ├── kamar.dart
│   │   │   ├── booking.dart
│   │   │   ├── tagihan.dart
│   │   │   ├── pembayaran.dart
│   │   │   ├── keluhan.dart
│   │   │   ├── review.dart
│   │   │   └── user.dart
│   │   ├── repositories/       → Repository pattern
│   │   └── datasources/        → Remote & local data source
│   └── presentation/
│       ├── pages/              → Halaman-halaman aplikasi
│       │   ├── auth/           → Login & Register
│       │   ├── home/           → Halaman utama
│       │   ├── kamar/          → Daftar & detail kamar
│       │   ├── booking/        → Proses pemesanan
│       │   ├── tagihan/        → Tagihan & pembayaran
│       │   ├── keluhan/        → Kirim keluhan
│       │   └── profile/        → Profil pengguna
│       ├── widgets/            → Widget reusable
│       └── blocs/              → State management (BLoC/Cubit)
├── test/
│   ├── unit/                   → Unit test
│   ├── widget/                 → Widget test
│   └── integration/            → Integration test
├── assets/
│   ├── images/                 → Gambar & ilustrasi
│   └── fonts/                  → Font kustom
├── .env.example                → Template environment
├── pubspec.yaml                → Konfigurasi dependencies
└── Jenkinsfile                 → CI/CD pipeline config
```

---

## 📦 Dependencies Utama

| Package | Keterangan |
|---|---|
| `dio` | HTTP client untuk komunikasi API |
| `flutter_bloc` | State management dengan BLoC pattern |
| `go_router` | Navigasi & routing |
| `get_it` | Dependency injection |
| `freezed` | Immutable model & union types |
| `json_serializable` | Serialisasi JSON otomatis |
| `shared_preferences` | Penyimpanan data lokal sederhana |
| `flutter_secure_storage` | Penyimpanan token secara aman |
| `cached_network_image` | Cache gambar dari internet |
| `intl` | Internasionalisasi & format tanggal |

---

## 🗃️ Model Data

| Model | Keterangan |
|---|---|
| `User` | Data pengguna (admin & penyewa) |
| `Kamar` | Data kamar kost |
| `GaleriKamar` | Foto-foto kamar |
| `FasilitasKamar` | Fasilitas tiap kamar |
| `Furnitur` | Data furnitur tambahan |
| `Booking` | Data pemesanan kamar |
| `Tagihan` | Tagihan bulanan penyewa |
| `Pembayaran` | Riwayat pembayaran |
| `Review` | Ulasan kamar dari penyewa |
| `Keluhan` | Keluhan penyewa |

---

## ❗ Troubleshooting

### 1. `flutter doctor` menunjukkan error

```bash
# Update Flutter ke versi terbaru
flutter upgrade

# Cek lisensi Android
flutter doctor --android-licenses
```

### 2. Dependency conflict saat `flutter pub get`

```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### 3. Emulator tidak bisa konek ke API lokal

```bash
# Pastikan menggunakan 10.0.2.2 bukan localhost di .env
API_BASE_URL=http://10.0.2.2:8000/api

# Cek apakah backend berjalan
curl http://localhost:8000/api
```

### 4. Build APK gagal — `Gradle build failed`

```bash
cd android
./gradlew clean
cd ..
flutter build apk --debug
```

### 5. Hot reload tidak bekerja

```bash
# Stop aplikasi, lalu jalankan ulang
flutter run
# Tekan 'R' (kapital) di terminal untuk hot restart penuh
```

### 6. Error: `A build.gradle file cannot be found`

```bash
flutter clean
flutter pub get
# Pastikan folder android/ tidak corrupt
```

### 7. Perubahan model tidak ter-generate

Jika menggunakan `freezed` atau `json_serializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Untuk auto-generate saat ada perubahan:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 8. Token autentikasi tidak tersimpan

Pastikan `flutter_secure_storage` sudah dikonfigurasi dengan benar di `android/app/build.gradle`:

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 18  // Minimum untuk flutter_secure_storage
    }
}
```

### 9. Jenkins pipeline gagal saat `flutter test`

```bash
# Pastikan tidak ada test yang skip atau broken
flutter test --no-pub

# Jalankan test dengan output verbose
flutter test --verbose
```

### 10. Gambar tidak muncul dari API

```bash
# Periksa URL gambar di response API
# Pastikan CORS sudah dikonfigurasi di backend Laravel
# Cek permission READ di Android Manifest jika menggunakan gambar lokal
```

### 11. VSCode tidak mengenali Flutter SDK

```bash
# Tambahkan path Flutter ke environment variable
export PATH="$PATH:/path/to/flutter/bin"
source ~/.bashrc  # atau ~/.zshrc

# Verifikasi
flutter --version
```

### 12. `MissingPluginException` saat runtime

```bash
flutter clean
flutter pub get
# Stop dan jalankan ulang aplikasi (bukan hot reload)
flutter run
```

---

## 👥 Tim

| Nama | Role | GitHub |
|---|---|---|
| ArdiannXyz | Owner/Mobile Dev | @ArdiannXyz |

---

## 📝 Lisensi

Project ini menggunakan lisensi [MIT](LICENSE).
