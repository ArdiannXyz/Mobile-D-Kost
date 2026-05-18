# GitHub Actions — D'Kost Flutter App

Direktori ini berisi dua workflow otomatis untuk project D'Kost.

---

## Workflow yang Tersedia

### 1. `ci.yml` — Continuous Integration
**Trigger:** Setiap `push` atau `pull_request` ke branch `main`, `master`, `develop`

| Job | Fungsi |
|-----|--------|
| `analyze` | Cek format kode (`dart format`) + Flutter analyze (lint) |
| `test` | Jalankan unit & widget test + upload coverage report |
| `build_debug` | Build APK debug + upload sebagai artifact |

### 2. `cd.yml` — Continuous Delivery (Release)
**Trigger:** Push tag versi seperti `v1.0.0`, `v1.2.3-beta`, atau dipicu manual

| Job | Fungsi |
|-----|--------|
| `build_release` | Build APK release (signed) + AAB untuk Play Store |
| `create_github_release` | Buat GitHub Release otomatis dengan changelog dari git log |

---

## Setup: GitHub Secrets yang Diperlukan

Masuk ke **Settings → Secrets and variables → Actions** di repository Anda, lalu tambahkan:

### Untuk CD (signing APK release)

| Secret Name | Keterangan |
|-------------|------------|
| `KEYSTORE_BASE64` | File keystore Android di-encode ke base64 |
| `KEYSTORE_PASSWORD` | Password keystore |
| `KEY_ALIAS` | Alias key di dalam keystore |
| `KEY_PASSWORD` | Password key (bisa sama dengan keystore password) |

### Cara encode keystore ke Base64

**Linux/macOS:**
```bash
base64 -w 0 your-release.keystore
```

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("your-release.keystore"))
```

Salin output tersebut dan paste sebagai nilai secret `KEYSTORE_BASE64`.

---

## Cara Membuat Release Baru

### Metode 1: Push Tag (Otomatis)
```bash
# Tandai commit saat ini dengan tag versi
git tag v1.0.0

# Push tag ke GitHub → CD workflow otomatis berjalan
git push origin v1.0.0
```

### Metode 2: Manual Dispatch
1. Buka tab **Actions** di GitHub
2. Pilih workflow **"🚀 CD — Build & Release APK"**
3. Klik **"Run workflow"**
4. Isi versi dan build number → klik **"Run workflow"**

---

## Konvensi Penamaan Tag

| Tag | Keterangan |
|-----|------------|
| `v1.0.0` | Rilis stabil |
| `v1.0.1` | Patch / bug fix |
| `v1.1.0` | Minor — fitur baru |
| `v2.0.0` | Major — breaking change |
| `v1.0.0-beta` | Beta (ditandai pre-release) |
| `v1.0.0-rc.1` | Release candidate |

---

## File yang Dihasilkan

| Workflow | Artifact | Retensi |
|----------|----------|---------|
| CI | APK Debug | 7 hari |
| CI | Coverage report | 14 hari |
| CD | APK Release | 30 hari |
| CD | AAB Release | 30 hari |
| CD | GitHub Release | Permanen |

---

## Catatan Penting

> **`google-services.json`** sudah ada di repository (`android/app/google-services.json`).  
> Pastikan file ini **tidak di-push ke repo publik** jika berisi konfigurasi sensitif.  
> Tambahkan ke `.gitignore` dan gunakan GitHub Secret jika perlu.
