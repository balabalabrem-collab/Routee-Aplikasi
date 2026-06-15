# 🎮 Panduan Demo Aplikasi Routee Surabaya

Dokumen ini berisi semua informasi penting, data testing, dan langkah-langkah simulasi pembayaran untuk keperluan presentasi dan demo aplikasi **Routee Surabaya**.

---

## 🔑 Kredensial Midtrans Sandbox (Testing)
Gunakan kredensial berikut jika Anda perlu memverifikasi setelan di dashboard Midtrans:

*   **Merchant ID**: `M458011512`
*   **Client Key**: `Mid-client-[CLIENT_KEY_ANDA]`
*   **Server Key**: `Mid-server-[SERVER_KEY_ANDA]`
*   **Environment**: Sandbox (Testing Mode - Tanpa Uang Asli)

---

## 💳 Metode Pembayaran untuk Demo
Berikut adalah cara mensimulasikan pembayaran sukses pada sistem Midtrans Sandbox langsung dari aplikasi:

### 1. Kartu Kredit / Debit (Simulasi Langsung)
*   **Nomor Kartu**: `4811 1111 1111 1114`
*   **CVV**: `123`
*   **Tanggal Kedaluwarsa**: Bulan/Tahun apa saja di masa depan (Contoh: `12/28`)
*   **Kode OTP (3DS)**: `112233`

### 2. Bank Virtual Account (Simulasi Via Portal)
1.  Pilih **Bank Transfer** di aplikasi (misalnya **BCA**, **BNI**, atau **BRI**).
2.  Salin (Copy) **Nomor Virtual Account** yang muncul di layar pembayaran.
3.  Buka web simulator Midtrans: **[https://simulator.sandbox.midtrans.com](https://simulator.sandbox.midtrans.com)**.
4.  Pilih menu **Bank Transfer** -> Pilih bank yang sesuai (misal: BCA).
5.  Tempel (Paste) nomor Virtual Account tadi, lalu klik **Inquire** -> **Pay**.
6.  Status di aplikasi Anda akan otomatis berubah menjadi **Lunas/Berhasil**.

### 3. GoPay / ShopeePay (Simulasi QR Code)
1.  Pilih **GoPay** / **ShopeePay** di layar pembayaran.
2.  QR Code Sandbox akan muncul.
3.  Klik tombol simulator berwarna oranye/biru di samping QR Code di halaman tersebut untuk mensimulasikan "Scan Berhasil" dan "Bayar Berhasil".

---

## 💾 Basis Data & Riwayat Transaksi (Laravel Backend)
Aplikasi menggunakan basis data **SQLite** (`database.sqlite`) untuk menyimpan riwayat transaksi secara lokal.

### Endpoints API yang dapat diakses:
*   **Melihat Riwayat Transaksi (JSON)**:
    Buka di browser setelah menjalankan server Laravel:
    `http://localhost:8000/api/payment/history`
    *(Menampilkan 50 transaksi sewa terakhir secara realtime dari database)*

*   **Cek Status Transaksi Spesifik**:
    `http://localhost:8000/api/payment/status/{ORDER_ID}`

---

## 🚀 Persiapan Sebelum Presentasi Demo
1.  **Jalankan Laravel Backend**:
    ```bash
    cd c:\xampp\htdocs\Routee
    php artisan serve
    ```
    *Pastikan port berjalan di `localhost:8000` agar Flutter dapat berkomunikasi.*

2.  **Jalankan Flutter App**:
    Gunakan perangkat fisik (HP) atau emulator Android/iOS Anda:
    ```bash
    cd c:\xampp\htdocs\Routee\routee_flutter
    flutter run
    ```
