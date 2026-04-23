<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('pages.home');
})->name('home');

Route::get('/trip', function () {
    return view('pages.trip');
})->name('trip');

Route::get('/map', function () {
    return view('pages.map');
})->name('map');

Route::get('/explore', function () {
    $destinations = [
        [
            'id'           => 'maspati',
            'name'         => 'Kampung Lawas Maspati',
            'category'     => 'Heritage',
            'image'        => 'maspati.jpg',
            'description'  => 'Kampung Lawas Maspati adalah kawasan pemukiman bersejarah di jantung Kota Surabaya yang telah berdiri sejak era kolonial Belanda. Rumah-rumah berarsitektur Indische Empire style berpadu harmonis dengan keseharian warga yang masih menjaga kearifan lokal.',
            'location'     => 'Jl. Maspati, Bubutan, Surabaya',
            'hours'        => '07:00 – 17:00',
            'ticket'       => 'Gratis',
            'duration'     => '45 – 60 menit',
            'rating'       => 4.5,
        ],
        [
            'id'           => 'tjokroaminoto',
            'name'         => 'Rumah HOS Tjokroaminoto',
            'category'     => 'Heritage',
            'image'        => 'tjokroaminoto.jpg',
            'description'  => 'Rumah bersejarah tempat tinggal H.O.S. Tjokroaminoto, tokoh pergerakan nasional Indonesia. Di sinilah Soekarno muda pernah menjadi kos dan mendapat bimbingan langsung dari sang guru bangsa.',
            'location'     => 'Jl. Peneleh Gang VII No.29, Surabaya',
            'hours'        => '08:00 – 16:00',
            'ticket'       => 'Rp 5.000',
            'duration'     => '30 – 45 menit',
            'rating'       => 4.7,
        ],
        [
            'id'           => 'chenghoo',
            'name'         => 'Masjid Cheng Hoo',
            'category'     => 'Religi',
            'image'        => 'chenghoo.jpg',
            'description'  => 'Masjid Muhammad Cheng Hoo adalah masjid unik bergaya arsitektur Tionghoa di Surabaya. Didirikan untuk mengenang Laksamana Cheng Hoo yang beragama Islam, masjid ini menjadi simbol akulturasi budaya yang indah.',
            'location'     => 'Jl. Gading No.2, Ketabang, Surabaya',
            'hours'        => '05:00 – 21:00',
            'ticket'       => 'Gratis',
            'duration'     => '30 – 45 menit',
            'rating'       => 4.8,
        ],
        [
            'id'           => 'ampel',
            'name'         => 'Makam Sunan Ampel',
            'category'     => 'Religi',
            'image'        => 'ampel.jpg',
            'description'  => 'Sunan Ampel adalah salah satu dari Wali Songo yang berjasa menyebarkan Islam di tanah Jawa. Kompleks makamnya di kawasan Ampel menjadi destinasi ziarah utama dan pusat wisata religi di Surabaya.',
            'location'     => 'Jl. Ampel Masjid No.53, Surabaya',
            'hours'        => '06:00 – 21:00',
            'ticket'       => 'Gratis',
            'duration'     => '45 – 60 menit',
            'rating'       => 4.9,
        ],
        [
            'id'           => 'dejavasche',
            'name'         => 'Gedung De Javasche Bank',
            'category'     => 'Heritage',
            'image'        => 'dejavasche.jpg',
            'description'  => 'Gedung De Javasche Bank adalah salah satu bangunan bersejarah megah peninggalan zaman kolonial Belanda. Kini berfungsi sebagai museum, gedung ini menyimpan koleksi numismatik dan kisah perjalanan perbankan Indonesia.',
            'location'     => 'Jl. Garuda No.1, Krembangan Sel., Surabaya',
            'hours'        => '08:00 – 15:30',
            'ticket'       => 'Rp 5.000',
            'duration'     => '45 – 60 menit',
            'rating'       => 4.6,
        ],
    ];

    $culinary = [
        [
            'id'       => 'rawon',
            'name'     => 'Rawon Setan',
            'image'    => 'rawon.jpg',
            'distance' => '≤ 500 m dari rute',
            'rating'   => 4.8,
            'duration' => '30 – 45 menit',
            'price'    => 'Rp 30.000 – Rp 45.000',
            'desc'     => 'Rawon hitam pekat khas Surabaya dengan kuah kluwek yang kaya rempah dan daging sapi empuk. Legenda kuliner malam Surabaya yang beroperasi hingga dini hari.',
        ],
        [
            'id'       => 'lontong',
            'name'     => 'Lontong Balap',
            'image'    => 'lontong.jpg',
            'distance' => '≤ 500 m dari rute',
            'rating'   => 4.7,
            'duration' => '20 – 30 menit',
            'price'    => 'Rp 20.000 – Rp 30.000',
            'desc'     => 'Sajian khas Surabaya berupa lontong, tahu goreng, lentho, tauge, bawang goreng, dan petis udang. Sarapan favorit warga Surabaya sejak dekade lalu.',
        ],
    ];

    return view('pages.explore', compact('destinations', 'culinary'));
})->name('explore');

Route::get('/detail/{id}', function ($id) {
    $destinations = [
        'maspati' => [
            'id'          => 'maspati',
            'name'        => 'Kampung Lawas Maspati',
            'category'    => 'Heritage',
            'image'       => 'maspati.jpg',
            'description' => 'Kampung Lawas Maspati adalah kawasan pemukiman bersejarah di jantung Kota Surabaya yang telah berdiri sejak era kolonial Belanda. Rumah-rumah berarsitektur Indische Empire style berpadu harmonis dengan keseharian warga yang masih menjaga kearifan lokal. Kampung ini pernah menjadi tempat tinggal kalangan priyayi dan tokoh pergerakan, menjadikannya kapsul waktu yang hidup di tengah kota modern.',
            'location'    => 'Jl. Maspati, Bubutan, Surabaya',
            'hours'       => '07:00 – 17:00',
            'ticket'      => 'Gratis',
            'duration'    => '45 – 60 menit',
            'rating'      => 4.5,
        ],
        'tjokroaminoto' => [
            'id'          => 'tjokroaminoto',
            'name'        => 'Rumah HOS Tjokroaminoto',
            'category'    => 'Heritage',
            'image'       => 'tjokroaminoto.jpg',
            'description' => 'Rumah bersejarah tempat tinggal H.O.S. Tjokroaminoto, tokoh pergerakan nasional Indonesia. Di sinilah Soekarno muda pernah menjadi kos dan mendapat bimbingan langsung dari sang guru bangsa. Rumah ini kini menjadi museum yang menyimpan berbagai koleksi dan dokumentasi perjuangan Tjokroaminoto.',
            'location'    => 'Jl. Peneleh Gang VII No.29, Surabaya',
            'hours'       => '08:00 – 16:00',
            'ticket'      => 'Rp 5.000',
            'duration'    => '30 – 45 menit',
            'rating'      => 4.7,
        ],
        'chenghoo' => [
            'id'          => 'chenghoo',
            'name'        => 'Masjid Cheng Hoo',
            'category'    => 'Religi',
            'image'       => 'chenghoo.jpg',
            'description' => 'Masjid Muhammad Cheng Hoo adalah masjid unik bergaya arsitektur Tionghoa di Surabaya. Didirikan untuk mengenang Laksamana Cheng Hoo yang beragama Islam, masjid ini menjadi simbol akulturasi budaya yang indah. Warna merah dan emas mendominasi eksteriornya, mencerminkan harmoni dua kebudayaan besar.',
            'location'    => 'Jl. Gading No.2, Ketabang, Surabaya',
            'hours'       => '05:00 – 21:00',
            'ticket'      => 'Gratis',
            'duration'    => '30 – 45 menit',
            'rating'      => 4.8,
        ],
        'ampel' => [
            'id'          => 'ampel',
            'name'        => 'Makam Sunan Ampel',
            'category'    => 'Religi',
            'image'       => 'ampel.jpg',
            'description' => 'Sunan Ampel adalah salah satu dari Wali Songo yang berjasa menyebarkan Islam di tanah Jawa. Kompleks makamnya di kawasan Ampel menjadi destinasi ziarah utama dan pusat wisata religi di Surabaya. Suasana sakral berpadu dengan pasar oleh-oleh khas Arab yang ramai di sekitarnya.',
            'location'    => 'Jl. Ampel Masjid No.53, Surabaya',
            'hours'       => '06:00 – 21:00',
            'ticket'      => 'Gratis',
            'duration'    => '45 – 60 menit',
            'rating'      => 4.9,
        ],
        'dejavasche' => [
            'id'          => 'dejavasche',
            'name'        => 'Gedung De Javasche Bank',
            'category'    => 'Heritage',
            'image'       => 'dejavasche.jpg',
            'description' => 'Gedung De Javasche Bank adalah salah satu bangunan bersejarah megah peninggalan zaman kolonial Belanda. Kini berfungsi sebagai museum, gedung ini menyimpan koleksi numismatik dan kisah perjalanan perbankan Indonesia. Arsitektur neo-klasiknya menjadi latar foto favorit para pengunjung kawasan kota lama Surabaya.',
            'location'    => 'Jl. Garuda No.1, Krembangan Sel., Surabaya',
            'hours'       => '08:00 – 15:30',
            'ticket'      => 'Rp 5.000',
            'duration'    => '45 – 60 menit',
            'rating'      => 4.6,
        ],
    ];

    $destination = $destinations[$id] ?? $destinations['maspati'];
    return view('pages.detail', compact('destination'));
})->name('detail');

Route::get('/transport', function () {
    $options = [
        [
            'id'          => 'motorbike',
            'icon'        => '🛵',
            'name'        => 'Motor',
            'price'       => 'Rp 70.000 / hari',
            'desc'        => 'Fleksibel, mudah parkir di gang sempit kawasan heritage. Cocok untuk solo traveler atau pasangan.',
            'pros'        => ['Hemat biaya', 'Mudah parkir', 'Bebas macet'],
            'cons'        => ['Kapasitas 2 orang', 'Rentan cuaca'],
            'color'       => '#D39858',
        ],
        [
            'id'          => 'car',
            'icon'        => '🚗',
            'name'        => 'Mobil + Driver',
            'price'       => 'Rp 300.000 / hari',
            'desc'        => 'Nyaman untuk keluarga atau rombongan. Driver berpengalaman tahu rute terbaik kota lama Surabaya.',
            'pros'        => ['Nyaman & AC', 'Kapasitas 4–6 orang', 'Driver berpengalaman'],
            'cons'        => ['Biaya lebih tinggi', 'Sulit parkir di area sempit'],
            'color'       => '#8A4E1E',
        ],
        [
            'id'          => 'tour',
            'icon'        => '🏆',
            'name'        => 'Private Tour',
            'price'       => 'Mulai Rp 500.000',
            'desc'        => 'Paket lengkap dengan pemandu wisata berlisensi, kendaraan, dan tiket destinasi. Pengalaman premium!',
            'pros'        => ['Pemandu berlisensi', 'All-inclusive', 'Jadwal fleksibel'],
            'cons'        => ['Biaya tertinggi', 'Perlu booking H-1'],
            'color'       => '#34150F',
        ],
    ];
    return view('pages.transport', compact('options'));
})->name('transport');

Route::get('/umkm', function () {
    $products = [
        ['name' => 'Batik Mangrove Surabaya',   'image' => 'umkm1.jpg', 'price' => 'Rp 120.000', 'seller' => 'Batik Sonokembang', 'rating' => 4.7],
        ['name' => 'Keripik Ikan Bandeng',       'image' => 'umkm2.jpg', 'price' => 'Rp 45.000',  'seller' => 'UMKM Kenjeran',     'rating' => 4.5],
        ['name' => 'Petis Udang Premium',        'image' => 'umkm3.jpg', 'price' => 'Rp 35.000',  'seller' => 'Bu Darmi Petis',    'rating' => 4.8],
        ['name' => 'Rujak Cingur Kemasan',       'image' => 'umkm4.jpg', 'price' => 'Rp 25.000',  'seller' => 'Dapur Ibu Siti',    'rating' => 4.6],
        ['name' => 'Kue Lumpur Original',        'image' => 'umkm5.jpg', 'price' => 'Rp 30.000',  'seller' => 'Kue Bu Endang',     'rating' => 4.9],
        ['name' => 'Kerajinan Bambu Heritage',   'image' => 'umkm6.jpg', 'price' => 'Rp 75.000',  'seller' => 'Sentra Maspati',    'rating' => 4.4],
    ];
    return view('pages.umkm', compact('products'));
})->name('umkm');
