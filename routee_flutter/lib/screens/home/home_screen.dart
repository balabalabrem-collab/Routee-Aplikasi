import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../core/data/culinary_data.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/culinary_card.dart';
import '../../widgets/common/bounceable.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = DestinationsData.destinations.take(6).toList();
    final featuredCulinary = CulinaryData.culinary.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── HERO SECTION ─────────────────────────────
          SliverToBoxAdapter(child: _HeroSection()),

          // ─── HOW IT WORKS ─────────────────────────────
          SliverToBoxAdapter(child: _HowItWorksSection()),

          // ─── STATS ROW ────────────────────────────────
          SliverToBoxAdapter(child: _StatsRow()),

          // ─── DESTINATIONS ─────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              label: 'Hidden Gems',
              title: 'Destinasi Heritage Surabaya',
              subtitle: 'Tempat bersejarah kaya cerita yang menunggu dijelajahi',
              actionLabel: 'Lihat Semua',
              onAction: () => context.go('/explore?category=Heritage'),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                itemCount: featured.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: EdgeInsets.only(right: i < featured.length - 1 ? 12 : 0),
                  child: SizedBox(
                    width: 200,
                    child: DestinationCard(
                      destination: featured[i],
                      onTap: () => context.push('/detail/${featured[i].id}'),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── CULINARY ─────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              label: 'Kuliner Legendaris',
              title: 'Wajib Dicoba di Surabaya',
              subtitle: 'Kuliner otentik dalam jangkauan rute perjalananmu',
              actionLabel: 'Lihat Semua',
              onAction: () => context.go('/explore?category=Kuliner'),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: featuredCulinary.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: EdgeInsets.only(right: i < featuredCulinary.length - 1 ? 12 : 0),
                  child: SizedBox(
                    width: 240,
                    child: CulinaryCard(culinary: featuredCulinary[i]),
                  ),
                ),
              ),
            ),
          ),

          // ─── CTA BANNER ───────────────────────────────
          SliverToBoxAdapter(child: _CtaBanner()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HERO SECTION
// ═══════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B2314), Color(0xFF6D4C2A), Color(0xFF8B6914)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: logo image + badge
              Row(
                children: [
                  // ── Logo Image ──
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.asset(
                      'assets/images/logo_baru.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (c, e, s) {
                        debugPrint('Error loading logo.png: $e');
                        return Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'R',
                              style: GoogleFonts.poppins(
                                color: AppColors.accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Brand text beside logo
                  Text(
                    'ROUTEE',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accent, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Heritage Trip',
                          style: GoogleFonts.poppins(
                            color: AppColors.accentLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Headline
              Text(
                'Where to go',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              Text(
                'today? 🤔',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Temukan hidden gems, situs heritage, dan kuliner legendaris Surabaya dalam 1 hari perjalanan efisien.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),

              // Image card stack
              _HeroImageRow(),

              const SizedBox(height: 28),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      label: '🗺️  Plan My Trip',
                      isPrimary: true,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton(
                      label: 'Explore',
                      isPrimary: false,
                      context: context,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isPrimary,
    required BuildContext context,
  }) {
    return Bounceable(
      onTap: () {
        if (isPrimary) {
          context.go('/trip');
        } else {
          context.go('/explore');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.accent : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isPrimary ? AppColors.textPrimary : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroImageRow extends StatelessWidget {
  final List<Map<String, String>> images = const [
    {'img': 'assets/images/Kampoeng Lawas Maspati.JPG.jpeg', 'name': 'Kampoeng Lawas Maspati'},
    {'img': 'assets/images/masjid cenghoo.jpg.jpeg', 'name': 'Masjid Cheng Hoo'},
    {'img': 'assets/images/makam sunan ampel.jpg.jpeg', 'name': 'Makam Sunan Ampel'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        children: images.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < images.length - 1 ? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item['img']!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.white12),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6, left: 6, right: 6,
                      child: Text(
                        item['name']!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HOW IT WORKS
// ═══════════════════════════════════════════════════════
class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      {'num': '01', 'icon': '🎯', 'title': 'Pilih Preferensi', 'desc': 'Heritage, religi, atau kuliner?'},
      {'num': '02', 'icon': '🗺️', 'title': 'Generate Itinerary', 'desc': 'Algoritma Routee susun rute terbaik'},
      {'num': '03', 'icon': '🚀', 'title': 'Mulai Perjalanan!', 'desc': 'Ikuti rute dan nikmati Surabaya'},
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cara Kerja', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('Perjalanan Cerdas dalam 3 Langkah', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((e) => _StepTile(step: e.value, isLast: e.key == steps.length - 1)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Bounceable(
              onTap: () => context.go('/trip'),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('🗺️  Mulai Rencanakan Trip'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final Map<String, String> step;
  final bool isLast;
  const _StepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(step['icon']!, style: const TextStyle(fontSize: 18)),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 24, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step['title']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(step['desc']!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// STATS ROW
// ═══════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'num': '17+', 'label': 'Destinasi'},
      {'num': '14', 'label': 'Kuliner'},
      {'num': '4.7★', 'label': 'Avg Rating'},
      {'num': '~Rp150rb', 'label': 'Per Trip'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: stats.asMap().entries.map((e) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: e.key < stats.length - 1
                      ? const Border(right: BorderSide(color: AppColors.divider))
                      : null,
                ),
                child: Column(
                  children: [
                    Text(e.value['num']!, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(e.value['label']!, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.label, required this.title, required this.subtitle,
    required this.actionLabel, required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Bounceable(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 9,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CTA BANNER
// ═══════════════════════════════════════════════════════
class _CtaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D4C2A), Color(0xFF4A3219)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            'Siap Jelajahi Surabaya?',
            style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Buat itinerary 1-hari terbaikmu sekarang — gratis, cepat, dan tanpa ribet.',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Bounceable(
                  onTap: () => context.go('/trip'),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('Plan My Trip'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Bounceable(
                  onTap: () => context.go('/explore'),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Explore Dulu'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
