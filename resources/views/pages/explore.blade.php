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

        <!-- TABS -->
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

        <!-- TAB: HERITAGE -->
        <div class="tab-content active" id="tab-content-heritage" role="tabpanel">
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Heritage')
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
                            <p>{{ Str::limit($d['description'], 85) }}</p>
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
                <a href="{{ route('trip') }}" class="btn btn-primary">🗺️ Plan Heritage Trip →</a>
            </div>
        </div>

        <!-- TAB: RELIGI -->
        <div class="tab-content" id="tab-content-religi" role="tabpanel">
            <div class="explore-grid">
                @foreach($destinations as $d)
                    @if($d['category'] === 'Religi')
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
                            <p>{{ Str::limit($d['description'], 85) }}</p>
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
                <a href="{{ route('trip') }}" class="btn btn-primary">🗺️ Plan Religi Trip →</a>
            </div>
        </div>

        <!-- TAB: CULINARY -->
        <div class="tab-content" id="tab-content-culinary" role="tabpanel">
            <div class="explore-grid">
                @foreach($culinary as $c)
                <div class="explore-card" id="explore-{{ $c['id'] }}">
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
                        <div class="explore-meta" style="margin-top:.3rem;">
                            <span>📍 {{ $c['distance'] }}</span>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
            <div class="tab-cta">
                <a href="{{ route('trip') }}" class="btn btn-primary">🍜 Tambah ke Trip →</a>
            </div>
        </div>

    </div>
</section>

@endsection

@section('scripts')
<style>
/* Explore quick stats */
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

/* Tab CTA */
.tab-cta { text-align: center; margin-top: 2.5rem; padding-top: 2rem; border-top: 1px dashed var(--border); }
</style>
@endsection
