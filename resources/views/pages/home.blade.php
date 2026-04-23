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

        <!-- TRUST BADGES -->
        <div class="trust-row">
            <span class="trust-item">✅ Rute Dioptimasi</span>
            <span class="trust-item">✅ Tanpa Login</span>
            <span class="trust-item">✅ Gratis 100%</span>
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

            <!-- CARD: Rumah HOS Tjokroaminoto -->
            <a href="{{ route('detail', 'tjokroaminoto') }}" class="dest-card" id="dest-tjokro">
                <div class="dest-img-wrap">
                    <!-- IMAGE: Rumah HOS Tjokroaminoto -->
                    <img src="/images/tjokroaminoto.jpg" alt="Rumah HOS Tjokroaminoto"
                         onerror="this.src='/images/placeholder.jpg'">
                    <span class="dest-badge">Heritage</span>
                    <div class="dest-img-overlay"></div>
                </div>
                <div class="dest-info">
                    <h3>Rumah HOS Tjokroaminoto</h3>
                    <p>Kos Bung Karno muda — rumah guru bangsa yang membentuk Indonesia.</p>
                    <div class="dest-meta">
                        <span>⏱ 30–45 menit</span>
                        <span class="dest-rating">★ 4.7</span>
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
            <div class="culinary-card" id="culinary-rawon">
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
                </div>
            </div>

            <!-- LONTONG BALAP -->
            <div class="culinary-card" id="culinary-lontong">
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
                </div>
            </div>

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
