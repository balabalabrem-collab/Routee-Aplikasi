@extends('layouts.app')

@section('title', 'UMKM Lokal — Routee Surabaya')

@section('content')

<div class="page-hero page-hero-sm">
    <div class="container">
        <span class="section-label">Belanja Lokal</span>
        <h1>Produk UMKM Surabaya</h1>
        <p>Dukung pengusaha lokal dengan membeli oleh-oleh dan produk khas Surabaya.</p>
    </div>
</div>

<section class="section" id="umkm-section">
    <div class="container">

        <!-- FILTER BAR -->
        <div class="tab-bar umkm-filter" id="umkm-filter">
            <button class="tab-btn active" data-filter="all" id="filter-all">Semua</button>
            <button class="tab-btn" data-filter="fashion" id="filter-fashion">Fashion</button>
            <button class="tab-btn" data-filter="food" id="filter-food">Makanan</button>
            <button class="tab-btn" data-filter="craft" id="filter-craft">Kerajinan</button>
        </div>

        <div class="umkm-grid" id="umkm-products">
            @foreach($products as $i => $p)
            <div class="umkm-card" id="umkm-{{ $i }}">
                <div class="umkm-img-wrap">
                    <!-- IMAGE: {{ $p['name'] }} -->
                    <img src="/images/{{ $p['image'] }}" alt="{{ $p['name'] }}"
                         onerror="this.src='/images/placeholder.jpg'">
                    <div class="umkm-img-overlay">
                        <button class="btn btn-sm btn-white umkm-quick-btn"
                                onclick="quickBuy('{{ $p['name'] }}', '{{ $p['price'] }}')">
                            Lihat Detail
                        </button>
                    </div>
                </div>
                <div class="umkm-card-body">
                    <div class="umkm-seller">{{ $p['seller'] }}</div>
                    <h3>{{ $p['name'] }}</h3>
                    <div class="umkm-footer">
                        <span class="umkm-price">{{ $p['price'] }}</span>
                        <span class="umkm-rating">★ {{ $p['rating'] }}</span>
                    </div>
                    <button class="btn btn-primary btn-block btn-sm" style="margin-top:.75rem;"
                            onclick="quickBuy('{{ $p['name'] }}', '{{ $p['price'] }}')"
                            id="buy-{{ $i }}">
                        Pesan Sekarang
                    </button>
                </div>
            </div>
            @endforeach
        </div>

    </div>
</section>

<!-- QUICK BUY MODAL -->
<div class="modal-overlay" id="umkm-modal" style="display:none;">
    <div class="modal-box">
        <div class="modal-icon">🛍️</div>
        <h2 id="umkm-modal-name">Nama Produk</h2>
        <p>Harga: <strong id="umkm-modal-price"></strong></p>
        <p style="color:#888;font-size:.9rem;margin-top:.5rem;">Hubungi penjual langsung untuk pembelian. Dukung UMKM lokal Surabaya!</p>
        <div class="modal-actions">
            <button class="btn btn-primary" onclick="closeUmkmModal()" id="umkm-modal-order">Hubungi Penjual</button>
            <button class="btn btn-outline" onclick="closeUmkmModal()">Tutup</button>
        </div>
    </div>
</div>

<!-- UMKM INFO BANNER -->
<section class="section umkm-banner-section" id="umkm-info-banner">
    <div class="container">
        <div class="umkm-info-banner">
            <div class="umkm-banner-icon">🤝</div>
            <div class="umkm-banner-text">
                <h3>Mengapa Belanja di UMKM Lokal?</h3>
                <p>Setiap pembelian produk UMKM mendukung langsung perekonomian masyarakat Surabaya. 90% pendapatan UMKM tersirkulasi di komunitas lokal, menciptakan lapangan kerja dan melestarikan budaya.</p>
            </div>
            <div class="umkm-banner-stats">
                <div class="umkm-stat">
                    <span class="umkm-stat-num">200+</span>
                    <span class="umkm-stat-label">UMKM Aktif</span>
                </div>
                <div class="umkm-stat">
                    <span class="umkm-stat-num">90%</span>
                    <span class="umkm-stat-label">Produk Lokal</span>
                </div>
            </div>
        </div>
    </div>
</section>

@endsection

@section('scripts')
<script>
function quickBuy(name, price) {
    document.getElementById('umkm-modal-name').textContent = name;
    document.getElementById('umkm-modal-price').textContent = price;
    document.getElementById('umkm-modal').style.display = 'flex';
}
function closeUmkmModal() {
    document.getElementById('umkm-modal').style.display = 'none';
}
document.getElementById('umkm-modal').addEventListener('click', function(e) {
    if (e.target === this) closeUmkmModal();
});
</script>
@endsection
