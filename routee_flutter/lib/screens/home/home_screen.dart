import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/data/destinations_data.dart';
import '../../core/data/culinary_data.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/culinary_card.dart';
import '../../widgets/common/bounceable.dart';
import '../../widgets/common/contact_admin_sheet.dart';

import '../../providers/home_scroll_provider.dart';
import '../../providers/language_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = DestinationsData.destinations.take(6).toList();
    final featuredCulinary = CulinaryData.culinary.take(4).toList();
    final homeScroll = context.watch<HomeScrollProvider>();
    final language = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: homeScroll.scrollController,
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
              label: language.translateText(id: 'Hidden Gems', en: 'Hidden Gems'),
              title: language.translateText(id: 'Destinasi Heritage Surabaya', en: 'Surabaya Heritage Destinations'),
              subtitle: language.translateText(id: 'Tempat bersejarah kaya cerita yang menunggu dijelajahi', en: 'Historic places rich in stories waiting to be explored'),
              actionLabel: language.translateText(id: 'Lihat Semua', en: 'View All'),
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
              label: language.translateText(id: 'Kuliner Legendaris', en: 'Legendary Culinary'),
              title: language.translateText(id: 'Wajib Dicoba di Surabaya', en: 'Must-Try in Surabaya'),
              subtitle: language.translateText(id: 'Kuliner otentik dalam jangkauan rute perjalananmu', en: 'Authentic culinary within your travel route'),
              actionLabel: language.translateText(id: 'Lihat Semua', en: 'View All'),
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

          // ─── SEWA TRANSPORTASI CTA ─────────────────────
          SliverToBoxAdapter(child: _TransportCta()),

          // ─── HUBUNGI KAMI ──────────────────────────────
          SliverToBoxAdapter(child: _ContactSection()),

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
    final language = context.watch<LanguageProvider>();
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
                      'assets/images/logo v2.png',
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
                          language.translateText(id: 'Rute Warisan', en: 'Heritage Trip'),
                          style: GoogleFonts.poppins(
                            color: AppColors.accentLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final isLoggedIn = auth.isLoggedIn;
                      final user = auth.currentUser;
                      final nameInitial = isLoggedIn && user != null && user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?';

                      return GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: isLoggedIn
                                ? const LinearGradient(
                                    colors: [AppColors.accent, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isLoggedIn ? null : Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLoggedIn ? AppColors.accent : Colors.white54,
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isLoggedIn)
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                            ],
                          ),
                          child: Center(
                            child: isLoggedIn
                                ? Text(
                                    nameInitial,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Headline
              Text(
                language.translateText(id: 'Mau ke mana', en: 'Where to go'),
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              Text(
                language.translateText(id: 'hari ini? 🤔', en: 'today? 🤔'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                language.translateText(
                  id: 'Temukan permata tersembunyi, situs sejarah, dan kuliner legendaris Surabaya dalam 1 hari perjalanan efisien.',
                  en: 'Discover hidden gems, heritage sites, and legendary culinary delights of Surabaya in an efficient 1-day trip.',
                ),
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 12),

              // Slogan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Text(
                  '"${AppStrings.slogan}"',
                  style: GoogleFonts.poppins(
                    color: AppColors.accentLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                  ),
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
                      label: language.translateText(id: '🗺️  Rencanakan Trip', en: '🗺️  Plan My Trip'),
                      isPrimary: true,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton(
                      label: language.translate('explore'),
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
    final language = context.watch<LanguageProvider>();
    final steps = [
      {
        'num': '01',
        'icon': '🎯',
        'title': language.translateText(id: 'Pilih Preferensi', en: 'Select Preferences'),
        'desc': language.translateText(id: 'Heritage, religi, atau kuliner?', en: 'Heritage, religion, or culinary?')
      },
      {
        'num': '02',
        'icon': '🗺️',
        'title': language.translateText(id: 'Generate Itinerary', en: 'Generate Itinerary'),
        'desc': language.translateText(id: 'Algoritma Routee susun rute terbaik', en: 'Routee\'s algorithm plans the best route')
      },
      {
        'num': '03',
        'icon': '🚀',
        'title': language.translateText(id: 'Mulai Perjalanan!', en: 'Start Journey!'),
        'desc': language.translateText(id: 'Ikuti rute dan nikmati Surabaya', en: 'Follow the route and enjoy Surabaya')
      },
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.translateText(id: 'Cara Kerja', en: 'How it Works'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(language.translateText(id: 'Perjalanan Cerdas dalam 3 Langkah', en: 'Smart Travel in 3 Steps'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((e) => _StepTile(step: e.value, isLast: e.key == steps.length - 1)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Bounceable(
              onTap: () => context.go('/trip'),
              child: ElevatedButton(
                onPressed: () {},
                child: Text('🗺️  ' + language.translateText(id: 'Mulai Rencanakan Trip', en: 'Start Planning Trip')),
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
    final language = context.watch<LanguageProvider>();
    final stats = [
      {'num': '17+', 'label': language.translateText(id: 'Destinasi', en: 'Destinations')},
      {'num': '14', 'label': language.translateText(id: 'Kuliner', en: 'Culinary')},
      {'num': '4.7★', 'label': language.translateText(id: 'Avg Rating', en: 'Avg Rating')},
      {'num': '~Rp150rb', 'label': language.translateText(id: 'Per Trip', en: 'Per Trip')},
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
    final language = context.watch<LanguageProvider>();
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
            language.translateText(id: 'Siap Jelajahi Surabaya?', en: 'Ready to Explore Surabaya?'),
            style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            language.translateText(
              id: 'Buat itinerary 1-hari terbaikmu sekarang — gratis, cepat, dan tanpa ribet.',
              en: 'Create your best 1-day itinerary now — free, fast, and hassle-free.',
            ),
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
                    child: Text(language.translateText(id: 'Rencana Trip', en: 'Plan My Trip')),
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
                    child: Text(language.translateText(id: 'Jelajah Dulu', en: 'Explore First')),
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

// ═══════════════════════════════════════════════════════
// TRANSPORT CTA
// ═══════════════════════════════════════════════════════
class _TransportCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A3219), Color(0xFF6D4C2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.translateText(id: 'Butuh Transportasi?', en: 'Need Transportation?'),
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  language.translateText(
                    id: 'Sewa motor atau mobil + driver berpengalaman untuk perjalanan nyaman.',
                    en: 'Rent a motorbike or car + experienced driver for a comfortable journey.',
                  ),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 12),
                Bounceable(
                  onTap: () => context.go('/rental'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      language.translateText(id: 'Lihat Kendaraan →', en: 'View Vehicles →'),
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: const Text('🚗', style: TextStyle(fontSize: 32)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CONTACT SECTION
// ═══════════════════════════════════════════════════════
class _ContactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.translateText(id: 'Hubungi Kami', en: 'Contact Us'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(language.translateText(id: 'Butuh Bantuan?', en: 'Need Help?'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(language.translateText(id: 'Tim admin siap membantu melalui WhatsApp atau Instagram', en: 'Our admin team is ready to help via WhatsApp or Instagram'), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Bounceable(
                  onTap: () => ContactAdminSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 18),
                        const SizedBox(width: 8),
                        Text('WhatsApp', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF25D366))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Bounceable(
                  onTap: () => ContactAdminSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1306C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE1306C).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: Color(0xFFE1306C), size: 18),
                        const SizedBox(width: 8),
                        Text('Instagram', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFE1306C))),
                      ],
                    ),
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
