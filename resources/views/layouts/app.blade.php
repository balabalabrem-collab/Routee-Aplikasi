<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Routee — Jelajahi hidden gems, heritage, dan kuliner Surabaya dalam 1 hari. Buat itinerary cerdas sekarang!">
    <title>@yield('title', 'Routee — 1-Day Trip Planner Surabaya')</title>

    <!-- Google Fonts: Poppins -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400&display=swap" rel="stylesheet">

    <!-- Main Stylesheet -->
    <link rel="stylesheet" href="/css/style.css">

    @yield('head')
</head>
<body class="page-loading">

<!-- PAGE TRANSITION OVERLAY -->
<div class="page-overlay" id="page-overlay"></div>

<!-- ===== NAVBAR ===== -->
<nav class="navbar" id="navbar">
    <div class="nav-container">

        <!-- LOGO: Routee Main Logo -->
        <a href="{{ route('home') }}" class="nav-logo" id="nav-logo-link">
            <img src="/images/logo.png" alt="Routee Logo" class="logo-img"
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'">
            <span class="logo-text-fallback">Routee</span>
        </a>

        <!-- DESKTOP MENU -->
        <ul class="nav-links" id="nav-links">
            <li>
                <a href="{{ route('home') }}"
                   class="{{ request()->routeIs('home') ? 'active' : '' }}"
                   id="nav-home">Home</a>
            </li>
            <li>
                <a href="{{ route('explore') }}"
                   class="{{ request()->routeIs('explore') ? 'active' : '' }}"
                   id="nav-explore">Explore</a>
            </li>
            <li>
                <a href="{{ route('trip') }}"
                   class="{{ request()->routeIs('trip') ? 'active' : '' }}"
                   id="nav-trip">Trip</a>
            </li>
            <li>
                <a href="{{ route('map') }}"
                   class="{{ request()->routeIs('map') ? 'active' : '' }}"
                   id="nav-map">Peta</a>
            </li>
            <li>
                <a href="{{ route('transport') }}"
                   class="{{ request()->routeIs('transport') ? 'active' : '' }}"
                   id="nav-transport">Transport</a>
            </li>
            <li>
                <a href="{{ route('umkm') }}"
                   class="{{ request()->routeIs('umkm') ? 'active' : '' }}"
                   id="nav-umkm">UMKM</a>
            </li>
        </ul>

        <!-- CTA -->
        <a href="{{ route('trip') }}" class="btn btn-primary nav-cta" id="nav-plan-btn">
            🗺️ Plan My Trip
        </a>

        <!-- HAMBURGER -->
        <button class="hamburger" id="hamburger" aria-label="Buka Menu" aria-expanded="false">
            <span></span><span></span><span></span>
        </button>
    </div>

    <!-- MOBILE MENU (inside navbar for cleaner z-index) -->
    <div class="mobile-menu" id="mobile-menu" aria-hidden="true">
        <a href="{{ route('home') }}" class="{{ request()->routeIs('home') ? 'active' : '' }}">🏠 Home</a>
        <a href="{{ route('explore') }}" class="{{ request()->routeIs('explore') ? 'active' : '' }}">🔍 Explore</a>
        <a href="{{ route('trip') }}" class="{{ request()->routeIs('trip') ? 'active' : '' }}">📅 Trip Planner</a>
        <a href="{{ route('map') }}" class="{{ request()->routeIs('map') ? 'active' : '' }}">🗺️ Peta Rute</a>
        <a href="{{ route('transport') }}" class="{{ request()->routeIs('transport') ? 'active' : '' }}">🚗 Transport</a>
        <a href="{{ route('umkm') }}" class="{{ request()->routeIs('umkm') ? 'active' : '' }}">🛍️ UMKM</a>
        <a href="{{ route('trip') }}" class="btn btn-primary" style="margin-top:.5rem;justify-content:center;">
            🗺️ Plan My 1-Day Trip
        </a>
    </div>
</nav>

<!-- ===== MAIN CONTENT ===== -->
<main id="main-content">
    @yield('content')
</main>

<!-- ===== FOOTER ===== -->
<footer class="footer">
    <div class="footer-inner">
        <div class="footer-brand">
            <!-- LOGO: Routee Footer Logo -->
            <div class="footer-logo-wrap">
                <img src="/images/logo.png" alt="Routee Logo" class="footer-logo"
                     onerror="this.style.display='none'">
                <span class="footer-name">Routee</span>
            </div>
            <p class="footer-tagline">Jelajahi Surabaya dalam 1 hari.<br>Hemat waktu, kaya pengalaman.</p>
            <div class="footer-badges">
                <span class="badge">Heritage Tourism</span>
                <span class="badge">Hidden Gems</span>
                <span class="badge">Culinary</span>
            </div>
        </div>
        <div class="footer-links">
            <h4>Halaman</h4>
            <a href="{{ route('home') }}">Home</a>
            <a href="{{ route('explore') }}">Explore</a>
            <a href="{{ route('trip') }}">Trip Planner</a>
            <a href="{{ route('map') }}">Peta Rute</a>
            <a href="{{ route('transport') }}">Transport</a>
            <a href="{{ route('umkm') }}">UMKM Lokal</a>
        </div>
        <div class="footer-links">
            <h4>Destinasi</h4>
            <a href="{{ route('detail', 'maspati') }}">Kampung Maspati</a>
            <a href="{{ route('detail', 'chenghoo') }}">Masjid Cheng Hoo</a>
            <a href="{{ route('detail', 'ampel') }}">Makam Sunan Ampel</a>
            <a href="{{ route('detail', 'dejavasche') }}">De Javasche Bank</a>
        </div>
        <div class="footer-info">
            <h4>Tentang Routee</h4>
            <p>Proyek penelitian UTS Universitas Teknologi Surabaya tentang optimasi rute wisata heritage 1-hari di Kota Surabaya.</p>
            <a href="{{ route('trip') }}" class="btn btn-primary btn-sm footer-cta">
                Mulai Trip Sekarang →
            </a>
        </div>
    </div>
    <div class="footer-bottom">
        <p>© 2025 <strong>Routee</strong> · Universitas Teknologi Surabaya · UTS Presentation Project</p>
    </div>
</footer>

<!-- Main JS -->
<script src="/js/script.js"></script>
@yield('scripts')

</body>
</html>
