@extends('layouts.app')

@section('title', 'UMKM Lokal — Routee Surabaya')

@section('content')

<div class="page-hero page-hero-sm">
    <div class="container">
        <span class="section-label">Produk Lokal</span>
        <h1>UMKM Surabaya</h1>
        <p>Temukan produk autentik dari pengusaha lokal Surabaya — oleh-oleh, kerajinan, dan kuliner khas.</p>
    </div>
</div>

<section class="section" id="umkm-section">
    <div class="container">

        <div class="explore-quick-stats" style="margin-bottom:2rem;">
            <div class="eq-stat"><span class="eq-num">{{ count($products) }}</span><span class="eq-label">Produk</span></div>
            <div class="eq-stat"><span class="eq-num">200+</span><span class="eq-label">UMKM Aktif</span></div>
            <div class="eq-stat"><span class="eq-num">4.7</span><span class="eq-label">Avg Rating</span></div>
            <div class="eq-stat"><span class="eq-num">90%</span><span class="eq-label">Produk Lokal</span></div>
        </div>

        <div class="tab-bar" id="umkm-filter" role="tablist">
            <button class="tab-btn active umkm-cat-btn" data-filter="all"     id="filter-all">Semua</button>
            <button class="tab-btn umkm-cat-btn"         data-filter="fashion" id="filter-fashion">👗 Fashion</button>
            <button class="tab-btn umkm-cat-btn"         data-filter="food"    id="filter-food">🍜 Makanan</button>
            <button class="tab-btn umkm-cat-btn"         data-filter="craft"   id="filter-craft">🎨 Kerajinan</button>
        </div>

        <div class="umkm-grid" id="umkm-products">
            @foreach($products as $p)
            <div class="umkm-card" id="umkm-{{ $p['id'] }}" data-category="{{ $p['category'] }}">
                <div class="umkm-img-wrap">
                    <img src="/images/{{ $p['image'] }}" alt="{{ $p['name'] }}" onerror="this.src='/images/placeholder.jpg'">
                    <span class="umkm-cat-tag">{{ ucfirst($p['category']) }}</span>

                    <!-- HOVER OVERLAY -->
                    <div class="umkm-hover-overlay">
                        <div class="umkm-hover-inner">
                            <p class="umkm-hover-seller">🏪 {{ $p['seller'] }}</p>
                            <h4 class="umkm-hover-name">{{ $p['name'] }}</h4>
                            <div class="umkm-hover-tags">
                                <span class="umkm-hover-price">💰 {{ $p['price'] }}</span>
                                <span class="umkm-hover-rating">★ {{ $p['rating'] }}</span>
                            </div>
                            <p class="umkm-hover-note">🤝 Hubungi penjual langsung di lokasi wisata Surabaya.</p>
                        </div>
                    </div>
                </div>
                <div class="umkm-card-body">
                    <div class="umkm-seller">{{ $p['seller'] }}</div>
                    <h3>{{ $p['name'] }}</h3>
                    <div class="umkm-footer">
                        <span class="umkm-price">{{ $p['price'] }}</span>
                        <span class="umkm-rating">★ {{ $p['rating'] }}</span>
                    </div>
                </div>
            </div>
            @endforeach
        </div>

        <div class="custom-empty" id="umkm-empty" style="display:none;">
            <div class="custom-empty-icon">📦</div>
            <p>Tidak ada produk di kategori ini saat ini.</p>
        </div>



    </div>
</section>

<section class="section umkm-banner-section" id="umkm-info-banner">
    <div class="container">
        <div class="umkm-info-banner">
            <div class="umkm-banner-icon">🤝</div>
            <div class="umkm-banner-text">
                <h3>Mengapa Belanja di UMKM Lokal?</h3>
                <p>Setiap pembelian produk UMKM mendukung langsung perekonomian masyarakat Surabaya. 90% pendapatan UMKM tersirkulasi di komunitas lokal, menciptakan lapangan kerja dan melestarikan budaya.</p>
            </div>
            <div class="umkm-banner-stats">
                <div class="umkm-stat"><span class="umkm-stat-num">200+</span><span class="umkm-stat-label">UMKM Aktif</span></div>
                <div class="umkm-stat"><span class="umkm-stat-num">90%</span><span class="umkm-stat-label">Produk Lokal</span></div>
            </div>
        </div>
    </div>
</section>

@endsection

@section('scripts')
<script>
const filterBtns = document.querySelectorAll('.umkm-cat-btn');
const cards = document.querySelectorAll('#umkm-products .umkm-card');
const emptyState = document.getElementById('umkm-empty');

filterBtns.forEach(btn => {
    btn.addEventListener('click', function () {
        filterBtns.forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        const filter = this.dataset.filter;
        let visible = 0;
        cards.forEach(card => {
            const match = filter === 'all' || card.dataset.category === filter;
            card.style.display = match ? '' : 'none';
            if (match) visible++;
        });
        emptyState.style.display = visible === 0 ? 'block' : 'none';
    });
});
</script>

<style>
.explore-quick-stats { display:flex;gap:0;background:var(--bg-card);border-radius:var(--radius);border:1.5px solid var(--border);overflow:hidden;box-shadow:0 4px 18px var(--shadow); }
.eq-stat { flex:1;text-align:center;padding:1.2rem;border-right:1px solid var(--border); }
.eq-stat:last-child { border-right:none; }
.eq-num { display:block;font-size:1.45rem;font-weight:900;color:var(--heading); }
.eq-label { display:block;font-size:.73rem;color:var(--text-muted);font-weight:500;text-transform:uppercase;letter-spacing:.05em;margin-top:.15rem; }

/* Hover overlay on UMKM card image */
.umkm-img-wrap { position:relative; overflow:hidden; }
.umkm-img-wrap img { transition: transform 0.4s ease; display:block; width:100%; }
.umkm-card:hover .umkm-img-wrap img { transform: scale(1.07); }
.umkm-cat-tag { position:absolute;top:10px;right:10px;background:rgba(0,0,0,.55);color:#fff;font-size:.72rem;font-weight:600;padding:.25rem .6rem;border-radius:6px;backdrop-filter:blur(4px);z-index:2; }

.umkm-hover-overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(52,21,15,.96) 0%, rgba(52,21,15,.7) 55%, transparent 100%);
    display: flex;
    align-items: flex-end;
    opacity: 0;
    transform: translateY(8px);
    transition: opacity 0.32s ease, transform 0.32s ease;
    z-index: 3;
    border-radius: inherit;
}
.umkm-card:hover .umkm-hover-overlay {
    opacity: 1;
    transform: translateY(0);
}
.umkm-hover-inner {
    padding: 1rem 1rem 1.1rem;
    color: #fff;
    width: 100%;
}
.umkm-hover-seller { font-size:.75rem; opacity:.8; margin:0 0 .25rem; }
.umkm-hover-name   { font-size:.95rem; font-weight:700; margin:0 0 .5rem; line-height:1.25; }
.umkm-hover-tags   { display:flex; gap:.5rem; flex-wrap:wrap; margin-bottom:.6rem; }
.umkm-hover-price  { background:rgba(211,152,88,.35); border:1px solid rgba(211,152,88,.5); color:#fde68a; font-size:.75rem; font-weight:700; padding:.2rem .55rem; border-radius:6px; }
.umkm-hover-rating { background:rgba(255,255,255,.15); color:#fff; font-size:.75rem; font-weight:700; padding:.2rem .55rem; border-radius:6px; }
.umkm-hover-note   { font-size:.72rem; opacity:.75; margin:0; line-height:1.4; }
</style>
@endsection
