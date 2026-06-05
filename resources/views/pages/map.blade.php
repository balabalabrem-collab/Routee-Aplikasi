@extends('layouts.app')

@section('title', 'Peta Rute — Routee Surabaya')

@section('content')

<div class="page-hero page-hero-sm">
    <div class="container">
        <span class="section-label">Navigasi</span>
        <h1>Peta Rute Perjalanan</h1>
        <p>Visualisasi jalur destinasi heritage Surabaya — dari terminal/stasiun menuju setiap situs bersejarah.</p>
    </div>
</div>

<section class="section" id="map-section">
    <div class="container">
        <div class="map-layout">

            <!-- SVG MAP -->
            <div class="map-container" id="fake-map">
                <div class="map-header">
                    <span class="map-label">🗺️ Peta Heritage Surabaya</span>
                    <span class="map-badge">7 Destinasi · ~12 km area</span>
                </div>

                <div class="map-visual">
                    <svg class="map-svg" viewBox="0 0 720 460" xmlns="http://www.w3.org/2000/svg">

                        <!-- Base map background – warm parchment -->
                        <rect width="720" height="460" fill="#f5ede0"/>

                        <!-- Water / Sungai Kalimas (blue strip top-left) -->
                        <path d="M0,60 Q120,80 200,70 Q280,60 320,90 Q360,120 400,100 Q440,80 480,95 Q520,110 560,100 L560,120 Q520,130 480,115 Q440,100 400,120 Q360,140 320,110 Q280,80 200,90 Q120,100 0,80 Z" fill="#b3d9f5" opacity="0.7"/>
                        <text x="80" y="78" fill="#5a9fc0" font-size="9" font-family="Poppins,sans-serif" font-weight="600">Sungai Kalimas</text>

                        <!-- Major roads – horizontal -->
                        <rect x="0" y="148" width="720" height="16" fill="#ddd0b8" rx="2"/> <!-- Jl. Kembang Jepun / Perak -->
                        <rect x="0" y="248" width="720" height="14" fill="#ddd0b8" rx="2"/> <!-- Jl. Bubutan -->
                        <rect x="0" y="340" width="720" height="14" fill="#ddd0b8" rx="2"/> <!-- Jl. Raya Darmo -->

                        <!-- Major roads – vertical -->
                        <rect x="148" y="0" width="14" height="460" fill="#ddd0b8" rx="2"/> <!-- Jl. Pahlawan -->
                        <rect x="310" y="0" width="14" height="460" fill="#ddd0b8" rx="2"/> <!-- Jl. Tunjungan -->
                        <rect x="510" y="0" width="14" height="460" fill="#ddd0b8" rx="2"/> <!-- Jl. Kenjeran -->

                        <!-- Minor roads -->
                        <line x1="0" y1="200" x2="720" y2="200" stroke="#e8dcc8" stroke-width="7"/>
                        <line x1="0" y1="290" x2="720" y2="290" stroke="#e8dcc8" stroke-width="7"/>
                        <line x1="230" y1="0" x2="230" y2="460" stroke="#e8dcc8" stroke-width="7"/>
                        <line x1="400" y1="0" x2="400" y2="460" stroke="#e8dcc8" stroke-width="7"/>
                        <line x1="610" y1="0" x2="610" y2="460" stroke="#e8dcc8" stroke-width="7"/>

                        <!-- Road labels -->
                        <text x="4" y="145" fill="#a89070" font-size="8.5" font-family="Poppins,sans-serif">Jl. Perak / Kembang Jepun</text>
                        <text x="4" y="245" fill="#a89070" font-size="8.5" font-family="Poppins,sans-serif">Jl. Bubutan</text>
                        <text x="4" y="337" fill="#a89070" font-size="8.5" font-family="Poppins,sans-serif">Jl. Raya Darmo</text>
                        <text x="152" y="12" fill="#a89070" font-size="8.5" font-family="Poppins,sans-serif" transform="rotate(90,152,12)">Jl. Pahlawan</text>
                        <text x="314" y="12" fill="#a89070" font-size="8.5" font-family="Poppins,sans-serif" transform="rotate(90,314,12)">Jl. Tunjungan</text>

                        <!-- ROUTE LINE: Kota Lama → Maspati → Tunjungan → Siola → Alun-Alun -->
                        <polyline
                            points="90,155 190,255 317,310 400,310 400,350 480,350"
                            fill="none" stroke="#D39858" stroke-width="3.5"
                            stroke-dasharray="10,5" stroke-linecap="round"
                            class="route-line"/>

                        <!-- ═══════════════════════════════
                             DESTINATION MARKERS
                             ═══════════════════════════════ -->

                        <!-- A: Kawasan Kota Lama (top-left near Kalimas) -->
                        <circle cx="88" cy="148" r="18" fill="#8A4E1E" stroke="white" stroke-width="2.5"/>
                        <text x="88" y="153" fill="white" font-size="10" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">A</text>
                        <rect x="42" y="120" width="92" height="22" rx="4" fill="white" opacity="0.92"/>
                        <text x="88" y="135" fill="#34150F" font-size="8.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Kota Lama</text>
                        <!-- pulse ring -->
                        <circle cx="88" cy="148" r="26" fill="none" stroke="#D39858" stroke-width="2" opacity="0.5">
                            <animate attributeName="r" values="18;32;18" dur="2.5s" repeatCount="indefinite"/>
                            <animate attributeName="opacity" values="0.5;0;0.5" dur="2.5s" repeatCount="indefinite"/>
                        </circle>

                        <!-- B: De Javasche Bank (near Kota Lama, slightly right) -->
                        <circle cx="155" cy="155" r="16" fill="#8A4E1E" stroke="white" stroke-width="2.5"/>
                        <text x="155" y="160" fill="white" font-size="9" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">B</text>
                        <rect x="110" y="128" width="92" height="22" rx="4" fill="white" opacity="0.92"/>
                        <text x="156" y="143" fill="#34150F" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">De Javasche Bank</text>

                        <!-- C: Maspati -->
                        <circle cx="190" cy="255" r="17" fill="#8A4E1E" stroke="white" stroke-width="2.5"/>
                        <text x="190" y="260" fill="white" font-size="10" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">C</text>
                        <rect x="150" y="228" width="80" height="22" rx="4" fill="white" opacity="0.92"/>
                        <text x="190" y="243" fill="#34150F" font-size="8.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Maspati</text>

                        <!-- Masjid Cheng Hoo (Religi – teal) -->
                        <circle cx="360" cy="230" r="15" fill="#2a9d8f" stroke="white" stroke-width="2.5"/>
                        <text x="360" y="235" fill="white" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif">🕌</text>
                        <rect x="310" y="208" width="100" height="20" rx="4" fill="white" opacity="0.92"/>
                        <text x="360" y="222" fill="#1a5c54" font-size="7.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Masjid Cheng Hoo</text>

                        <!-- D: Tunjungan -->
                        <circle cx="317" cy="310" r="17" fill="#8A4E1E" stroke="white" stroke-width="2.5"/>
                        <text x="317" y="315" fill="white" font-size="10" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">D</text>
                        <rect x="272" y="284" width="90" height="22" rx="4" fill="white" opacity="0.92"/>
                        <text x="317" y="299" fill="#34150F" font-size="8.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Jl. Tunjungan</text>

                        <!-- E: Siola / Museum Surabaya -->
                        <circle cx="400" cy="310" r="17" fill="#8A4E1E" stroke="white" stroke-width="2.5"/>
                        <text x="400" y="315" fill="white" font-size="10" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">E</text>
                        <rect x="354" y="284" width="92" height="22" rx="4" fill="white" opacity="0.92"/>
                        <text x="400" y="299" fill="#34150F" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Museum Siola</text>

                        <!-- F: Taman Bungkul -->
                        <circle cx="480" cy="350" r="17" fill="#8A4E1E" stroke="white" stroke-width="2.5"/>
                        <text x="480" y="355" fill="white" font-size="10" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">F</text>
                        <rect x="430" y="323" width="100" height="22" rx="4" fill="white" opacity="0.92"/>
                        <text x="480" y="338" fill="#34150F" font-size="8.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Taman Bungkul</text>

                        <!-- Sunan Ampel (Religi – teal, far right) -->
                        <circle cx="590" cy="165" r="15" fill="#2a9d8f" stroke="white" stroke-width="2.5"/>
                        <text x="590" y="170" fill="white" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif">🕌</text>
                        <rect x="542" y="143" width="96" height="20" rx="4" fill="white" opacity="0.92"/>
                        <text x="590" y="157" fill="#1a5c54" font-size="7.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">Makam Sunan Ampel</text>

                        <!-- Food markers -->
                        <circle cx="230" cy="195" r="13" fill="#e8834a" stroke="white" stroke-width="2"/>
                        <text x="230" y="200" fill="white" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif">🍜</text>
                        <text x="230" y="183" fill="#8A4E1E" font-size="7.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="600">Soto Pak Sadi</text>

                        <circle cx="355" cy="355" r="13" fill="#e8834a" stroke="white" stroke-width="2"/>
                        <text x="355" y="360" fill="white" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif">🍜</text>
                        <text x="355" y="342" fill="#8A4E1E" font-size="7.5" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="600">Rawon Setan</text>

                        <!-- Terminal markers (green) -->
                        <rect x="30" y="290" width="70" height="26" rx="6" fill="#27ae60" stroke="white" stroke-width="2"/>
                        <text x="65" y="307" fill="white" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">🚉 Pasar Turi</text>

                        <rect x="268" y="400" width="78" height="26" rx="6" fill="#27ae60" stroke="white" stroke-width="2"/>
                        <text x="307" y="417" fill="white" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">🚉 Wonokromo</text>

                        <rect x="490" y="400" width="72" height="26" rx="6" fill="#27ae60" stroke="white" stroke-width="2"/>
                        <text x="526" y="417" fill="white" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">🚌 Joyoboyo</text>

                        <rect x="600" y="290" width="62" height="26" rx="6" fill="#27ae60" stroke="white" stroke-width="2"/>
                        <text x="631" y="307" fill="white" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="700">🚉 Gubeng</text>

                    </svg>

                    <!-- LEGEND -->
                    <div class="map-legend">
                        <div class="legend-item"><span class="legend-dot" style="background:#8A4E1E"></span><span>Heritage</span></div>
                        <div class="legend-item"><span class="legend-dot" style="background:#2a9d8f"></span><span>Religi</span></div>
                        <div class="legend-item"><span class="legend-dot" style="background:#e8834a"></span><span>Kuliner</span></div>
                        <div class="legend-item"><span class="legend-dot" style="background:#27ae60"></span><span>Terminal / Stasiun</span></div>
                        <div class="legend-item"><span class="legend-line"></span><span>Rute Utama</span></div>
                    </div>
                </div>
            </div>

            <!-- SIDEBAR -->
            <div class="route-sidebar" style="max-height:85vh; overflow-y:auto;">
                <h2>📍 Semua Destinasi</h2>
                <p style="font-size:.82rem;color:var(--text-muted);margin-bottom:1.25rem;">17 destinasi tersebar di seluruh Surabaya</p>

                <!-- HERITAGE GROUP -->
                <div class="map-dest-group-label">🏛 Heritage</div>

                <div class="route-step">
                    <div class="route-step-marker marker-a">A</div>
                    <div class="route-step-info">
                        <h4>Kawasan Kota Lama</h4>
                        <span class="route-time">Jl. Veteran, Krembangan · Gratis · 60–90 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-b">B</div>
                    <div class="route-step-info">
                        <h4>Gedung De Javasche Bank</h4>
                        <span class="route-time">Jl. Garuda, Krembangan · Rp 5.000 · 45–60 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-a">C</div>
                    <div class="route-step-info">
                        <h4>Kampung Lawas Maspati</h4>
                        <span class="route-time">Jl. Maspati, Bubutan · Gratis · 45–60 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-a">D</div>
                    <div class="route-step-info">
                        <h4>Jalan Tunjungan</h4>
                        <span class="route-time">Jl. Tunjungan · Gratis · 45–90 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-b">E</div>
                    <div class="route-step-info">
                        <h4>Museum Surabaya (Siola)</h4>
                        <span class="route-time">Jl. Tunjungan No.1 · Gratis · 60–90 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-a">F</div>
                    <div class="route-step-info">
                        <h4>Gedung Siola</h4>
                        <span class="route-time">Jl. Tunjungan · Gratis · 30–45 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-b">G</div>
                    <div class="route-step-info">
                        <h4>Alun-Alun Surabaya</h4>
                        <span class="route-time">Jl. Jimerto · Gratis · 30–45 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-a">H</div>
                    <div class="route-step-info">
                        <h4>Taman Bungkul</h4>
                        <span class="route-time">Jl. Raya Darmo · Gratis · 30–60 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-b">I</div>
                    <div class="route-step-info">
                        <h4>Kawasan Kenjeran</h4>
                        <span class="route-time">Kenjeran, Surabaya · Rp 5.000 · 60–90 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker marker-a">J</div>
                    <div class="route-step-info">
                        <h4>Kalimas Boat Ride</h4>
                        <span class="route-time">Dermaga Kalimas · Rp 15.000 · 45–60 mnt</span>
                    </div>
                </div>

                <!-- RELIGI GROUP -->
                <div class="map-dest-group-label" style="background:rgba(42,157,143,.12);color:#1a5c54;border-color:#2a9d8f;">🕌 Religi</div>

                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">K</div>
                    <div class="route-step-info">
                        <h4>Masjid Cheng Hoo</h4>
                        <span class="route-time">Jl. Gading No.2, Ketabang · Gratis · 30–45 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">L</div>
                    <div class="route-step-info">
                        <h4>Makam Sunan Ampel</h4>
                        <span class="route-time">Jl. Ampel Masjid No.53 · Gratis · 45–60 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">M</div>
                    <div class="route-step-info">
                        <h4>Langgar Dukur Kayu</h4>
                        <span class="route-time">Peneleh, Surabaya · Gratis · 20–30 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">N</div>
                    <div class="route-step-info">
                        <h4>Klenteng Kya-Kya</h4>
                        <span class="route-time">Kembang Jepun · Gratis · 30–45 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">O</div>
                    <div class="route-step-info">
                        <h4>Kelenteng Sanggar Agung</h4>
                        <span class="route-time">Pantai Kenjeran · Gratis · 30–45 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">P</div>
                    <div class="route-step-info">
                        <h4>Masjid Agung Surabaya</h4>
                        <span class="route-time">Jl. Masjid Agung Tim. · Gratis · 30–45 mnt</span>
                    </div>
                </div>
                <div class="route-step">
                    <div class="route-step-marker" style="background:#2a9d8f;">Q</div>
                    <div class="route-step-info">
                        <h4>Makam Sunan Bungkul</h4>
                        <span class="route-time">Jl. Raya Darmo · Gratis · 20–30 mnt</span>
                    </div>
                </div>

                <div class="route-summary-box" style="margin-top:1.5rem;">
                    <div class="route-sum-row"><span>Total Destinasi</span><strong>16 Lokasi</strong></div>
                    <div class="route-sum-row"><span>Heritage</span><strong>10 Tempat</strong></div>
                    <div class="route-sum-row"><span>Religi</span><strong>7 Tempat</strong></div>
                    <div class="route-sum-row"><span>Area Tercover</span><strong>~15 km</strong></div>
                </div>

                <a href="{{ route('trip') }}" class="btn btn-primary btn-block" id="back-to-trip-btn" style="margin-top:1.5rem;display:block;text-align:center;">
                    🗺️ Buat Itinerary Trip
                </a>
            </div>

        </div>
    </div>
</section>

<style>
.map-dest-group-label {
    font-size: .75rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .08em;
    color: var(--heading);
    background: rgba(138,78,30,.08);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: .4rem .8rem;
    margin: 1rem 0 .5rem;
}
</style>

@endsection

