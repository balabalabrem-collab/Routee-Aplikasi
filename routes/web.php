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

/* =====================================================
   EXPLORE — enriched destination & culinary data
   ===================================================== */
if (!function_exists('get_destinations')) {
    function get_destinations() {
        return [
            [
                'id'          => 'maspati',
                'name'        => 'Kampung Lawas Maspati',
                'category'    => 'Heritage',
                'image'       => 'maspati.jpg',
                'description' => 'Kawasan pemukiman bersejarah kolonial Belanda bergaya Indische Empire. Rumah-rumah terawat, gang sempit, dan keseharian warga menjadikannya kapsul waktu di tengah kota modern.',
                'location'    => 'Jl. Maspati, Bubutan, Surabaya',
                'hours'       => '07:00 – 17:00',
                'ticket'      => 'Gratis',
                'duration'    => '45 – 60 menit',
                'rating'      => 4.5,
            ],
            [
                'id'          => 'dejavasche',
                'name'        => 'Gedung De Javasche Bank',
                'category'    => 'Heritage',
                'image'       => 'dejavasche.jpg',
                'description' => 'Bangunan neo-klasik megah peninggalan kolonial, kini museum perbankan Indonesia. Arsitekturnya menjadi latar foto favorit di kawasan kota lama Surabaya.',
                'location'    => 'Jl. Garuda No.1, Krembangan Sel., Surabaya',
                'hours'       => '08:00 – 15:30',
                'ticket'      => 'Rp 5.000',
                'duration'    => '45 – 60 menit',
                'rating'      => 4.6,
            ],
            [
                'id'          => 'tunjungan',
                'name'        => 'Jalan Tunjungan',
                'category'    => 'Heritage',
                'image'       => 'tunjungan.jpg',
                'description' => 'Jantung kota lama Surabaya yang melegenda. Deretan gedung kolonial, Hotel Majapahit bersejarah, dan suasana bazar malam yang ikonik menjadikannya wajib dikunjungi.',
                'location'    => 'Jl. Tunjungan, Surabaya',
                'hours'       => '24 jam',
                'ticket'      => 'Gratis',
                'duration'    => '45 – 90 menit',
                'rating'      => 4.6,
            ],
            [
                'id'          => 'gedung-siola',
                'name'        => 'Museum Surabaya (Gedung Siola)',
                'category'    => 'Heritage',
                'image'       => 'siola.jpg',
                'description' => 'Gedung putih megah era kolonial yang kini menjadi Museum Surabaya. Menyimpan ribuan koleksi artefak, peta kuno, dan kisah terbentuknya Kota Pahlawan.',
                'location'    => 'Jl. Tunjungan No.1, Surabaya',
                'hours'       => '08:00 – 16:00',
                'ticket'      => 'Gratis',
                'duration'    => '60 – 90 menit',
                'rating'      => 4.5,
            ],
            [
                'id'          => 'kota-lama',
                'name'        => 'Kawasan Kota Lama',
                'category'    => 'Heritage',
                'image'       => 'kota-lama.jpg',
                'description' => 'Pusat perdagangan kolonial Belanda abad 17. Deretan gudang tua, jembatan bersejarah, dan sungai Kalimas membentuk lanskap heritage yang unik dan memikat.',
                'location'    => 'Krembangan, Surabaya',
                'hours'       => '24 jam',
                'ticket'      => 'Gratis',
                'duration'    => '60 – 90 menit',
                'rating'      => 4.7,
            ],
            [
                'id'          => 'alun-alun',
                'name'        => 'Alun-Alun Surabaya',
                'category'    => 'Heritage',
                'image'       => 'alun-alun.jpg',
                'description' => 'Ruang publik modern di jantung Surabaya, dikelilingi gedung bersejarah dan Balai Kota. Ideal untuk bersantai sambil menikmati pemandangan kota lama.',
                'location'    => 'Jl. Jimerto, Surabaya',
                'hours'       => '06:00 – 22:00',
                'ticket'      => 'Gratis',
                'duration'    => '30 – 45 menit',
                'rating'      => 4.4,
            ],
            [
                'id'          => 'taman-bungkul',
                'name'        => 'Taman Bungkul',
                'category'    => 'Heritage',
                'image'       => 'bungkul.jpg',
                'description' => 'Taman kota ikonik tempat makam Sunan Bungkul. Trotoar lebar, area bermain, dan pohon-pohon rindang menjadikannya tempat nongkrong favorit warga sekaligus spot heritage.',
                'location'    => 'Jl. Raya Darmo, Surabaya',
                'hours'       => '06:00 – 22:00',
                'ticket'      => 'Gratis',
                'duration'    => '30 – 60 menit',
                'rating'      => 4.6,
            ],
            [
                'id'          => 'kenjeran',
                'name'        => 'Kawasan Kenjeran',
                'category'    => 'Heritage',
                'image'       => 'kenjeran.jpg',
                'description' => 'Pesisir utara Surabaya dengan pemandangan laut, klenteng megah, benteng peninggalan kolonial, dan pasar ikan segar. Perpaduan unik antara tradisi nelayan dan sejarah kota.',
                'location'    => 'Kenjeran, Surabaya',
                'hours'       => '06:00 – 18:00',
                'ticket'      => 'Rp 5.000',
                'duration'    => '60 – 90 menit',
                'rating'      => 4.3,
            ],
            [
                'id'          => 'kalimas',
                'name'        => 'Kalimas Boat Ride',
                'category'    => 'Heritage',
                'image'       => 'kapal-selam.jpg',
                'description' => 'Naik perahu menyusuri Sungai Kalimas yang bersejarah, melihat gudang kolonial dan kehidupan tepi sungai khas Surabaya dari perspektif unik yang tidak bisa anda temukan di daratan.',
                'location'    => 'Dermaga Kalimas, Surabaya',
                'hours'       => '07:00 – 17:00',
                'ticket'      => 'Rp 15.000',
                'duration'    => '45 – 60 menit',
                'rating'      => 4.5,
            ],
            [
                'id'          => 'chenghoo',
                'name'        => 'Masjid Cheng Hoo',
                'category'    => 'Religi',
                'image'       => 'chenghoo.jpg',
                'description' => 'Masjid bergaya arsitektur Tionghoa, simbol akulturasi budaya Islam dan Tiongkok. Warna merah-emas mendominasi eksteriornya yang menawan.',
                'location'    => 'Jl. Gading No.2, Ketabang, Surabaya',
                'hours'       => '05:00 – 21:00',
                'ticket'      => 'Gratis',
                'duration'    => '30 – 45 menit',
                'rating'      => 4.8,
            ],
            [
                'id'          => 'ampel',
                'name'        => 'Makam Sunan Ampel',
                'category'    => 'Religi',
                'image'       => 'ampel.jpg',
                'description' => 'Kompleks makam Wali Songo penyebar Islam di Jawa. Suasana sakral, pasar Arab yang ramai, dan masjid tua berusia lebih dari 600 tahun.',
                'location'    => 'Jl. Ampel Masjid No.53, Surabaya',
                'hours'       => '06:00 – 21:00',
                'ticket'      => 'Gratis',
                'duration'    => '45 – 60 menit',
                'rating'      => 4.9,
            ],
            [
                'id'          => 'langgar-dukur',
                'name'        => 'Langgar Dukur Kayu',
                'category'    => 'Religi',
                'image'       => 'langgar.jpg',
                'description' => 'Langgar (mushola) bersejarah berbahan kayu yang menjadi saksi perkembangan Islam di kawasan Peneleh. Memiliki arsitektur tradisional sederhana dengan nilai historis tinggi.',
                'location'    => 'Peneleh, Surabaya',
                'hours'       => '05:00 – 21:00',
                'ticket'      => 'Gratis',
                'duration'    => '20–30 menit',
                'rating'      => 4.5,
            ],
            [
                'id'          => 'klenteng-kya-kya',
                'name'        => 'Klenteng Kya-Kya',
                'category'    => 'Religi',
                'image'       => 'kya-kya.jpeg',
                'description' => 'Klenteng bersejarah di kawasan Pecinan Surabaya, pusat kehidupan budaya Tionghoa. Ornamen merah-emas, patung naga, dan aroma dupa menciptakan atmosfer spiritual yang khas.',
                'location'    => 'Kembang Jepun, Surabaya',
                'hours'       => '06:00 – 20:00',
                'ticket'      => 'Gratis',
                'duration'    => '30 – 45 menit',
                'rating'      => 4.4,
            ],
            [
                'id'          => 'sanggar-agung',
                'name'        => 'Kelenteng Sanggar Agung',
                'category'    => 'Religi',
                'image'       => 'sanggar-agung.jpg',
                'description' => 'Klenteng megah di kawasan Pantai Kenjeran dengan patung Dewi Kwan Im raksasa menghadap laut. Tempat ibadah sekaligus destinasi wisata spiritual yang ikonik dan fotogenik di Surabaya.',
                'location'    => 'Pantai Kenjeran, Surabaya',
                'hours'       => '06:00 – 18:00',
                'ticket'      => 'Gratis (donasi sukarela)',
                'duration'    => '30–45 menit',
                'rating'      => 4.8,
            ],
            [
                'id'          => 'masjid-agung',
                'name'        => 'Masjid Agung Surabaya',
                'category'    => 'Religi',
                'image'       => 'masjid-agung.jpeg',
                'description' => 'Masjid kebanggaan Surabaya dengan kapasitas ribuan jamaah dan menara kembar yang menjulang tinggi. Arsitektur modern-islami yang megah dan fasilitas lengkap.',
                'location'    => 'Jl. Masjid Agung Tim., Surabaya',
                'hours'       => '05:00 – 22:00',
                'ticket'      => 'Gratis',
                'duration'    => '30 – 45 menit',
                'rating'      => 4.7,
            ],
            [
                'id'          => 'makam-bungkul',
                'name'        => 'Makam Sunan Bungkul',
                'category'    => 'Religi',
                'image'       => 'bungkul.jpg',
                'description' => 'Makam penyebar Islam di Surabaya selatan, terletak di dalam Taman Bungkul. Dikunjungi peziarah dari seluruh Jawa Timur, terutama malam Jumat.',
                'location' => 'Jl. Raya Darmo, Surabaya',
                'hours'    => '06:00 – 22:00', 'ticket' => 'Gratis', 'duration' => '20 – 30 menit', 'rating' => 4.5,
            ]
        ];
    }
}

if (!function_exists('get_culinary')) {
    function get_culinary() {
        return [
            [
                'id'       => 'rawon',
                'name'     => 'Rawon Setan',
                'image'    => 'rawon.jpg',
                'distance' => '≤ 500m dari rute',
                'rating'   => 4.8,
                'duration' => '30 – 45 menit',
                'price'    => 'Rp 30.000 – Rp 45.000',
                'desc'     => 'Rawon hitam pekat khas Surabaya dengan kuah kluwek kaya rempah dan daging sapi empuk. Legenda kuliner malam Surabaya — buka hingga dini hari!',
                'area'     => 'Embong Malang',
            ],
            [
                'id'       => 'lontong-balap',
                'name'     => 'Lontong Balap',
                'image'    => 'lontong.jpg',
                'distance' => '≤ 500m dari rute',
                'rating'   => 4.7,
                'duration' => '20 – 30 menit',
                'price'    => 'Rp 20.000 – Rp 30.000',
                'desc'     => 'Lontong, tahu goreng, lentho, tauge, dan petis udang. Sarapan paling khas Surabaya sejak dekade lalu.',
                'area'     => 'Wonokromo',
            ],
            [
                'id'       => 'tahu-tek',
                'name'     => 'Tahu Tek',
                'image'    => 'tahu-tek.jpg',
                'distance' => '≤ 1 km dari rute',
                'rating'   => 4.6,
                'duration' => '15 – 25 menit',
                'price'    => 'Rp 12.000 – Rp 20.000',
                'desc'     => 'Tahu goreng setengah matang disiram bumbu kacang petis dengan irisan lontong, tauge, dan kerupuk. Camilan otentik Surabaya yang menggoyang lidah.',
                'area'     => 'Pusat Kota',
            ],
            [
                'id'       => 'rujak-cingur',
                'name'     => 'Rujak Cingur',
                'image'    => 'rujak.jpeg',
                'distance' => '≤ 1 km dari rute',
                'rating'   => 4.7,
                'duration' => '20 – 30 menit',
                'price'    => 'Rp 20.000 – Rp 35.000',
                'desc'     => 'Rujak khas Jawa Timur dengan irisan cingur (hidung sapi), sayuran, lontong, tahu tempe, dan bumbu petis yang kaya cita rasa.',
                'area'     => 'Gubeng',
            ],
            [
                'id'       => 'soto-pak-sadi',
                'name'     => 'Soto Pak Sadi',
                'image'    => 'soto-sadi.jpg',
                'distance' => '≤ 500m dari rute',
                'rating'   => 4.7,
                'duration' => '20 – 30 menit',
                'price'    => 'Rp 18.000 – Rp 28.000',
                'desc'     => 'Soto Surabaya legendaris dengan kuah bening kaya rempah, tauge segar, telur, dan ayam kampung. Sarapan pagi favorit sejak 1970-an.',
                'area'     => 'Peneleh',
            ],
            [
                'id'       => 'tahu-campur',
                'name'     => 'Tahu Campur',
                'image'    => 'tahucampur.jpeg',
                'distance' => '≤ 1 km dari rute',
                'rating'   => 4.6,
                'duration' => '15 – 25 menit',
                'price'    => 'Rp 15.000 – Rp 25.000',
                'desc'     => 'Hidangan berkuah kaldu gurih dengan tahu goreng, jeroan sapi, lontong, tauge, dan mie kuning. Kehangatan dalam semangkuk yang penuh cita rasa.',
                'area'     => 'Lamongan Road',
            ],
            [
                'id'       => 'zangrandi',
                'name'     => 'Es Krim Zangrandi',
                'image'    => 'zangrandi.jpg',
                'distance' => '≤ 500m dari Tunjungan',
                'rating'   => 4.8,
                'duration' => '30 – 45 menit',
                'price'    => 'Rp 25.000 – Rp 55.000',
                'desc'     => 'Es krim legendaris Surabaya since 1933. Racikan Italia dengan campuran buah tropis lokal. Tempat favorit generasi ke generasi di jantung kota lama.',
                'area'     => 'Embong Malang',
            ],
            [
                'id'       => 'spikoe',
                'name'     => 'Spikoe Resep Kuno',
                'image'    => 'spikoe.jpg',
                'distance' => '≤ 2 km dari rute',
                'rating'   => 4.9,
                'duration' => '15 - 30 menit',
                'price'    => 'Rp 85.000 – Rp 300.000',
                'desc'     => 'Lapis Surabaya legendaris dengan resep kuno sejak 1976. Oleh-oleh wajib khas Surabaya yang lembut dan kaya rasa manis perpaduan cokelat dan kuning telur.',
                'area'     => 'Rungkut',
            ],
            [
                'id'       => 'siropen',
                'name'     => 'Siropen',
                'image'    => 'siropen.jpg',
                'distance' => '≤ 1 km dari rute',
                'rating'   => 4.8,
                'duration' => '15 - 30 menit',
                'price'    => 'Rp 30.000 – Rp 50.000',
                'desc'     => 'Sirup legendaris pertama di Indonesia sejak 1923, dirintis oleh JC van Drongelen. Varian rasa ikonik seperti mawar dan frambozen selalu menjadi primadona.',
                'area'     => 'Krembangan',
            ],
            [
                'id'       => 'bu-rudy',
                'name'     => 'Sambal Bu Rudy',
                'image'    => 'sambal.jpeg',
                'distance' => '≤ 2 km dari rute',
                'rating'   => 4.9,
                'duration' => '20 – 30 menit',
                'price'    => 'Rp 25.000 – Rp 90.000',
                'desc'     => 'Oleh-oleh legendaris Surabaya! Sambal terasi dengan ikan teri renyah yang telah mendunia. Kemasan modern untuk dinikmati di rumah atau dijadikan buah tangan.',
                'area'     => 'Dharmahusada',
            ],
            [
                'id'       => 'karmini',
                'name'     => 'Karmini Culinary',
                'image'    => 'karmini.jpeg',
                'distance' => '≤ 500m dari Ampel',
                'rating'   => 4.5,
                'duration' => '30 – 45 menit',
                'price'    => 'Rp 20.000 – Rp 40.000',
                'desc'     => 'Warung kuliner khas Arab-Surabaya di dekat kawasan Ampel. Menu andalan: nasi kebuli, sate kambing, dan sup buntut yang kaya rempah autentik.',
                'area'     => 'Ampel',
            ],
            [
                'id'       => 'lontong-kupang',
                'name'     => 'Lontong Kupang',
                'image'    => 'lontong-kupang.jpeg',
                'distance' => '≤ 500m dari Kenjeran',
                'rating'   => 4.6,
                'duration' => '20 – 30 menit',
                'price'    => 'Rp 15.000 – Rp 25.000',
                'desc'     => 'Kuliner khas pesisir Surabaya! Kerang kupang dengan kuah petis, lentho, dan lontong. Wajib dicoba saat mengunjungi kawasan Kenjeran.',
                'area'     => 'Kenjeran',
            ],
            [
                'id'       => 'rawon-kalkulator',
                'name'     => 'Rawon Kalkulator',
                'image'    => 'rawon.jpeg',
                'distance' => '≤ 1 km dari Darmo',
                'rating'   => 4.7,
                'duration' => '30 – 45 menit',
                'price'    => 'Rp 35.000 – Rp 55.000',
                'desc'     => 'Rawon presisi khas Surabaya Selatan — dijuluki "kalkulator" karena porsinya selalu tepat dan harganya transparan. Kuah hitam pekat dengan daging yang melimpah.',
                'area'     => 'Raya Darmo',
            ],
            [
                'id'       => 'warung-pojok',
                'name'     => 'Warung Pojok Gubeng',
                'image'    => 'pojok-gubeng.jpeg',
                'distance' => '≤ 500m dari Gubeng',
                'rating'   => 4.5,
                'duration' => '30 – 45 menit',
                'price'    => 'Rp 15.000 – Rp 30.000',
                'desc'     => 'Warung legendaris di sudut Gubeng yang telah buka sejak 1960-an. Menu nasi campur, pecel, dan aneka lauk pauk rumahan yang otentik dan terjangkau.',
                'area'     => 'Gubeng',
            ]
        ];
    }
}

Route::get('/explore', function () {
    $destinations = get_destinations();
    $culinary = get_culinary();
    return view('pages.explore', compact('destinations', 'culinary'));
})->name('explore');

/* =====================================================
   DETAIL — maps both destinations and culinary items correctly
   ===================================================== */
Route::get('/detail/{id}', function ($id) {
    $destinations = get_destinations();
    $d_indexed = [];
    foreach ($destinations as $d) {
        $d_indexed[$d['id']] = $d;
    }

    $culinary = get_culinary();
    $c_indexed = [];
    foreach ($culinary as $c) {
        $c_indexed[$c['id']] = [
            'id'          => $c['id'],
            'name'        => $c['name'],
            'category'    => 'Kuliner',
            'image'       => $c['image'],
            'description' => $c['desc'],
            'location'    => $c['area'] . ' (' . $c['distance'] . ')',
            'hours'       => '09:00 – 22:00',
            'ticket'      => $c['price'],
            'duration'    => $c['duration'],
            'rating'      => $c['rating'],
        ];
    }

    $all = array_merge($d_indexed, $c_indexed);
    $destination = $all[$id] ?? $all['maspati'];
    return view('pages.detail', compact('destination'));
})->name('detail');

Route::get('/transport', function () {
    $options = [
        [
            'id' => 'motorbike', 'icon' => '🛵', 'name' => 'Motor',
            'image' => 'motor.jpg',
            'price' => 'Rp 70.000 / hari',
            'desc'  => 'Fleksibel, mudah parkir di gang sempit kawasan heritage. Cocok untuk solo traveler atau pasangan.',
            'pros'  => ['Hemat biaya', 'Mudah parkir', 'Bebas macet'],
            'cons'  => ['Kapasitas 2 orang', 'Rentan cuaca'],
            'color' => '#D39858',
        ],
        [
            'id' => 'car', 'icon' => '🚗', 'name' => 'Mobil + Driver',
            'image' => 'mobil-driver.jpg',
            'price' => 'Rp 300.000 / hari',
            'desc'  => 'Nyaman untuk keluarga atau rombongan. Driver berpengalaman tahu rute terbaik kota lama.',
            'pros'  => ['Nyaman & AC', 'Kapasitas 4–6 orang', 'Driver berpengalaman'],
            'cons'  => ['Biaya lebih tinggi', 'Sulit parkir di area sempit'],
            'color' => '#8A4E1E',
        ],
        [
            'id' => 'tour', 'icon' => '🏆', 'name' => 'Private Tour',
            'image' => 'private-tour.jpg',
            'price' => 'Mulai Rp 500.000',
            'desc'  => 'Paket lengkap dengan pemandu berlisensi, kendaraan, dan tiket destinasi. Pengalaman premium!',
            'pros'  => ['Pemandu berlisensi', 'All-inclusive', 'Jadwal fleksibel'],
            'cons'  => ['Biaya tertinggi', 'Perlu booking H-1'],
            'color' => '#34150F',
        ],
    ];
    return view('pages.transport', compact('options'));
})->name('transport');



Route::get('/umkm', function () {
    $products = [
        ['id' => 0, 'name' => 'Batik Mangrove Surabaya',   'image' => 'batik.jpg', 'price' => 'Rp 120.000', 'seller' => 'Batik Sonokembang', 'rating' => 4.7, 'category' => 'fashion'],
        ['id' => 1, 'name' => 'Keripik Ikan Bandeng',       'image' => 'keripik ikan bandeng.jpeg', 'price' => 'Rp 45.000',  'seller' => 'UMKM Kenjeran',     'rating' => 4.5, 'category' => 'food'],
        ['id' => 3, 'name' => 'Rujak Cingur Kemasan',       'image' => 'rujak.jpeg', 'price' => 'Rp 25.000',  'seller' => 'Dapur Ibu Siti',    'rating' => 4.6, 'category' => 'food'],
        ['id' => 4, 'name' => 'Kue Lumpur Original',        'image' => 'lumpur.jpeg', 'price' => 'Rp 30.000',  'seller' => 'Kue Bu Endang',     'rating' => 4.9, 'category' => 'food'],
        ['id' => 5, 'name' => 'Kerajinan Bambu Heritage',   'image' => 'kerajinan bambu.jpeg', 'price' => 'Rp 75.000',  'seller' => 'Sentra Maspati',    'rating' => 4.4, 'category' => 'craft'],
        ['id' => 6, 'name' => 'Gelang Manik Tradisional',   'image' => 'gelang manik.jpeg', 'price' => 'Rp 35.000', 'seller' => 'Kerajinan Ampel',  'rating' => 4.5, 'category' => 'fashion'],
        ['id' => 7, 'name' => 'Sambal Bu Rudy',             'image' => 'sambal.jpeg', 'price' => 'Rp 55.000', 'seller' => 'Bu Rudy Original', 'rating' => 4.9, 'category' => 'food'],
        ['id' => 8, 'name' => 'Topeng Seni Surabaya',       'image' => 'topeng.jpeg', 'price' => 'Rp 150.000','seller' => 'Seniman Lokal',    'rating' => 4.6, 'category' => 'craft'],
        ['id' => 9, 'name' => 'Batik Tulis Peneleh',        'image' => 'batik tulis peneleh.jpeg', 'price' => 'Rp 250.000','seller' => 'Batik Peneleh',   'rating' => 4.8, 'category' => 'fashion'],
        ['id' => 10,'name' => 'Abon Ikan Tenggiri',         'image' => 'abon.jpg', 'price' => 'Rp 40.000', 'seller' => 'UMKM Kenjeran',   'rating' => 4.6, 'category' => 'food'],
        ['id' => 11,'name' => 'Miniatur Kapal Pinisi',      'image' => 'miniatur kapal pinisi.jpeg', 'price' => 'Rp 95.000', 'seller' => 'Galeri Kalimas',  'rating' => 4.7, 'category' => 'craft'],
    ];
    return view('pages.umkm', compact('products'));
})->name('umkm');
