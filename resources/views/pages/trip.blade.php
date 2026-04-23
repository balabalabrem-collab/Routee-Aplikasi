@extends('layouts.app')

@section('title', 'Trip Planner — Routee Surabaya')

@section('content')

<!-- LOADING OVERLAY — simulates "generating" feel -->
<div class="trip-loading" id="trip-loading">
    <div class="trip-loading-inner">
        <div class="loading-spinner"></div>
        <h3>Mengoptimasi Rute...</h3>
        <p>Routee sedang menyusun itinerary terbaik untukmu</p>
        <div class="loading-steps">
            <div class="ls-item" id="ls-1">✅ Menganalisis destinasi</div>
            <div class="ls-item" id="ls-2">⏳ Menghitung jarak tempuh</div>
            <div class="ls-item" id="ls-3">⏳ Menyusun jadwal optimal</div>
            <div class="ls-item" id="ls-4">⏳ Menemukan kuliner terdekat</div>
        </div>
    </div>
</div>

<!-- TRIP CONTENT (hidden until loading done) -->
<div id="trip-content" style="opacity:0;">

    <!-- PAGE HERO -->
    <div class="page-hero page-hero-sm trip-hero">
        <div class="container">
            <div class="trip-hero-labels">
                <span class="hero-smart-label">🧠 Smart Route</span>
                <span class="hero-smart-label hero-smart-best">🏆 Best for 1-Day Trip</span>
                <span class="hero-smart-label hero-smart-opt">✅ Optimized Route</span>
            </div>
            <span class="section-label">Itinerary Otomatis</span>
            <h1>Quick Trip Mode</h1>
            <p>Rute 1-hari Surabaya Heritage &amp; Culinary yang sudah dioptimasi untuk kamu.</p>
        </div>
    </div>

    <section class="section" id="trip-result">
        <div class="container">

            <!-- TRIP SUMMARY BAR -->
            <div class="trip-summary-bar">
                <div class="trip-stat">
                    <span class="trip-stat-icon">⏱</span>
                    <div>
                        <span class="trip-stat-num">8 Jam</span>
                        <span class="trip-stat-label">Total Durasi</span>
                    </div>
                </div>
                <div class="trip-stat">
                    <span class="trip-stat-icon">📍</span>
                    <div>
                        <span class="trip-stat-num">3 Dest.</span>
                        <span class="trip-stat-label">Destinasi</span>
                    </div>
                </div>
                <div class="trip-stat">
                    <span class="trip-stat-icon">🍜</span>
                    <div>
                        <span class="trip-stat-num">2 Kuliner</span>
                        <span class="trip-stat-label">Rekomendasi</span>
                    </div>
                </div>
                <div class="trip-stat trip-stat-highlight">
                    <span class="trip-stat-icon">💰</span>
                    <div>
                        <span class="trip-stat-num">Rp 150.000</span>
                        <span class="trip-stat-label">Total Biaya</span>
                    </div>
                </div>
            </div>

            <div class="trip-layout">

                <!-- ── ITINERARY TIMELINE ── -->
                <div class="trip-timeline-wrap">
                    <div class="trip-title-row">
                        <h2 class="trip-section-title">📅 Itinerary Hari Ini</h2>
                        <span class="trip-date-badge">Senin, 23 Apr 2025</span>
                    </div>

                    <div class="timeline" id="trip-timeline">

                        <!-- STOP 1 -->
                        <div class="timeline-item" id="tl-maspati">
                            <div class="tl-time">
                                <span class="tl-hr">08:00</span>
                                <span class="tl-period">WIB</span>
                            </div>
                            <div class="tl-connector">
                                <div class="tl-dot tl-dot-start"></div>
                                <div class="tl-line"></div>
                            </div>
                            <div class="tl-card">
                                <div class="tl-card-img">
                                    <!-- IMAGE: Kampung Lawas Maspati -->
                                    <img src="/images/maspati.jpg" alt="Kampung Lawas Maspati"
                                         onerror="this.src='/images/placeholder.jpg'">
                                </div>
                                <div class="tl-card-body">
                                    <div class="tl-badge-row">
                                        <div class="tl-badge">Heritage • Stop 1</div>
                                        <span class="tl-rating-sm">★ 4.5</span>
                                    </div>
                                    <h3>Kampung Lawas Maspati</h3>
                                    <p>Mulai perjalanan dengan menelusuri gang-gang bersejarah Maspati. Temui warga, lestarikan budaya.</p>
                                    <div class="tl-meta">
                                        <span>⏱ 45–60 menit</span>
                                        <span>🎟 Gratis</span>
                                        <span>📍 Bubutan</span>
                                    </div>
                                    <div class="tl-actions">
                                        <a href="{{ route('detail', 'maspati') }}" class="btn btn-sm btn-outline">Lihat Detail</a>
                                        <a href="{{ route('map') }}" class="btn btn-sm btn-primary">Navigasi</a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- TRANSIT 1 -->
                        <div class="tl-transit">
                            <div class="transit-line"></div>
                            <div class="transit-info">
                                <span class="transit-icon">🛵</span>
                                <span>±10 menit perjalanan · 1.2 km</span>
                            </div>
                            <div class="transit-line"></div>
                        </div>

                        <!-- STOP 2 -->
                        <div class="timeline-item" id="tl-tjokro">
                            <div class="tl-time">
                                <span class="tl-hr">10:00</span>
                                <span class="tl-period">WIB</span>
                            </div>
                            <div class="tl-connector">
                                <div class="tl-dot"></div>
                                <div class="tl-line"></div>
                            </div>
                            <div class="tl-card">
                                <div class="tl-card-img">
                                    <!-- IMAGE: Rumah HOS Tjokroaminoto -->
                                    <img src="/images/tjokroaminoto.jpg" alt="Rumah HOS Tjokroaminoto"
                                         onerror="this.src='/images/placeholder.jpg'">
                                </div>
                                <div class="tl-card-body">
                                    <div class="tl-badge-row">
                                        <div class="tl-badge">Heritage • Stop 2</div>
                                        <span class="tl-rating-sm">★ 4.7</span>
                                    </div>
                                    <h3>Rumah HOS Tjokroaminoto</h3>
                                    <p>Menelusuri jejak guru bangsa dan kos Bung Karno muda. Sejarah yang membentuk Indonesia.</p>
                                    <div class="tl-meta">
                                        <span>⏱ 30–45 menit</span>
                                        <span>🎟 Rp 5.000</span>
                                        <span>📍 Peneleh</span>
                                    </div>
                                    <div class="tl-actions">
                                        <a href="{{ route('detail', 'tjokroaminoto') }}" class="btn btn-sm btn-outline">Lihat Detail</a>
                                        <a href="{{ route('map') }}" class="btn btn-sm btn-primary">Navigasi</a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- TRANSIT 2: LUNCH -->
                        <div class="tl-transit tl-transit-food">
                            <div class="transit-line"></div>
                            <div class="transit-info">
                                <span class="transit-icon">🍽️</span>
                                <span>Waktu makan siang</span>
                            </div>
                            <div class="transit-line"></div>
                        </div>

                        <!-- LUNCH -->
                        <div class="timeline-item" id="tl-rawon">
                            <div class="tl-time">
                                <span class="tl-hr">12:00</span>
                                <span class="tl-period">WIB</span>
                            </div>
                            <div class="tl-connector">
                                <div class="tl-dot tl-dot-food"></div>
                                <div class="tl-line"></div>
                            </div>
                            <div class="tl-card tl-card-food">
                                <div class="tl-card-img">
                                    <!-- IMAGE: Rawon Setan -->
                                    <img src="/images/rawon.jpg" alt="Rawon Setan"
                                         onerror="this.src='/images/placeholder.jpg'">
                                </div>
                                <div class="tl-card-body">
                                    <div class="tl-badge-row">
                                        <div class="tl-badge tl-badge-food">🍜 Kuliner · Makan Siang</div>
                                    </div>
                                    <h3>Rawon Setan</h3>
                                    <p>Rawon hitam pekat khas Surabaya — kuliner ikonik yang wajib dicoba!</p>
                                    <div class="tl-meta">
                                        <span>⏱ 30–45 menit</span>
                                        <span>💰 Rp 30.000–45.000</span>
                                        <span>📍 ≤ 500m</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- TRANSIT 3 -->
                        <div class="tl-transit">
                            <div class="transit-line"></div>
                            <div class="transit-info">
                                <span class="transit-icon">🛵</span>
                                <span>±15 menit perjalanan · 3.4 km</span>
                            </div>
                            <div class="transit-line"></div>
                        </div>

                        <!-- STOP 3 -->
                        <div class="timeline-item" id="tl-dejavasche">
                            <div class="tl-time">
                                <span class="tl-hr">13:30</span>
                                <span class="tl-period">WIB</span>
                            </div>
                            <div class="tl-connector">
                                <div class="tl-dot"></div>
                                <div class="tl-line"></div>
                            </div>
                            <div class="tl-card">
                                <div class="tl-card-img">
                                    <!-- IMAGE: Gedung De Javasche Bank -->
                                    <img src="/images/dejavasche.jpg" alt="Gedung De Javasche Bank"
                                         onerror="this.src='/images/placeholder.jpg'">
                                </div>
                                <div class="tl-card-body">
                                    <div class="tl-badge-row">
                                        <div class="tl-badge">Heritage • Stop 3</div>
                                        <span class="tl-rating-sm">★ 4.6</span>
                                    </div>
                                    <h3>Gedung De Javasche Bank</h3>
                                    <p>Museum perbankan kolonial dengan arsitektur megah di kawasan kota lama Surabaya.</p>
                                    <div class="tl-meta">
                                        <span>⏱ 45–60 menit</span>
                                        <span>🎟 Rp 5.000</span>
                                        <span>📍 Krembangan</span>
                                    </div>
                                    <div class="tl-actions">
                                        <a href="{{ route('detail', 'dejavasche') }}" class="btn btn-sm btn-outline">Lihat Detail</a>
                                        <a href="{{ route('map') }}" class="btn btn-sm btn-primary">Navigasi</a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- TRANSIT 4: SNACK -->
                        <div class="tl-transit tl-transit-food">
                            <div class="transit-line"></div>
                            <div class="transit-info">
                                <span class="transit-icon">☕</span>
                                <span>Kuliner sore</span>
                            </div>
                            <div class="transit-line"></div>
                        </div>

                        <!-- SNACK -->
                        <div class="timeline-item" id="tl-lontong">
                            <div class="tl-time">
                                <span class="tl-hr">15:30</span>
                                <span class="tl-period">WIB</span>
                            </div>
                            <div class="tl-connector">
                                <div class="tl-dot tl-dot-food"></div>
                                <div class="tl-line tl-line-last"></div>
                            </div>
                            <div class="tl-card tl-card-food">
                                <div class="tl-card-img">
                                    <!-- IMAGE: Lontong Balap -->
                                    <img src="/images/lontong.jpg" alt="Lontong Balap"
                                         onerror="this.src='/images/placeholder.jpg'">
                                </div>
                                <div class="tl-card-body">
                                    <div class="tl-badge-row">
                                        <div class="tl-badge tl-badge-food">🍜 Kuliner · Sore</div>
                                    </div>
                                    <h3>Lontong Balap</h3>
                                    <p>Penutup perjalanan yang sempurna — kuliner khas yang menghangatkan perut dan jiwa.</p>
                                    <div class="tl-meta">
                                        <span>⏱ 20–30 menit</span>
                                        <span>💰 Rp 20.000–30.000</span>
                                        <span>📍 ≤ 500m</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- END -->
                        <div class="tl-end">
                            <div class="tl-end-marker">
                                <span>🏁</span>
                            </div>
                            <div class="tl-end-info">
                                <strong>Selesai ~16:00 WIB</strong>
                                <span>Total trip: 8 jam · Estimasi biaya: Rp 150.000</span>
                            </div>
                        </div>

                    </div><!-- /timeline -->
                </div><!-- /trip-timeline-wrap -->

                <!-- ── SIDEBAR ── -->
                <div class="trip-sidebar">

                    <!-- VIEW ROUTE CTA -->
                    <a href="{{ route('map') }}" class="view-route-btn" id="view-route-btn">
                        <span class="vrb-icon">🗺️</span>
                        <div class="vrb-text">
                            <strong>View Route</strong>
                            <span>Lihat peta perjalananmu</span>
                        </div>
                        <span class="vrb-arrow">→</span>
                    </a>

                    <!-- COST BREAKDOWN -->
                    <div class="sidebar-card" id="cost-card">
                        <div class="sidebar-card-header">
                            <h3>💰 Estimasi Biaya</h3>
                            <span class="sidebar-badge">Terjangkau</span>
                        </div>
                        <div class="cost-rows">
                            <div class="cost-row">
                                <span>🎟 Tiket Destinasi</span>
                                <span>Rp 10.000</span>
                            </div>
                            <div class="cost-row">
                                <span>🍜 Kuliner</span>
                                <span>Rp 70.000</span>
                            </div>
                            <div class="cost-row">
                                <span>🛵 Transport (Motor)</span>
                                <span>Rp 70.000</span>
                            </div>
                            <div class="cost-divider"></div>
                            <div class="cost-row cost-total">
                                <span>Total</span>
                                <span>Rp 150.000</span>
                            </div>
                        </div>
                    </div>

                    <!-- TRANSPORT -->
                    <div class="sidebar-card" id="transport-card">
                        <h3>🛵 Transportasi</h3>
                        <p>Rekomendasi: <strong>Motor</strong> — fleksibel untuk kawasan heritage yang sempit.</p>
                        <div class="transport-opts">
                            <div class="transport-opt transport-opt-rec">
                                <span>🛵 Motor</span>
                                <span>Rp 70rb/hari</span>
                            </div>
                            <div class="transport-opt">
                                <span>🚗 Mobil</span>
                                <span>Rp 300rb/hari</span>
                            </div>
                        </div>
                        <a href="{{ route('transport') }}" class="btn btn-outline btn-block" id="trip-transport-btn" style="margin-top:1rem;">
                            Lihat Semua Pilihan →
                        </a>
                    </div>

                    <!-- TIPS -->
                    <div class="sidebar-card tips-card" id="tips-card">
                        <h3>💡 Tips Perjalanan</h3>
                        <ul class="tips-list">
                            <li>Mulai pagi sebelum 08:00 agar tidak terik</li>
                            <li>Bawa uang tunai untuk tiket &amp; kuliner</li>
                            <li>Pakai baju sopan saat ke situs religi</li>
                            <li>Bawa minum &amp; sun screen</li>
                        </ul>
                    </div>

                    <!-- EXPLORE MORE -->
                    <a href="{{ route('explore') }}" class="btn btn-outline btn-block" style="margin-top:.5rem;">
                        🔍 Explore Destinasi Lain
                    </a>

                </div><!-- /trip-sidebar -->

            </div><!-- /trip-layout -->
        </div><!-- /container -->
    </section>

</div><!-- /trip-content -->

@endsection

@section('scripts')
<script>
// ── TRIP LOADING SIMULATION ──────────────────────────
(function() {
    const loading = document.getElementById('trip-loading');
    const content = document.getElementById('trip-content');
    // Only animate if coming fresh (not back navigation)
    const visited = sessionStorage.getItem('trip_visited');

    if (visited) {
        // Skip loading if already visited this session
        loading.style.display = 'none';
        content.style.opacity = '1';
        return;
    }

    sessionStorage.setItem('trip_visited', '1');

    const steps = [
        { id: 'ls-2', delay: 500 },
        { id: 'ls-3', delay: 1000 },
        { id: 'ls-4', delay: 1500 },
    ];

    steps.forEach(({ id, delay }) => {
        setTimeout(() => {
            const el = document.getElementById(id);
            if (el) el.textContent = el.textContent.replace('⏳', '✅');
        }, delay);
    });

    setTimeout(() => {
        loading.style.opacity = '0';
        loading.style.transition = 'opacity 0.5s ease';
        setTimeout(() => {
            loading.style.display = 'none';
            content.style.opacity = '1';
            content.style.transition = 'opacity 0.6s ease';
        }, 500);
    }, 2200);
})();

// ── HIGHLIGHT CURRENT TIME SLOT ──────────────────────
(function() {
    const now = new Date();
    const h = now.getHours();
    let active = null;
    if (h < 10)       active = 'tl-maspati';
    else if (h < 12)  active = 'tl-tjokro';
    else if (h < 13)  active = 'tl-rawon';
    else if (h < 15)  active = 'tl-dejavasche';
    else if (h < 17)  active = 'tl-lontong';
    if (active) {
        const el = document.getElementById(active);
        if (el) el.classList.add('tl-item-now');
    }
})();
</script>
@endsection
