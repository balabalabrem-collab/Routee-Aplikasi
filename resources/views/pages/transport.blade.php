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
            <div class="transport-card" id="transport-{{ $opt['id'] }}">
                <div class="transport-icon-wrap">
                    <span class="transport-icon">{{ $opt['icon'] }}</span>
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
                <div class="transport-footer">
                    <button class="btn btn-primary btn-block"
                            id="book-{{ $opt['id'] }}"
                            onclick="bookTransport(event, '{{ $opt['name'] }}', '{{ $opt['price'] }}')">
                        Pilih {{ $opt['name'] }}
                    </button>
                </div>
            </div>
            @endforeach
        </div>

        <!-- BOOKING CONFIRMATION MODAL -->
        <div class="modal-overlay" id="booking-modal" style="display:none;">
            <div class="modal-box">
                <div class="modal-icon">🎉</div>
                <h2>Transportasi Dipilih!</h2>
                <p>Kamu telah memilih <strong id="booking-name"></strong> dengan tarif <strong id="booking-price"></strong> per hari.</p>
                <p style="color:var(--text-muted);font-size:.86rem;margin-top:.5rem;">
                    Hubungi penyedia melalui aplikasi Gojek / Grab / lokal, atau langsung ke lokasi.
                </p>
                <div class="modal-actions">
                    <a href="{{ route('trip') }}" class="btn btn-primary" id="modal-to-trip">📅 Lihat Itinerary</a>
                    <button class="btn btn-outline" data-modal-close>Tutup</button>
                </div>
            </div>
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
function bookTransport(e, name, price) {
    e.stopPropagation();
    // Select the card
    const card = e.target.closest('.transport-card');
    document.querySelectorAll('.transport-card').forEach(c => c.classList.remove('selected'));
    if (card) card.classList.add('selected');

    // Show modal
    document.getElementById('booking-name').textContent  = name;
    document.getElementById('booking-price').textContent = price;
    document.getElementById('booking-modal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

// Close modal via [data-modal-close] buttons  (global JS handles this too, but be explicit)
document.querySelectorAll('[data-modal-close]').forEach(btn => {
    btn.addEventListener('click', () => {
        document.getElementById('booking-modal').style.display = 'none';
        document.body.style.overflow = '';
    });
});

// Backdrop close
document.getElementById('booking-modal').addEventListener('click', function(e) {
    if (e.target === this) {
        this.style.display = 'none';
        document.body.style.overflow = '';
    }
});
</script>
@endsection
