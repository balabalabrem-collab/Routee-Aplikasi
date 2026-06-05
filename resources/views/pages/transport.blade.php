@extends('layouts.app')

@section('title', 'Transportasi — Routee Surabaya')

@section('content')

<div class="page-hero page-hero-sm">
    <div class="container">
        <span class="section-label">Mobilitas</span>
        <h1>Pilihan Transportasi</h1>
        <p>Pilih armada yang paling sesuai dengan budget dan kenyamananmu untuk menjelajah Surabaya.</p>
    </div>
</div>

<section class="section" id="transport-section">
    <div class="container">

        <!-- Back to Trip -->
        <div style="margin-bottom:2rem;">
            <a href="{{ route('trip') }}" class="btn btn-outline btn-sm" id="back-to-trip">
                ← Kembali ke Itinerary
            </a>
        </div>

        <!-- TRANSPORT CARDS -->
        <div class="transport-grid" id="transport-options">
            @foreach($options as $opt)
            <div class="transport-card" id="transport-{{ $opt['id'] }}" style="overflow: hidden; position: relative;">
                <div style="margin: -2.5rem -2.5rem 1.5rem -2.5rem; width: calc(100% + 5rem); max-width: none;">
                    <!-- IMAGE: {{ $opt['name'] }} Transport -->
                    <img src="/images/{{ $opt['image'] }}" alt="{{ $opt['name'] }}" style="width: 100%; height: 200px; object-fit: cover; display: block;" onerror="this.src='/images/placeholder.jpg'">
                </div>
                <div class="transport-icon-wrap" style="position: relative; margin-top: -4rem; background: var(--bg-card); display: inline-flex; align-items: center; justify-content: center; width: 4.5rem; height: 4.5rem; border-radius: 50%; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border: 4px solid var(--bg-card); margin-bottom: 1rem;">
                    <span class="transport-icon" style="margin:0; font-size: 2rem;">{{ $opt['icon'] }}</span>
                </div>
                <div class="transport-body">
                    <h3>{{ $opt['name'] }}</h3>
                    <div class="transport-price">{{ $opt['price'] }}</div>
                    <p>{{ $opt['desc'] }}</p>

                    <div class="transport-pros-cons">
                        <div class="pros">
                            <strong>✅ Keuntungan</strong>
                            <ul>
                                @foreach($opt['pros'] as $pro)
                                <li>{{ $pro }}</li>
                                @endforeach
                            </ul>
                        </div>
                        <div class="cons">
                            <strong>⚠️ Pertimbangan</strong>
                            <ul>
                                @foreach($opt['cons'] as $con)
                                <li>{{ $con }}</li>
                                @endforeach
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="transport-footer" style="padding: 1.5rem;">
                    <div style="background: #f8f9fa; padding: 1rem; border-radius: 8px; text-align: center; color: var(--text-muted); font-size: 0.9rem;">
                        Tersedia di area kedatangan atau dapat dipesan melalui aplikasi terpercaya.
                    </div>
                </div>
            </div>
            @endforeach
        </div>



        <!-- COMPARISON TABLE -->
        <div class="comparison-section" id="comparison-table" style="margin-top:4rem;">
            <h2>📊 Perbandingan Lengkap</h2>
            <div class="table-wrap">
                <table class="comparison-table">
                    <thead>
                        <tr>
                            <th>Aspek</th>
                            <th>🛵 Motor</th>
                            <th>🚗 Mobil + Driver</th>
                            <th>🏆 Private Tour</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Harga</td>
                            <td class="best">Rp 70.000/hari</td>
                            <td>Rp 300.000/hari</td>
                            <td>Mulai Rp 500.000</td>
                        </tr>
                        <tr>
                            <td>Kapasitas</td>
                            <td>1–2 orang</td>
                            <td class="best">4–6 orang</td>
                            <td>Fleksibel</td>
                        </tr>
                        <tr>
                            <td>Kenyamanan</td>
                            <td>⭐⭐⭐</td>
                            <td class="best">⭐⭐⭐⭐⭐</td>
                            <td>⭐⭐⭐⭐⭐</td>
                        </tr>
                        <tr>
                            <td>Kemudahan Parkir</td>
                            <td class="best">Sangat Mudah</td>
                            <td>Terbatas</td>
                            <td>Driver Handle</td>
                        </tr>
                        <tr>
                            <td>Panduan Wisata</td>
                            <td>Tidak Ada</td>
                            <td>Tidak Ada</td>
                            <td class="best">Termasuk</td>
                        </tr>
                        <tr>
                            <td>Rekomendasi untuk</td>
                            <td class="best">Solo / Couple</td>
                            <td>Keluarga</td>
                            <td class="best">Premium Experience</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- BACK TO TRIP CTA -->
        <div style="text-align:center; margin-top:3rem;">
            <a href="{{ route('trip') }}" class="btn btn-primary btn-lg">
                📅 Kembali ke Itinerary →
            </a>
        </div>

    </div>
</section>

@endsection

@section('scripts')
<script>

</script>
@endsection
