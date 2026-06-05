@extends('layouts.app')

@section('title', 'Explore — Routee Surabaya')

@section('content')

<div class="page-hero page-hero-sm">
    <div class="container">
        <span class="section-label">Jelajahi</span>
        <h1>Semua Destinasi &amp; Kuliner</h1>
        <p>Pilih berdasarkan kategori dan temukan permata tersembunyi Surabaya.</p>
    </div>
</div>

<section class="section" id="explore-section">
    <div class="container">

        <!-- QUICK STATS -->
        <div class="explore-quick-stats">
            <div class="eq-stat">
                <span class="eq-num">{{ count($destinations) }}</span>
                <span class="eq-label">Destinasi</span>
            </div>
            <div class="eq-stat">
                <span class="eq-num">{{ count($culinary) }}</span>
                <span class="eq-label">Kuliner</span>
            </div>
            <div class="eq-stat">
                <span class="eq-num">4.7</span>
                <span class="eq-label">Avg Rating</span>
            </div>
            <div class="eq-stat">
                <span class="eq-num">~Rp150rb</span>
                <span class="eq-label">Per-Trip Cost</span>
            </div>
        </div>

        <!-- SEARCH BAR -->
        <div class="explore-search-wrap" style="margin-bottom:1.5rem;">
            <div style="position:relative;max-width:520px;">
                <span style="position:absolute;left:1rem;top:50%;transform:translateY(-50%);font-size:1.1rem;">🔍</span>
                <input type="text" id="explore-search" placeholder="Cari destinasi, kuliner, atau kategori..."
                    style="width:100%;padding:.8rem 1rem .8rem 2.8rem;border:2px solid var(--border);border-radius:var(--radius);font-family:inherit;font-size:.9rem;background:var(--bg-card);color:var(--text);outline:none;transition:border-color .2s;"
                    oninput="filterExplore(this.value)"
                    onfocus="this.style.borderColor='var(--primary)'"
                    onblur="this.style.borderColor='var(--border)'"
                >
            </div>
            <p id="explore-search-count" style="font-size:.8rem;color:var(--text-muted);margin-top:.4rem;display:none;"></p>
        </div>

        <!-- ── TABS ─────────────────────────────────── -->
        <div class="tab-bar" id="explore-tabs" role="tablist">
            <button class="tab-btn active" data-tab="heritage" id="tab-heritage"
                    role="tab" aria-selected="true" aria-controls="tab-content-heritage">
                🏛 Heritage
            </button>
            <button class="tab-btn" data-tab="religi" id="tab-religi"
                    role="tab" aria-selected="false" aria-controls="tab-content-religi">
                🕌 Religi
            </button>
            <button class="tab-btn" data-tab="culinary" id="tab-culinary"
                    role="tab" aria-selected="false" aria-controls="tab-content-culinary">
                🍜 Kuliner
            </button>
        </div>

        <!-- ══════════════════════════════════════════
             TAB: HERITAGE
             ══════════════════════════════════════════ -->
        <div class="tab-content active" id="tab-content-heritage" role="tabpanel">

            <!-- GROUP: Peneleh / Kawasan Bersejarah -->
            <div class="dest-group-header">
                <span class="dest-group-title">🏘 Kawasan Peneleh &amp; Bubutan</span>
                <span class="dest-group-badge">Heritage Utama</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Heritage' && in_array($d['id'], ['maspati']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $d['name'] }} -->
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-heritage">Heritage</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Tunjungan / Kota Lama -->
            <div class="dest-group-header">
                <span class="dest-group-title">🏛 Tunjungan &amp; Kota Lama</span>
                <span class="dest-group-badge">Kolonial</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Heritage' && in_array($d['id'], ['tunjungan','gedung-siola','kota-lama','dejavasche']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $d['name'] }} -->
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-heritage">Heritage</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Kenjeran & Pesisir -->
            <div class="dest-group-header">
                <span class="dest-group-title">🌊 Kenjeran &amp; Pesisir</span>
                <span class="dest-group-badge">Pantai &amp; Alam</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Heritage' && in_array($d['id'], ['kenjeran','kalimas']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $d['name'] }} -->
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-heritage">Heritage</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Taman Kota -->
            <div class="dest-group-header">
                <span class="dest-group-title">🌳 Taman &amp; Ruang Publik</span>
                <span class="dest-group-badge">Bersantai</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Heritage' && in_array($d['id'], ['alun-alun','taman-bungkul']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $d['name'] }} -->
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-heritage">Heritage</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <div class="tab-cta">
                <a href="{{ route('trip') }}" class="btn btn-primary">🗺️ Mulai Plan Heritage Trip →</a>
                <a href="{{ route('map') }}" class="btn btn-outline" style="margin-left:.75rem;">🗺️ Lihat di Peta</a>
            </div>
        </div>

        <!-- ══════════════════════════════════════════
             TAB: RELIGI
             ══════════════════════════════════════════ -->
        <div class="tab-content" id="tab-content-religi" role="tabpanel">

            <!-- GROUP: Masjid & Wali -->
            <div class="dest-group-header">
                <span class="dest-group-title">🕌 Masjid &amp; Situs Wali</span>
                <span class="dest-group-badge">Ziarah &amp; Wisata</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Religi' && in_array($d['id'], ['ampel','langgar-dukur','masjid-agung','chenghoo']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-religi">Religi</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Klenteng & Budaya Tionghoa -->
            <div class="dest-group-header">
                <span class="dest-group-title">🏮 Klenteng &amp; Pecinan</span>
                <span class="dest-group-badge">Multikultural</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Religi' && in_array($d['id'], ['klenteng-kya-kya','sanggar-agung']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-religi">Religi</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Makam & Ziarah -->
            <div class="dest-group-header">
                <span class="dest-group-title">🌿 Makam &amp; Ziarah</span>
                <span class="dest-group-badge">Spiritual</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Religi' && in_array($d['id'], ['makam-bungkul']))
                    <a href="{{ route('detail', $d['id']) }}" class="explore-card" id="explore-{{ $d['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $d['name'] }} -->
                            <img src="/images/{{ $d['image'] }}" alt="{{ $d['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $d['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-religi">Religi</span>
                            <h3>{{ $d['name'] }}</h3>
                            <p>{{ Str::limit($d['description'], 80) }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $d['duration'] }}</span>
                                <span>🎟 {{ $d['ticket'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <div class="tab-cta">
                <a href="{{ route('trip') }}" class="btn btn-primary">🕌 Plan Religi Trip →</a>
                <a href="{{ route('map') }}" class="btn btn-outline" style="margin-left:.75rem;">🗺️ Lihat di Peta</a>
            </div>
        </div>

        <!-- ══════════════════════════════════════════
             TAB: KULINER
             ══════════════════════════════════════════ -->
        <div class="tab-content" id="tab-content-culinary" role="tabpanel">

            <!-- GROUP: Makanan Berat -->
            <div class="dest-group-header">
                <span class="dest-group-title">🍲 Makanan Khas Surabaya</span>
                <span class="dest-group-badge">Makan Utama</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($culinary as $c)
                    @if(in_array($c['id'], ['rawon','lontong-balap','rujak-cingur','soto-pak-sadi','tahu-campur','tahu-tek']))
                    <a href="{{ route('detail', $c['id']) }}" class="explore-card" id="explore-{{ $c['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $c['name'] }} -->
                            <img src="/images/{{ $c['image'] }}" alt="{{ $c['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $c['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-culinary">Kuliner</span>
                            <h3>{{ $c['name'] }}</h3>
                            <p>{{ $c['desc'] }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $c['duration'] }}</span>
                                <span>💰 {{ $c['price'] }}</span>
                            </div>
                            <div class="explore-meta" style="margin-top:.25rem;">
                                <span>📍 {{ $c['area'] }}</span>
                                <span>{{ $c['distance'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Kuliner Pesisir -->
            <div class="dest-group-header">
                <span class="dest-group-title">🦐 Kuliner Pesisir &amp; Khas Kawasan</span>
                <span class="dest-group-badge">Area Spesifik</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($culinary as $c)
                    @if(in_array($c['id'], ['lontong-kupang','karmini','warung-pojok']))
                    <a href="{{ route('detail', $c['id']) }}" class="explore-card" id="explore-{{ $c['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $c['name'] }} -->
                            <img src="/images/{{ $c['image'] }}" alt="{{ $c['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $c['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-culinary">Kuliner</span>
                            <h3>{{ $c['name'] }}</h3>
                            <p>{{ $c['desc'] }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $c['duration'] }}</span>
                                <span>💰 {{ $c['price'] }}</span>
                            </div>
                            <div class="explore-meta" style="margin-top:.25rem;">
                                <span>📍 {{ $c['area'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <!-- GROUP: Oleh-oleh & Dessert -->
            <div class="dest-group-header">
                <span class="dest-group-title">🍦 Dessert &amp; Oleh-oleh</span>
                <span class="dest-group-badge">Penutup &amp; Buah Tangan</span>
                <div class="dest-group-line"></div>
            </div>
            <div class="explore-grid">
                @foreach($culinary as $c)
                    @if(in_array($c['id'], ['zangrandi','bu-rudy','rawon-kalkulator','spikoe','siropen']))
                    <a href="{{ route('detail', $c['id']) }}" class="explore-card" id="explore-{{ $c['id'] }}">
                        <div class="explore-card-img">
                            <!-- IMAGE: {{ $c['name'] }} -->
                            <img src="/images/{{ $c['image'] }}" alt="{{ $c['name'] }}"
                                 onerror="this.src='/images/placeholder.jpg'">
                            <div class="explore-card-overlay">
                                <span class="explore-rating">★ {{ $c['rating'] }}</span>
                            </div>
                        </div>
                        <div class="explore-card-body">
                            <span class="explore-cat explore-cat-culinary">Kuliner</span>
                            <h3>{{ $c['name'] }}</h3>
                            <p>{{ $c['desc'] }}</p>
                            <div class="explore-meta">
                                <span>⏱ {{ $c['duration'] }}</span>
                                <span>💰 {{ $c['price'] }}</span>
                            </div>
                            <div class="explore-meta" style="margin-top:.25rem;">
                                <span>📍 {{ $c['area'] }}</span>
                            </div>
                        </div>
                    </a>
                    @endif
                @endforeach
            </div>

            <div class="tab-cta">
                <a href="{{ route('trip') }}" class="btn btn-primary">🗺️ Plan Trip dengan Kuliner Ini →</a>
            </div>
        </div>

    </div>
</section>

@endsection

@section('scripts')
<style>
.explore-quick-stats {
    display: flex; gap: 0;
    background: var(--bg-card);
    border-radius: var(--radius);
    border: 1.5px solid var(--border);
    overflow: hidden;
    margin-bottom: 2rem;
    box-shadow: 0 4px 18px var(--shadow);
}
.eq-stat {
    flex: 1; text-align: center;
    padding: 1.2rem;
    border-right: 1px solid var(--border);
}
.eq-stat:last-child { border-right: none; }
.eq-num   { display: block; font-size: 1.45rem; font-weight: 900; color: var(--heading); }
.eq-label { display: block; font-size: .73rem; color: var(--text-muted); font-weight: 500; text-transform: uppercase; letter-spacing: .05em; margin-top: .15rem; }

.tab-cta { text-align: center; margin-top: 2.5rem; padding-top: 2rem; border-top: 1px dashed var(--border); }

/* Search highlight */
.search-highlight { background: rgba(211,152,88,.25); border-radius: 3px; padding: 0 2px; }
.explore-card.search-hidden { display: none !important; }
</style>
<script>
// Tab switching (preserve existing)
const tabBtns = document.querySelectorAll('.tab-btn[data-tab]');
const tabContents = document.querySelectorAll('.tab-content');
tabBtns.forEach(btn => {
    btn.addEventListener('click', function() {
        tabBtns.forEach(b => { b.classList.remove('active'); b.setAttribute('aria-selected','false'); });
        tabContents.forEach(t => t.classList.remove('active'));
        this.classList.add('active');
        this.setAttribute('aria-selected','true');
        const target = document.getElementById('tab-content-' + this.dataset.tab);
        if(target) target.classList.add('active');
        // Clear search on tab switch
        const search = document.getElementById('explore-search');
        if(search) { search.value=''; filterExplore(''); }
    });
});

// Live search
function filterExplore(query) {
    const q = query.toLowerCase().trim();
    const countEl = document.getElementById('explore-search-count');
    const allCards = document.querySelectorAll('.tab-content.active .explore-card');
    let visible = 0;

    allCards.forEach(card => {
        const text = card.textContent.toLowerCase();
        if(!q || text.includes(q)) {
            card.classList.remove('search-hidden');
            visible++;
        } else {
            card.classList.add('search-hidden');
        }
    });

    if(q && countEl) {
        countEl.textContent = visible + ' hasil ditemukan untuk "' + query + '"';
        countEl.style.display = 'block';
    } else if(countEl) {
        countEl.style.display = 'none';
    }
}
</script>
@endsection

