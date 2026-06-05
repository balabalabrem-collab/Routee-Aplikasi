@extends('layouts.app')

@section('title', $destination['name'] . ' — Routee Surabaya')

@section('content')

<!-- PAGE HERO -->
<div class="page-hero page-hero-sm">
    <div class="container">
        <nav class="detail-breadcrumb">
            <a href="{{ route('home') }}">Home</a>
            <span>›</span>
            <a href="{{ route('explore') }}">Explore</a>
            <span>›</span>
            <span>{{ $destination['name'] }}</span>
        </nav>
        <span class="section-label">{{ $destination['category'] }}</span>
        <h1>{{ $destination['name'] }}</h1>
        <p>
            <span style="color:rgba(255,255,255,.85);">★ {{ $destination['rating'] }} / 5.0</span>
            &nbsp;·&nbsp;
            <span style="color:rgba(255,255,255,.75);">⏱ {{ $destination['duration'] }}</span>
            &nbsp;·&nbsp;
            <span style="color:rgba(255,255,255,.75);">🎟 {{ $destination['ticket'] }}</span>
        </p>
    </div>
</div>

<section class="section detail-section" id="detail-section">
    <div class="container">
        <div class="detail-layout">

            <!-- LEFT: IMAGE & GALLERY -->
            <div class="detail-media">
                <div class="detail-main-img">
                    <!-- IMAGE: {{ $destination['name'] }} -->
                    <img src="/images/{{ $destination['image'] }}" alt="{{ $destination['name'] }}"
                         onerror="this.src='/images/placeholder.jpg'"
                         id="detail-hero-img">
                    <div class="detail-cat-tag">
                        {{ $destination['category'] }}
                    </div>
                    <div class="detail-rating-tag">
                        ★ {{ $destination['rating'] }}
                    </div>
                </div>

                <!-- THUMBNAIL GALLERY (same image, different crop simulation) -->
                <div class="detail-thumbs">
                    <div class="detail-thumb active">
                        <img src="/images/{{ $destination['image'] }}" alt="{{ $destination['name'] }}"
                             onerror="this.src='/images/placeholder.jpg'">
                    </div>
                    <div class="detail-thumb">
                        <img src="/images/placeholder.jpg" alt="Foto 2">
                        <div class="thumb-overlay">+2 foto</div>
                    </div>
                </div>
            </div>

            <!-- RIGHT: INFO -->
            <div class="detail-info">
                <div class="detail-header">
                    <span class="detail-cat-badge {{ $destination['category'] === 'Religi' ? 'badge-religi' : ($destination['category'] === 'Kuliner' ? 'badge-culinary' : 'badge-heritage') }}">
                        {{ $destination['category'] }}
                    </span>
                    <h1>{{ $destination['name'] }}</h1>
                    <div class="detail-rating-row">
                        <span class="star-rating">
                            @for($i = 1; $i <= 5; $i++)
                                <span class="{{ $i <= floor($destination['rating']) ? 'star-filled' : 'star-empty' }}">★</span>
                            @endfor
                        </span>
                        <span class="rating-num">{{ $destination['rating'] }} / 5.0</span>
                    </div>
                </div>

                <p class="detail-desc">{{ $destination['description'] }}</p>

                <!-- INFO TABLE -->
                <div class="detail-info-grid">
                    <div class="info-item">
                        <span class="info-icon">📍</span>
                        <div>
                            <span class="info-label">Lokasi</span>
                            <span class="info-val">{{ $destination['location'] }}</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <span class="info-icon">🕐</span>
                        <div>
                            <span class="info-label">Jam Buka</span>
                            <span class="info-val">{{ $destination['hours'] }}</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <span class="info-icon">🎟</span>
                        <div>
                            <span class="info-label">Tiket Masuk</span>
                            <span class="info-val">{{ $destination['ticket'] }}</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <span class="info-icon">⏱</span>
                        <div>
                            <span class="info-label">Durasi Kunjungan</span>
                            <span class="info-val">{{ $destination['duration'] }}</span>
                        </div>
                    </div>
                </div>

                <!-- ACTION BUTTONS -->
                <div class="detail-actions">
                    <a href="{{ route('trip') }}" class="btn btn-primary btn-lg" id="view-itinerary-btn">
                        🗺️ Rencanakan Trip dari Sini
                    </a>
                    <a href="{{ route('explore') }}" class="btn btn-outline btn-lg" id="explore-more-btn">
                        🔍 Lihat Destinasi Lain
                    </a>
                </div>

                <!-- NEARBY CULINARY -->
                <div class="detail-nearby" id="nearby-section">
                    <h3>🍜 Kuliner Terdekat (≤500m)</h3>
                    <div class="nearby-grid">
                        <div class="nearby-card">
                            <!-- IMAGE: Rawon Setan (Nearby) -->
                            <img src="/images/rawon.jpg" alt="Rawon Setan"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="nearby-info">
                                <strong>Rawon Setan</strong>
                                <span>★ 4.8 · Rp 30.000–45.000</span>
                            </div>
                        </div>
                        <div class="nearby-card">
                            <!-- IMAGE: Lontong Balap (Nearby) -->
                            <img src="/images/lontong.jpg" alt="Lontong Balap"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="nearby-info">
                                <strong>Lontong Balap</strong>
                                <span>★ 4.7 · Rp 20.000–30.000</span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- MORE DESTINATIONS -->
        <div class="more-destinations" id="more-destinations">
            <h2>Destinasi Lainnya</h2>
            <div class="more-grid">
                <a href="{{ route('detail', 'maspati') }}" class="more-card {{ $destination['id'] === 'maspati' ? 'more-card-active' : '' }}" id="more-maspati">
                    <img src="/images/maspati.jpg" alt="Kampung Lawas Maspati" onerror="this.src='/images/placeholder.jpg'">
                    <span>Kampung Maspati</span>
                </a>
                <a href="{{ route('detail', 'tunjungan') }}" class="more-card {{ $destination['id'] === 'tunjungan' ? 'more-card-active' : '' }}" id="more-tunjungan">
                    <img src="/images/tunjungan.jpg" alt="Jalan Tunjungan" onerror="this.src='/images/placeholder.jpg'">
                    <span>Jalan Tunjungan</span>
                </a>
                <a href="{{ route('detail', 'chenghoo') }}" class="more-card {{ $destination['id'] === 'chenghoo' ? 'more-card-active' : '' }}" id="more-chenghoo">
                    <img src="/images/chenghoo.jpg" alt="Masjid Cheng Hoo" onerror="this.src='/images/placeholder.jpg'">
                    <span>Masjid Cheng Hoo</span>
                </a>
                <a href="{{ route('detail', 'ampel') }}" class="more-card {{ $destination['id'] === 'ampel' ? 'more-card-active' : '' }}" id="more-ampel">
                    <img src="/images/ampel.jpg" alt="Makam Sunan Ampel" onerror="this.src='/images/placeholder.jpg'">
                    <span>Makam Sunan Ampel</span>
                </a>
                <a href="{{ route('detail', 'dejavasche') }}" class="more-card {{ $destination['id'] === 'dejavasche' ? 'more-card-active' : '' }}" id="more-dejavasche">
                    <img src="/images/dejavasche.jpg" alt="De Javasche Bank" onerror="this.src='/images/placeholder.jpg'">
                    <span>De Javasche Bank</span>
                </a>
            </div>
        </div>
    </div>
</section>

@endsection

@section('scripts')
<style>
.detail-breadcrumb {
    display: flex;
    align-items: center;
    gap: .5rem;
    font-size: .82rem;
    color: rgba(255,255,255,.7);
    margin-bottom: 1rem;
    flex-wrap: wrap;
    justify-content: center;
}
.detail-breadcrumb a { color: rgba(255,255,255,.8); text-decoration: none; }
.detail-breadcrumb a:hover { color: #fff; text-decoration: underline; }
.detail-breadcrumb span { color: rgba(255,255,255,.5); }
</style>
@endsection
