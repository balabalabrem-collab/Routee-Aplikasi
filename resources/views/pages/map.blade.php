@extends('layouts.app')

@section('title', 'Peta Rute — Routee Surabaya')

@section('content')

<div class="page-hero page-hero-sm">
    <div class="container">
        <span class="section-label">Navigasi</span>
        <h1>Peta Rute Perjalanan</h1>
        <p>Rute optimal A → B → C untuk perjalanan heritage Surabaya 1 hari.</p>
    </div>
</div>

<section class="section" id="map-section">
    <div class="container">
        <div class="map-layout">

            <!-- FAKE MAP UI -->
            <div class="map-container" id="fake-map">
                <div class="map-header">
                    <span class="map-label">🗺️ Peta Rute Surabaya Heritage</span>
                    <span class="map-badge">3 Destinasi · 8 km</span>
                </div>

                <!-- MAP VISUAL -->
                <div class="map-visual">
                    <!-- BACKGROUND STREETS -->
                    <svg class="map-svg" viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg">
                        <!-- Street grid background -->
                        <rect width="700" height="420" fill="#f0e8dc"/>

                        <!-- Major roads -->
                        <line x1="0" y1="200" x2="700" y2="200" stroke="#d4c4a8" stroke-width="18"/>
                        <line x1="350" y1="0" x2="350" y2="420" stroke="#d4c4a8" stroke-width="18"/>
                        <line x1="0" y1="100" x2="700" y2="100" stroke="#e0d4c0" stroke-width="10"/>
                        <line x1="0" y1="320" x2="700" y2="320" stroke="#e0d4c0" stroke-width="10"/>
                        <line x1="175" y1="0" x2="175" y2="420" stroke="#e0d4c0" stroke-width="10"/>
                        <line x1="525" y1="0" x2="525" y2="420" stroke="#e0d4c0" stroke-width="10"/>

                        <!-- Street labels -->
                        <text x="10" y="196" fill="#b8a890" font-size="10" font-family="Poppins,sans-serif">Jl. Bubutan</text>
                        <text x="10" y="96" fill="#b8a890" font-size="10" font-family="Poppins,sans-serif">Jl. Pahlawan</text>
                        <text x="10" y="316" fill="#b8a890" font-size="10" font-family="Poppins,sans-serif">Jl. Garuda</text>

                        <!-- ROUTE LINE -->
                        <polyline
                            points="140,150 280,190 460,310"
                            fill="none"
                            stroke="#D39858"
                            stroke-width="4"
                            stroke-dasharray="10,4"
                            stroke-linecap="round"
                            class="route-line"
                        />

                        <!-- LOCATION A: Maspati -->
                        <circle cx="140" cy="150" r="22" fill="#8A4E1E" stroke="white" stroke-width="3"/>
                        <text x="140" y="154" fill="white" font-size="11" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">A</text>
                        <text x="140" y="130" fill="#34150F" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="600">Maspati</text>

                        <!-- LOCATION B: Tjokroaminoto -->
                        <circle cx="280" cy="190" r="22" fill="#D39858" stroke="white" stroke-width="3"/>
                        <text x="280" y="194" fill="white" font-size="11" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">B</text>
                        <text x="280" y="170" fill="#34150F" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="600">Tjokroaminoto</text>

                        <!-- FOOD MARKER: Rawon -->
                        <circle cx="370" cy="250" r="14" fill="#e8834a" stroke="white" stroke-width="2"/>
                        <text x="370" y="254" fill="white" font-size="10" text-anchor="middle" font-family="Poppins,sans-serif">🍜</text>
                        <text x="370" y="238" fill="#34150F" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif">Rawon</text>

                        <!-- LOCATION C: De Javasche -->
                        <circle cx="460" cy="310" r="22" fill="#8A4E1E" stroke="white" stroke-width="3"/>
                        <text x="460" y="314" fill="white" font-size="11" font-weight="bold" text-anchor="middle" font-family="Poppins,sans-serif">C</text>
                        <text x="460" y="292" fill="#34150F" font-size="9" text-anchor="middle" font-family="Poppins,sans-serif" font-weight="600">De Javasche</text>

                        <!-- FOOD MARKER: Lontong -->
                        <circle cx="560" cy="340" r="14" fill="#e8834a" stroke="white" stroke-width="2"/>
                        <text x="560" y="344" fill="white" font-size="10" text-anchor="middle" font-family="Poppins,sans-serif">🍜</text>
                        <text x="560" y="328" fill="#34150F" font-size="8" text-anchor="middle" font-family="Poppins,sans-serif">Lontong</text>

                        <!-- CURRENT LOCATION indicator -->
                        <circle cx="140" cy="150" r="30" fill="none" stroke="#D39858" stroke-width="2" opacity="0.5">
                            <animate attributeName="r" values="22;35;22" dur="2s" repeatCount="indefinite"/>
                            <animate attributeName="opacity" values="0.6;0;0.6" dur="2s" repeatCount="indefinite"/>
                        </circle>
                    </svg>

                    <!-- MAP LEGEND -->
                    <div class="map-legend">
                        <div class="legend-item">
                            <span class="legend-dot" style="background:#8A4E1E"></span>
                            <span>Destinasi Heritage</span>
                        </div>
                        <div class="legend-item">
                            <span class="legend-dot" style="background:#D39858"></span>
                            <span>Titik Saat Ini</span>
                        </div>
                        <div class="legend-item">
                            <span class="legend-dot" style="background:#e8834a"></span>
                            <span>Kuliner</span>
                        </div>
                        <div class="legend-item">
                            <span class="legend-line"></span>
                            <span>Rute Perjalanan</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ROUTE DETAILS SIDEBAR -->
            <div class="route-sidebar">
                <h2>📍 Detail Rute</h2>

                <!-- ROUTE STEP A -->
                <div class="route-step" id="route-step-a">
                    <div class="route-step-marker marker-a">A</div>
                    <div class="route-step-info">
                        <h4>Kampung Lawas Maspati</h4>
                        <span class="route-time">08:00 WIB · Start</span>
                        <div class="route-meta-row">
                            <span>📍 Jl. Maspati, Bubutan</span>
                        </div>
                    </div>
                </div>

                <div class="route-road-info">
                    <span class="road-line"></span>
                    <div class="road-details">
                        <span>🛵 ±10 menit</span>
                        <span>1.2 km</span>
                    </div>
                    <span class="road-line"></span>
                </div>

                <!-- ROUTE STEP B -->
                <div class="route-step" id="route-step-b">
                    <div class="route-step-marker marker-b">B</div>
                    <div class="route-step-info">
                        <h4>Rumah HOS Tjokroaminoto</h4>
                        <span class="route-time">10:00 WIB · Stop 2</span>
                        <div class="route-meta-row">
                            <span>📍 Jl. Peneleh Gang VII</span>
                        </div>
                    </div>
                </div>

                <!-- FOOD STOP -->
                <div class="route-food-stop">
                    <span>🍜</span>
                    <div>
                        <strong>Rawon Setan</strong>
                        <span>12:00 · Makan Siang · ≤500m</span>
                    </div>
                </div>

                <div class="route-road-info">
                    <span class="road-line"></span>
                    <div class="road-details">
                        <span>🛵 ±15 menit</span>
                        <span>3.4 km</span>
                    </div>
                    <span class="road-line"></span>
                </div>

                <!-- ROUTE STEP C -->
                <div class="route-step" id="route-step-c">
                    <div class="route-step-marker marker-a">C</div>
                    <div class="route-step-info">
                        <h4>Gedung De Javasche Bank</h4>
                        <span class="route-time">13:30 WIB · Stop 3</span>
                        <div class="route-meta-row">
                            <span>📍 Jl. Garuda, Krembangan</span>
                        </div>
                    </div>
                </div>

                <!-- FOOD STOP -->
                <div class="route-food-stop">
                    <span>🍜</span>
                    <div>
                        <strong>Lontong Balap</strong>
                        <span>15:30 · Kuliner Sore · ≤500m</span>
                    </div>
                </div>

                <!-- SUMMARY -->
                <div class="route-summary-box">
                    <div class="route-sum-row">
                        <span>Total Jarak</span>
                        <strong>± 8 km</strong>
                    </div>
                    <div class="route-sum-row">
                        <span>Total Waktu Perjalanan</span>
                        <strong>±25 menit transit</strong>
                    </div>
                    <div class="route-sum-row">
                        <span>Total Durasi Trip</span>
                        <strong>8 Jam</strong>
                    </div>
                </div>

                <a href="{{ route('trip') }}" class="btn btn-primary btn-block" id="back-to-trip-btn" style="margin-top:1.5rem;display:block;text-align:center;">
                    ← Kembali ke Itinerary
                </a>
            </div>

        </div>
    </div>
</section>

@endsection
