# 🗺️ Routee — 1-Day Heritage Trip Planner Surabaya

> **Proyek UTS — Universitas Teknologi Surabaya**  
> Optimasi Rute Wisata Heritage 1-Hari di Kota Surabaya

---

## 🚀 Cara Menjalankan

```bash
# 1. Masuk ke direktori project
cd C:\xampp\htdocs\Routee

# 2. Install dependencies (sudah dilakukan)
composer install

# 3. Generate app key (sudah dilakukan)
php artisan key:generate

# 4. Jalankan server
php artisan serve

# 5. Buka browser
# http://127.0.0.1:8000
```

---

## 📁 Struktur Project

```
Routee/
├── routes/
│   └── web.php               ← Semua route halaman
├── resources/views/
│   ├── layouts/
│   │   └── app.blade.php     ← Master layout (navbar, footer)
│   └── pages/
│       ├── home.blade.php    ← Halaman utama (/)
│       ├── trip.blade.php    ← Hasil itinerary (/trip)
│       ├── map.blade.php     ← Peta rute (/map)
│       ├── explore.blade.php ← Jelajahi destinasi (/explore)
│       ├── detail.blade.php  ← Detail destinasi (/detail/{id})
│       ├── transport.blade.php ← Transportasi (/transport)
│       └── umkm.blade.php    ← Produk UMKM (/umkm)
├── public/
│   ├── css/
│   │   └── style.css         ← Semua styling
│   ├── js/
│   │   └── script.js         ← Semua interaksi JS
│   └── images/               ← SEMUA GAMBAR DI SINI
│       ├── logo.png           ← Logo Routee ← GANTI DI SINI
│       ├── maspati.jpg        ← Kampung Lawas Maspati
│       ├── tjokroaminoto.jpg  ← Rumah HOS Tjokroaminoto
│       ├── chenghoo.jpg       ← Masjid Cheng Hoo
│       ├── ampel.jpg          ← Makam Sunan Ampel
│       ├── dejavasche.jpg     ← Gedung De Javasche Bank
│       ├── rawon.jpg          ← Rawon Setan
│       ├── lontong.jpg        ← Lontong Balap
│       ├── umkm1.jpg          ← Batik Mangrove
│       ├── umkm2.jpg          ← Keripik Ikan Bandeng
│       ├── umkm3.jpg          ← Petis Udang
│       ├── umkm4.jpg          ← Rujak Cingur
│       ├── umkm5.jpg          ← Kue Lumpur
│       ├── umkm6.jpg          ← Kerajinan Bambu
│       └── placeholder.jpg   ← Fallback jika gambar tidak ada
```

---

## 🖼️ Cara Mengganti Gambar

Sangat mudah! Cukup **replace file** di folder `public/images/`:

| File            | Isi                        |
|-----------------|----------------------------|
| `logo.png`      | Logo Routee utama          |
| `maspati.jpg`   | Foto Kampung Lawas Maspati |
| `tjokroaminoto.jpg` | Foto Rumah Tjokroaminoto |
| `chenghoo.jpg`  | Foto Masjid Cheng Hoo      |
| `ampel.jpg`     | Foto Makam Sunan Ampel     |
| `dejavasche.jpg`| Foto Gedung De Javasche    |
| `rawon.jpg`     | Foto Rawon Setan           |
| `lontong.jpg`   | Foto Lontong Balap         |

> **Catatan**: Pastikan nama file tetap sama agar tidak perlu mengubah kode.

---

## 📍 Halaman yang Tersedia

| URL             | Halaman              |
|-----------------|----------------------|
| `/`             | 🏠 Home              |
| `/trip`         | 📅 Itinerary         |
| `/map`          | 🗺️ Peta Rute        |
| `/explore`      | 🔍 Jelajahi          |
| `/detail/maspati`| 📍 Detail Destinasi |
| `/transport`    | 🚗 Transportasi      |
| `/umkm`         | 🛍️ Produk UMKM     |

---

## 🎨 Design System

```
Background   : #EACEAA
Primary Btn  : #D39858
Heading      : #8A4E1E
Text         : #34150F
Font         : Poppins (Google Fonts)
Border Radius: 16px
```

---

## ⚡ Tech Stack

- **Framework**: Laravel 12 (PHP 8.2)
- **Template**: Blade
- **Styling**: Vanilla CSS (no frameworks)
- **JavaScript**: Vanilla JS (no libraries)
- **Data**: Static arrays (no database)
- **Images**: Local files (no external CDN)

---

*© 2025 Routee — UTS Presentation Project*
