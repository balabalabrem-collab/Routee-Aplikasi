import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../core/data/culinary_data.dart';
import '../../core/models/destination_model.dart';
import '../../providers/explore_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/bounceable.dart';

import '../../core/data/umkm_data.dart';
import '../../core/models/umkm_model.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;
  const ExploreScreen({super.key, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> tabs = [
    {'label': '🏛  Heritage', 'key': 'Heritage'},
    {'label': '🕌  Religi', 'key': 'Religi'},
    {'label': '🍜  Kuliner', 'key': 'Kuliner'},
    {'label': '🛍️  UMKM', 'key': 'UMKM'},
  ];

  @override
  void initState() {
    super.initState();
    
    int initialIndex = 0;
    if (widget.initialCategory != null) {
      final idx = tabs.indexWhere((t) => t['key'] == widget.initialCategory);
      if (idx >= 0) {
        initialIndex = idx;
      }
    }

    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);

    final initialTabKey = tabs[initialIndex]['key'] as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().setTab(initialTabKey);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final tab = tabs[_tabController.index]['key'] as String;
      context.read<ExploreProvider>().setTab(tab);
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: AppColors.primary,
            flexibleSpace: _CollapsingExploreAppbarSpace(
              title: language.translate('explore'),
              subtitle: language.translateText(
                id: 'Jelajahi Semua Destinasi & Kuliner',
                en: 'Explore All Destinations & Culinary',
              ),
              expandedHeight: 150,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                height: 50, // explicitly constrain height to match PreferredSize
                color: AppColors.primary,
                child: TabBar(
                  controller: _tabController,
                  tabs: tabs.map((t) {
                    String label = t['label'] as String;
                    if (t['key'] == 'Religi') {
                      label = language.translateText(id: '🕌  Religi', en: '🕌  Religious');
                    } else if (t['key'] == 'Kuliner') {
                      label = language.translateText(id: '🍜  Kuliner', en: '🍜  Culinary');
                    }
                    return Tab(text: label);
                  }).toList(),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: AppColors.accent,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Stats Row
            _StatsBar(),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => context.read<ExploreProvider>().setSearch(q),
                decoration: InputDecoration(
                  hintText: language.translateText(
                    id: 'Cari destinasi, kuliner...',
                    en: 'Search destinations, culinary...',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ExploreProvider>().setSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DestinationTabView(category: 'Heritage'),
                  _DestinationTabView(category: 'Religi'),
                  _CulinaryTabView(),
                  _UmkmTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final stats = [
      {'n': '${DestinationsData.destinations.length}', 'l': language.translateText(id: 'Destinasi', en: 'Destinations')},
      {'n': '${CulinaryData.culinary.length}', 'l': language.translateText(id: 'Kuliner', en: 'Culinary')},
      {'n': '4.7★', 'l': language.translateText(id: 'Avg Rating', en: 'Avg Rating')},
      {'n': '~Rp150rb', 'l': language.translateText(id: 'Per Trip', en: 'Per Trip')},
    ];

    return Container(
      color: AppColors.surface,
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
                  Text(e.value['n']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text(e.value['l']!, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// DESTINATION TAB
// ═══════════════════════════════════════════════════════
class _DestinationTabView extends StatelessWidget {
  final String category;
  const _DestinationTabView({required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreProvider>(
      builder: (ctx, provider, _) {
        final q = provider.searchQuery;
        final all = DestinationsData.byCategory(category);
        final filtered = q.isEmpty
            ? all
            : all.where((d) =>
                d.name.toLowerCase().contains(q) ||
                d.shortDesc.toLowerCase().contains(q) ||
                d.location.toLowerCase().contains(q)).toList();

        if (filtered.isEmpty) {
          return _EmptySearch(query: q);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DestinationListCard(destination: filtered[i]),
          ),
        );
      },
    );
  }
}

class _DestinationListCard extends StatelessWidget {
  final DestinationModel destination;
  const _DestinationListCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    Color bg;
    String icon;
    switch (destination.category) {
      case 'Heritage': bg = AppColors.heritageBg; icon = '🏛'; break;
      case 'Religi': bg = AppColors.religiBg; icon = '🕌'; break;
      default: bg = AppColors.culinaryBg; icon = '🍜';
    }

    return Bounceable(
      onTap: () => context.push('/detail/${destination.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      destination.image,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: bg.withOpacity(0.9), borderRadius: BorderRadius.circular(5)),
                        child: Text('$icon', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.accent, size: 11),
                              const SizedBox(width: 2),
                              Text(
                                '${destination.rating}',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(destination.shortDesc, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        _MetaChip(icon: Icons.schedule_rounded, label: destination.duration),
                        _MetaChip(
                          icon: Icons.local_activity_rounded,
                          label: destination.ticket == 'Gratis'
                              ? language.translateText(id: 'Gratis', en: 'Free')
                              : destination.ticket,
                          isGreen: destination.ticket == 'Gratis',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),);
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isGreen;
  const _MetaChip({required this.icon, required this.label, this.isGreen = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isGreen ? AppColors.religiBg : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: isGreen ? AppColors.religiFg : AppColors.textMuted),
          const SizedBox(width: 3),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: isGreen ? AppColors.religiFg : AppColors.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CULINARY TAB
// ═══════════════════════════════════════════════════════
class _CulinaryTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreProvider>(
      builder: (ctx, provider, _) {
        final q = provider.searchQuery;
        final all = CulinaryData.culinary;
        final filtered = q.isEmpty
            ? all
            : all.where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.area.toLowerCase().contains(q) ||
                c.group.toLowerCase().contains(q)).toList();

        if (filtered.isEmpty) {
          return _EmptySearch(query: q);
        }

        // Group by group field
        final groups = <String, List<dynamic>>{};
        for (final c in filtered) {
          groups.putIfAbsent(c.group, () => []).add(c);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          children: groups.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GroupHeader(title: entry.key),
                const SizedBox(height: 8),
                ...entry.value.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CulinaryListCard(culinary: c),
                )),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}

class _CulinaryListCard extends StatelessWidget {
  final dynamic culinary;
  const _CulinaryListCard({required this.culinary});

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => context.push('/detail/${culinary.id}'),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 90,
              child: Image.asset(culinary.image, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant)),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(culinary.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accent, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${culinary.rating}',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(culinary.price, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.culinaryFg)),
                  const SizedBox(height: 3),
                  Text(culinary.desc, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(culinary.area, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.culinaryBg, borderRadius: BorderRadius.circular(4)),
                        child: Text(culinary.distance, style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.culinaryFg)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),),);
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(language.translateText(id: 'Tidak ditemukan', en: 'No results found'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(language.translateText(id: 'Coba kata kunci lain untuk "$query"', en: 'Try other keywords for "$query"'), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _CollapsingExploreAppbarSpace extends StatelessWidget {
  final String title;
  final String subtitle;
  final double expandedHeight;

  const _CollapsingExploreAppbarSpace({
    required this.title,
    required this.subtitle,
    required this.expandedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double currentHeight = constraints.maxHeight;
        final double statusBarHeight = MediaQuery.of(context).padding.top;
        final double collapsedHeight = kToolbarHeight + statusBarHeight + 50.0; // including TabBar height

        // Calculate progress (1.0 = expanded, 0.0 = collapsed)
        final double progress = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.primary),

            // Collapsed Title (shows when collapsed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: kToolbarHeight + statusBarHeight,
              child: Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Expanded Header (shows when expanded, title on top, subtitle on bottom, pushed up by TabBar)
            if (progress > 0.15)
              Opacity(
                opacity: progress,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 62), // pushed up to clear TabBar (50px) + spacing
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UmkmTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    return Consumer<ExploreProvider>(
      builder: (ctx, provider, _) {
        final filters = [
          {'key': 'all', 'label': language.translateText(id: '🏪 Semua', en: '🏪 All')},
          {'key': 'fashion', 'label': language.translateText(id: '👗 Fashion', en: '👗 Fashion')},
          {'key': 'food', 'label': language.translateText(id: '🍜 Makanan', en: '🍜 Food')},
          {'key': 'craft', 'label': language.translateText(id: '🎨 Kerajinan', en: '🎨 Craft')},
        ];

        final filtered = provider.umkmFilter == 'all'
            ? UmkmData.products
            : UmkmData.products.where((p) => p.category == provider.umkmFilter).toList();

        return Column(
          children: [
            // Filter chips
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                children: filters.map((f) {
                  final isSelected = provider.umkmFilter == f['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Bounceable(
                      onTap: () => provider.setUmkmFilter(f['key']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.umkmFg : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.umkmFg : AppColors.divider),
                        ),
                        child: Center(
                          child: Text(
                            f['label']!,
                            style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Grid content
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📦', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(language.translateText(id: 'Tidak ada produk di kategori ini', en: 'No products in this category'), style: GoogleFonts.poppins(color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _UmkmGridCard(product: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _UmkmGridCard extends StatelessWidget {
  final UmkmModel product;
  const _UmkmGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    String catLabel;
    Color catBg, catFg;
    switch (product.category) {
      case 'fashion': catLabel = '👗 Fashion'; catBg = AppColors.primarySurface; catFg = AppColors.primaryDark; break;
      case 'food': catLabel = '🍜 Makanan'; catBg = AppColors.primarySurface; catFg = AppColors.primaryDark; break;
      default: catLabel = '🎨 Kerajinan'; catBg = AppColors.umkmBg; catFg = AppColors.umkmFg;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant, child: const Icon(Icons.image_rounded, size: 32, color: AppColors.textMuted)),
                ),
                // Gradient overlay
                Container(
                  decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                ),
                // Category badge
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: catBg.withOpacity(0.92), borderRadius: BorderRadius.circular(6)),
                    child: Text(catLabel, style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w700, color: catFg)),
                  ),
                ),
                // Rating
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accentLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.seller, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(product.name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                const SizedBox(height: 4),
                Text(product.price, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
