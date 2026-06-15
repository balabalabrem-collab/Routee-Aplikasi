import 'dart:async';
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

          // ─── CONTACT ADMIN ─────────────────────────────
          const SliverToBoxAdapter(child: _ContactAdminSection()),

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

              // Image slider
              const _HeroImageSlider(),

              _CtaBanner(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImageSlider extends StatefulWidget {
  const _HeroImageSlider({super.key});

  @override
  State<_HeroImageSlider> createState() => _HeroImageSliderState();
}

class _HeroImageSliderState extends State<_HeroImageSlider> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  final List<Map<String, String>> images = const [
    {'img': 'assets/images/Kampoeng Lawas Maspati.JPG.jpeg', 'name': 'Kampoeng Lawas Maspati'},
    {'img': 'assets/images/gedung javasche bank.JPG.jpeg', 'name': 'Gedung De Javasche Bank'},
    {'img': 'assets/images/jalan tunjungan.JPG.jpeg', 'name': 'Jalan Tunjungan'},
    {'img': 'assets/images/museum siola.JPG.jpeg', 'name': 'Museum Surabaya (Siola)'},
    {'img': 'assets/images/kawasan kota lama.JPG.jpeg', 'name': 'Kawasan Kota Lama'},
    {'img': 'assets/images/alun alun surabaya.JPG.jpeg', 'name': 'Alun-Alun Surabaya'},
    {'img': 'assets/images/masjid cenghoo.jpg.jpeg', 'name': 'Masjid Cheng Hoo'},
    {'img': 'assets/images/makam sunan ampel.jpg.jpeg', 'name': 'Makam Sunan Ampel'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= images.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                final item = images[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item['img']!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.white.withOpacity(0.08),
                        child: const Icon(Icons.image, color: Colors.white24, size: 40),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xAA000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 14,
                      right: 14,
                      child: Text(
                        item['name']!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 14,
            right: 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: _currentPage == index ? 14 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (e.value['num']!.contains('★'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e.value['num']!.replaceAll('★', ''),
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.2),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star_rounded, color: AppColors.primary, size: 15),
                        ],
                      )
                    else
                      Text(e.value['num']!, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.2)),
                    const SizedBox(height: 2),
                    Text(e.value['label']!, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500, height: 1.2)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
// CONTACT ADMIN SECTION
// ═══════════════════════════════════════════════════════
class _ContactAdminSection extends StatelessWidget {
  const _ContactAdminSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Bounceable(
              onTap: () => ContactAdminSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/—Pngtree—whatsapp icon whatsapp logo whatsapp_3584845.png',
                      height: 18,
                      width: 18,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WhatsApp',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/—Pngtree—instagram icon instagram logo vector_3584852.png',
                      height: 18,
                      width: 18,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Instagram',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

