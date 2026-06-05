@extends('layouts.app')

@section('title', 'Routee — Where to go today?')

@section('content')

<!-- ===== HERO ===== -->
<section class="hero" id="hero">
    <div class="hero-bg-shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
    </div>

    <div class="hero-content animate-fade-up">
        <!-- LOGO: Routee Main Logo on Hero -->
        <div class="hero-logo">
            <img src="/images/logo.png" alt="Routee Logo" class="hero-logo-img"
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='block'">
            <span class="hero-logo-fallback" style="display:none">Routee</span>
        </div>

        <div class="hero-badge">
            <span class="pulse-dot"></span>
            Surabaya Heritage &amp; Culinary Trip
        </div>

        <h1 class="hero-headline">Where to go<br><span class="highlight">today?</span></h1>

        <p class="hero-sub">
            Temukan hidden gems, situs heritage, dan kuliner legendaris Surabaya
            dalam 1 hari perjalanan yang efisien dan berkesan.
        </p>

        <div class="hero-actions">
            <a href="{{ route('trip') }}" class="btn btn-primary btn-lg btn-animated" id="hero-plan-btn">
                <span class="btn-icon">🗺️</span>
                <span class="btn-text">Plan My 1-Day Trip</span>
                <span class="btn-arrow">→</span>
            </a>
            <a href="{{ route('explore') }}" class="btn btn-outline btn-lg" id="hero-explore-btn">
                Explore Destinasi
            </a>
        </div>

        <div class="hero-stats">
            <div class="stat-item">
                <span class="stat-num" data-target="5">5+</span>
                <span class="stat-label">Destinasi</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
                <span class="stat-num">8 jam</span>
                <span class="stat-label">1-Day Trip</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
                <span class="stat-num">Rp150rb</span>
                <span class="stat-label">Estimasi Biaya</span>
            </div>
        </div>

    </div>

    <div class="hero-visual">
        <div class="hero-card-stack animate-float">
            <div class="hcard hcard-back">
                <!-- IMAGE: Masjid Cheng Hoo -->
                <img src="/images/chenghoo.jpg" alt="Masjid Cheng Hoo"
                     onerror="this.src='/images/placeholder.jpg'">
                <div class="hcard-overlay"><span>Masjid Cheng Hoo</span></div>
            </div>
            <div class="hcard hcard-mid">
                <!-- IMAGE: Makam Sunan Ampel -->
                <img src="/images/ampel.jpg" alt="Makam Sunan Ampel"
                     onerror="this.src='/images/placeholder.jpg'">
                <div class="hcard-overlay"><span>Makam Sunan Ampel</span></div>
            </div>
            <div class="hcard hcard-front" id="hero-card-front">
                <!-- IMAGE: Kampung Lawas Maspati -->
                <img src="/images/maspati.jpg" alt="Kampung Lawas Maspati"
                     onerror="this.src='/images/placeholder.jpg'">
                <div class="hcard-overlay">
                    <span>📍 Kampung Maspati</span>
                    <span class="hcard-rating">★ 4.5</span>
                </div>
            </div>
        </div>

        <!-- FLOATING BADGE -->
        <div class="hero-float-badge">
            <span class="float-badge-icon">🏆</span>
            <div>
                <strong>Best for 1-Day Trip</strong>
                <span>Optimized Route</span>
            </div>
        </div>
    </div>
</section>

<!-- ===== HOW IT WORKS ===== -->
<section class="section how-it-works" id="how-it-works">
    <div class="container">
        <div class="section-header">
            <span class="section-label">Cara Kerja</span>
            <h2>Perjalanan Cerdas dalam 3 Langkah</h2>
            <p>Routee merancang itinerary paling efisien berdasarkan waktu dan preferensimu secara otomatis.</p>
        </div>
        <div class="steps-grid">
            <a href="{{ route('explore') }}" class="step-card" id="step-1">
                <div class="step-num-bg">01</div>
                <div class="step-icon">🎯</div>
                <h3>Pilih Preferensi</h3>
                <p>Heritage, religi, atau kuliner? Pilih sesuai minatmu dan biarkan Routee bekerja.</p>
                <span class="step-link">Lihat Destinasi →</span>
            </a>
            <div class="step-arrow-wrap">
                <div class="step-arrow">→</div>
            </div>
            <a href="{{ route('trip') }}" class="step-card" id="step-2">
                <div class="step-num-bg">02</div>
                <div class="step-icon">🗺️</div>
                <h3>Generate Itinerary</h3>
                <p>Algoritma Routee menyusun urutan destinasi paling efisien untuk menghemat waktu & biaya.</p>
                <span class="step-link">Lihat Itinerary →</span>
            </a>
            <div class="step-arrow-wrap">
                <div class="step-arrow">→</div>
            </div>
            <a href="{{ route('map') }}" class="step-card" id="step-3">
                <div class="step-num-bg">03</div>
                <div class="step-icon">🚀</div>
                <h3>Mulai Perjalanan!</h3>
                <p>Ikuti rute yang telah disiapkan dan nikmati pengalaman terbaik Surabaya dalam 1 hari.</p>
                <span class="step-link">Lihat Peta →</span>
            </a>
        </div>
        <div style="text-align:center;margin-top:2.5rem;">
            <a href="{{ route('trip') }}" class="btn btn-primary btn-lg" id="steps-cta-btn">
                🗺️ Mulai Rencanakan Trip →
            </a>
        </div>
    </div>
</section>

<!-- ===== DESTINATIONS ===== -->
<section class="section destinations-section" id="destinations">
    <div class="container">
        <div class="section-header">
            <span class="section-label">Hidden Gems</span>
            <h2>Destinasi Heritage Surabaya</h2>
            <p>Tempat-tempat bersejarah yang kaya cerita, menunggu untuk kamu jelajahi.</p>
        </div>
        <div class="dest-grid">

            <!-- CARD: Kampung Lawas Maspati -->
            <a href="{{ route('detail', 'maspati') }}" class="dest-card" id="dest-maspati">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Kampung Lawas Maspati -->
                    <img src="/images/maspati.jpg" alt="Kampung Lawas Maspati"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Kampung Lawas Maspati</h3>
                    <p>Kawasan pemukiman kolonial yang masih terawat di pusat kota.</p>
                    <div class="dest-meta">
                        <span>⏱ 45–60 menit</span>
                        <span class="dest-rating">★ 4.5</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>



            <!-- CARD: Masjid Cheng Hoo -->
            <a href="{{ route('detail', 'chenghoo') }}" class="dest-card" id="dest-chenghoo">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Masjid Cheng Hoo -->
                    <img src="/images/chenghoo.jpg" alt="Masjid Cheng Hoo"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge dest-badge-religi">Religi</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Masjid Cheng Hoo</h3>
                    <p>Masjid bergaya Tionghoa — simbol akulturasi budaya yang indah di Surabaya.</p>
                    <div class="dest-meta">
                        <span>⏱ 30–45 menit</span>
                        <span class="dest-rating">★ 4.8</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Makam Sunan Ampel -->
            <a href="{{ route('detail', 'ampel') }}" class="dest-card" id="dest-ampel">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Makam Sunan Ampel -->
                    <img src="/images/ampel.jpg" alt="Makam Sunan Ampel"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge dest-badge-religi">Religi</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Makam Sunan Ampel</h3>
                    <p>Pusat ziarah dan wisata religi Wali Songo di jantung Surabaya.</p>
                    <div class="dest-meta">
                        <span>⏱ 45–60 menit</span>
                        <span class="dest-rating">★ 4.9</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: De Javasche Bank -->
            <a href="{{ route('detail', 'dejavasche') }}" class="dest-card" id="dest-dejavasche">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Gedung De Javasche Bank -->
                    <img src="/images/dejavasche.jpg" alt="Gedung De Javasche Bank"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Gedung De Javasche Bank</h3>
                    <p>Museum perbankan bersejarah di kawasan kota lama Surabaya.</p>
                    <div class="dest-meta">
                        <span>⏱ 45–60 menit</span>
                        <span class="dest-rating">★ 4.6</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>
            <!-- CARD: Jalan Tunjungan -->
            <a href="{{ route('detail', 'tunjungan') }}" class="dest-card" id="dest-tunjungan">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Jalan Tunjungan -->
                    <img src="/images/tunjungan.jpg" alt="Jalan Tunjungan"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Jalan Tunjungan</h3>
                    <p>Jantung kota lama Surabaya yang melegenda. Deretan gedung kolonial, Hotel Majapahit bersejarah, dan bazar malam.</p>
                    <div class="dest-meta">
                        <span>⏱ 45–90 menit</span>
                        <span class="dest-rating">★ 4.6</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Gedung Siola -->
            <a href="{{ route('detail', 'gedung-siola') }}" class="dest-card" id="dest-siola">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Museum Surabaya (Gedung Siola) -->
                    <img src="/images/siola.jpg" alt="Museum Surabaya (Gedung Siola)"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Museum Surabaya (Siola)</h3>
                    <p>Gedung putih megah era kolonial yang kini menjadi Museum Surabaya, menyimpan ribuan koleksi artefak dan peta kuno.</p>
                    <div class="dest-meta">
                        <span>⏱ 60–90 menit</span>
                        <span class="dest-rating">★ 4.5</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Kawasan Kota Lama -->
            <a href="{{ route('detail', 'kota-lama') }}" class="dest-card" id="dest-kotalama">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Kawasan Kota Lama -->
                    <img src="/images/kota-lama.jpg" alt="Kawasan Kota Lama"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Kawasan Kota Lama</h3>
                    <p>Pusat perdagangan kolonial abad 17, deretan gudang tua dan jembatan bersejarah dengan lanskap yang memikat.</p>
                    <div class="dest-meta">
                        <span>⏱ 60–90 menit</span>
                        <span class="dest-rating">★ 4.7</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Klenteng Kenjeran -->
            <a href="{{ route('detail', 'klenteng-kenjeran') }}" class="dest-card" id="dest-kenjeran">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Klenteng Kenjeran -->
                    <img src="/images/kenjeran.jpg" alt="Klenteng Kenjeran"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge dest-badge-religi">Religi</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Klenteng Sanggar Agung</h3>
                    <p>Klenteng megah di tepi pantai Kenjeran dengan patung Dewi Kwan Im raksasa menghadap laut yang fotogenik.</p>
                    <div class="dest-meta">
                        <span>⏱ 30–45 menit</span>
                        <span class="dest-rating">★ 4.6</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Alun-Alun Surabaya -->
            <a href="{{ route('detail', 'alun-alun') }}" class="dest-card" id="dest-alunalun">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Alun-Alun Surabaya -->
                    <img src="/images/alun-alun.jpg" alt="Alun-Alun Surabaya"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Alun-Alun Surabaya</h3>
                    <p>Ruang publik kekinian di kompleks bawah tanah Balai Pemuda. Pusat seni, budaya, dan hiburan modern dengan semangat masa lalu.</p>
                    <div class="dest-meta">
                        <span>⏱ 45–60 menit</span>
                        <span class="dest-rating">★ 4.8</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Taman Bungkul -->
            <a href="{{ route('detail', 'taman-bungkul') }}" class="dest-card" id="dest-bungkul">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Taman Bungkul -->
                    <img src="/images/bungkul.jpg" alt="Taman Bungkul"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Taman Bungkul</h3>
                    <p>Taman kota pemenang penghargaan internasional. Pusat rekreasi asri dengan wisata religi makam Sunan Bungkul di dalamnya.</p>
                    <div class="dest-meta">
                        <span>⏱ 30–45 menit</span>
                        <span class="dest-rating">★ 4.7</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

            <!-- CARD: Monumen Kapal Selam -->
            <a href="{{ route('detail', 'kalimas') }}" class="dest-card" id="dest-kalimas">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Monumen Kapal Selam Kalimas -->
                    <img src="/images/kapal-selam.jpg" alt="Monumen Kapal Selam Kalimas"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Monumen Kapal Selam</h3>
                    <p>Kapal selam KRI Pasopati asli yang difungsikan jadi monumen dan museum sejarah maritim di tepi Kali Mas.</p>
                    <div class="dest-meta">
                        <span>⏱ 45–60 menit</span>
                        <span class="dest-rating">★ 4.5</span>
                    </div>
                    <div class="dest-cta">Lihat Detail →</div>
                </div>
            </a>

        </div>
        <div class="section-actions">
            <a href="{{ route('explore') }}" class="btn btn-outline btn-lg" id="all-dest-btn">
                Lihat Semua Destinasi →
            </a>
        </div>
    </div>
</section>

<!-- ===== CULINARY ===== -->
<section class="section culinary-section" id="culinary">
    <div class="container">
        <div class="section-header">
            <span class="section-label">Kuliner Legendaris</span>
            <h2>Wajib Dicoba Saat di Surabaya</h2>
            <p>Kuliner otentik dalam jangkauan ≤500m dari rute perjalananmu.</p>
        </div>
        <div class="culinary-grid">

            <!-- RAWON SETAN -->
            <a href="{{ route('detail', 'rawon') }}" class="culinary-card" id="culinary-rawon">
                <div class="culinary-img-wrap">
                    <!-- IMAGE: Rawon Setan -->
                    <img src="/images/rawon.jpg" alt="Rawon Setan"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="culinary-badge"><span>📍 ≤ 500m</span></div>
                </div>
                <div class="culinary-info">
                    <div class="culinary-header">
                        <h3>Rawon Setan</h3>
                        <span class="culinary-rating">★ 4.8</span>
                    </div>
                    <p>Rawon hitam pekat dengan kuah kluwek kaya rempah dan daging sapi empuk. Legenda kuliner Surabaya!</p>
                    <div class="culinary-meta">
                        <span>⏱ 30–45 menit</span>
                        <span>💰 Rp 30.000 – 45.000</span>
                    </div>
                    <div class="dest-cta" style="margin-top:.6rem;">Lihat Detail →</div>
                </div>
            </a>

            <!-- LONTONG BALAP -->
            <a href="{{ route('detail', 'lontong-balap') }}" class="culinary-card" id="culinary-lontong">
                <div class="culinary-img-wrap">
                    <!-- IMAGE: Lontong Balap -->
                    <img src="/images/lontong.jpg" alt="Lontong Balap"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="culinary-badge"><span>📍 ≤ 500m</span></div>
                </div>
                <div class="culinary-info">
                    <div class="culinary-header">
                        <h3>Lontong Balap</h3>
                        <span class="culinary-rating">★ 4.7</span>
                    </div>
                    <p>Sajian khas lontong, tahu, lentho, tauge, dan petis udang. Sarapan favorit warga Surabaya sejak dekade lalu.</p>
                    <div class="culinary-meta">
                        <span>⏱ 20–30 menit</span>
                        <span>💰 Rp 20.000 – 30.000</span>
                    </div>
                    <div class="dest-cta" style="margin-top:.6rem;">Lihat Detail →</div>
                </div>
            </a>

            <!-- RUJAK CINGUR -->
            <a href="{{ route('detail', 'rujak-cingur') }}" class="culinary-card" id="culinary-rujak">
                <div class="culinary-img-wrap">
                    <!-- IMAGE: Rujak Cingur -->
                    <img src="/images/rujak.jpeg" alt="Rujak Cingur"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="culinary-badge"><span>📍 ≤ 1km</span></div>
                </div>
                <div class="culinary-info">
                    <div class="culinary-header">
                        <h3>Rujak Cingur</h3>
                        <span class="culinary-rating">★ 4.7</span>
                    </div>
                    <p>Rujak khas Jawa Timur dengan irisan cingur, sayuran, dan bumbu petis pekat.</p>
                    <div class="culinary-meta">
                        <span>⏱ 20–30 menit</span>
                        <span>💰 Rp 20.000 – 35.000</span>
                    </div>
                    <div class="dest-cta" style="margin-top:.6rem;">Lihat Detail →</div>
                </div>
            </a>

            <!-- SOTO PAK SADI -->
            <a href="{{ route('detail', 'soto-pak-sadi') }}" class="culinary-card" id="culinary-soto">
                <div class="culinary-img-wrap">
                    <!-- IMAGE: Soto Pak Sadi -->
                    <img src="/images/soto-sadi.jpg" alt="Soto Pak Sadi"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="culinary-badge"><span>📍 ≤ 500m</span></div>
                </div>
                <div class="culinary-info">
                    <div class="culinary-header">
                        <h3>Soto Pak Sadi</h3>
                        <span class="culinary-rating">★ 4.7</span>
                    </div>
                    <p>Soto Surabaya legendaris dengan kuah bening kaya rempah, ayam kampung, dan tauge.</p>
                    <div class="culinary-meta">
                        <span>⏱ 20–30 menit</span>
                        <span>💰 Rp 18.000 – 28.000</span>
                    </div>
                    <div class="dest-cta" style="margin-top:.6rem;">Lihat Detail →</div>
                </div>
            </a>

            <!-- TAHU TEK -->
            <a href="{{ route('detail', 'tahu-tek') }}" class="culinary-card" id="culinary-tahutek">
                <div class="culinary-img-wrap">
                    <!-- IMAGE: Tahu Tek -->
                    <img src="/images/tahu-tek.jpg" alt="Tahu Tek"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="culinary-badge"><span>📍 ≤ 1km</span></div>
                </div>
                <div class="culinary-info">
                    <div class="culinary-header">
                        <h3>Tahu Tek</h3>
                        <span class="culinary-rating">★ 4.6</span>
                    </div>
                    <p>Tahu goreng setengah matang disiram bumbu kacang petis dan lontong.</p>
                    <div class="culinary-meta">
                        <span>⏱ 15–25 menit</span>
                        <span>💰 Rp 12.000 – 20.000</span>
                    </div>
                    <div class="dest-cta" style="margin-top:.6rem;">Lihat Detail →</div>
                </div>
            </a>

            <!-- ZANGRANDI -->
            <a href="{{ route('detail', 'zangrandi') }}" class="culinary-card" id="culinary-zangrandi">
                <div class="culinary-img-wrap">
                    <!-- IMAGE: Es Krim Zangrandi -->
                    <img src="/images/zangrandi.jpg" alt="Es Krim Zangrandi"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="culinary-badge"><span>📍 ≤ 500m</span></div>
                </div>
                <div class="culinary-info">
                    <div class="culinary-header">
                        <h3>Es Krim Zangrandi</h3>
                        <span class="culinary-rating">★ 4.8</span>
                    </div>
                    <p>Es krim legendaris Surabaya sejak 1933 dengan racikan Italia dan buah tropis.</p>
                    <div class="culinary-meta">
                        <span>⏱ 30–45 menit</span>
                        <span>💰 Rp 25.000 – 55.000</span>
                    </div>
                    <div class="dest-cta" style="margin-top:.6rem;">Lihat Detail →</div>
                </div>
            </a>

        </div>
    </div>
</section>

<!-- ===== CTA BANNER ===== -->
<section class="cta-banner" id="cta-banner">
    <div class="cta-bg-pattern"></div>
    <div class="container">
        <div class="cta-content">
            <div class="cta-icon">🗺️</div>
            <h2>Siap Jelajahi Surabaya?</h2>
            <p>Buat itinerary 1-hari terbaikmu sekarang — gratis, cepat, dan tanpa ribet.</p>
            <div class="cta-actions">
                <a href="{{ route('trip') }}" class="btn btn-white btn-lg" id="cta-final-btn">
                    🗺️ Plan My 1-Day Trip
                </a>
                <a href="{{ route('explore') }}" class="btn btn-outline-white btn-lg" id="cta-explore-btn">
                    Explore Dulu
                </a>
            </div>
            <div class="cta-features">
                <span>✅ Rute Dioptimasi</span>
                <span>✅ Estimasi Biaya Real</span>
                <span>✅ Tanpa Registrasi</span>
            </div>
        </div>
    </div>
</section>

@endsection
