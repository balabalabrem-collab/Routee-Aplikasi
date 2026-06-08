# Routee — 1-Day Heritage Trip Planner Surabaya 🗺️

<p align="center">
  <img src="assets/images/github_banner.png" alt="Routee Banner" width="100%">
</p>

Routee adalah aplikasi perencana perjalanan warisan budaya (*heritage trip planner*) satu hari di Surabaya. Aplikasi ini dirancang untuk memudahkan wisatawan menjelajahi destinasi bersejarah, kuliner legendaris, serta menyediakan sistem penyewaan kendaraan dan layanan ojek online (RO-JEK) terpadu.

---

## 📸 Tampilan Aplikasi (Visual Preview)

<p align="center">
  <img src="assets/images/app_mockups.png" alt="Routee App Mockups" width="100%">
</p>

---

## 🌟 Fitur Utama

1. **Trip Planner 1-Hari**: Membantu merencanakan rute perjalanan warisan budaya secara otomatis atau kustom.
2. **Persewaan Kendaraan Terpadu**: Layanan sewa motor dan mobil terpusat di area Stasiun Gubeng.
3. **Ojek Online RO-JEK**: Layanan ojek online instan dengan estimasi rute, kalkulasi tarif BBM (Rp2.000/km), dan detail harga terperinci.
4. **Dashboard Keuangan Admin (fl_chart)**: Visualisasi kontribusi pendapatan bersih menggunakan diagram lingkaran (*Pie Chart*) interaktif.
5. **Manajemen Karyawan**: Admin dapat menambah, mengubah, dan menghapus akun staf operasional.
6. **Portal Tugas Karyawan**: Staf operasional dapat memantau dan memperbarui status tugas secara interaktif (Belum Selesai ➡️ Menuju Lokasi ➡️ Selesai).
7. **Pemuatan Font Offline**: Seluruh font Google Poppins dibundel secara lokal guna mencegah masalah tulisan hilang/luntur saat aplikasi resumed dari background.

---

## 🔑 Akun Bawaan (Default Accounts)

Untuk mempermudah pengujian, berikut adalah detail akun bawaan yang terdaftar pada sistem lokal:

| Peran (Role) | Email | Kata Sandi (Password) |
| :--- | :--- | :--- |
| **Administrator** | `admin@routee.id` | `adminRoutee2026` |
| **Karyawan/Staff** | `karyawan@routee.id` | `staffRoutee2026` |

---

## 🛠️ Panduan Set Up Proyek

Ikuti langkah-langkah di bawah ini untuk menjalankan atau membangun aplikasi Routee di lingkungan lokal Anda:

### 1. Prasyarat (Prerequisites)
Pastikan perangkat Anda sudah terpasang:
* **Flutter SDK**: Versi `>=3.0.0` (direkomendasikan versi terbaru).
* **Dart SDK**: Versi `>=3.0.0 <4.0.0`.
* **Android Studio / VS Code** (beserta ekstensi Flutter & Dart).
* Emulator Android aktif atau perangkat fisik dalam mode *USB Debugging*.

### 2. Kloning Repositori
Kloning kode sumber khusus folder Flutter ini:
```bash
git clone https://github.com/balabalabrem-collab/Routee.git
cd Routee
```

### 3. Pemasangan Dependensi
Unduh dan pasang semua paket library yang dibutuhkan proyek (seperti `fl_chart`, `provider`, `go_router`, dll.):
```bash
flutter pub get
```

### 4. Menjalankan Aplikasi secara Lokal
Jalankan aplikasi di emulator atau perangkat fisik Anda dalam mode pengembangan (development mode):
```bash
flutter run
```

### 5. Membangun Paket Rilis APK
Untuk membangun berkas rilis APK final yang dioptimalkan (dengan fitur *icon & font tree-shaking*):
```bash
flutter build apk --release
```
Berkas APK hasil build akan berada di direktori:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Struktur Aset Khusus
* **Aset Font**: Tersimpan di folder `google_fonts/` di root proyek untuk menjaga aplikasi dapat merender teks secara offline tanpa koneksi internet.
* **Aset Logo**: Berkas launcher icon berada di `assets/images/logo_v2_launcher.png` dengan padding area aman (*safe zone*) 40% agar logo luar tidak terpotong di perangkat Android.
