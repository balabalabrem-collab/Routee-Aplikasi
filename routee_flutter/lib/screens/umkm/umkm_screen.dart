import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/umkm_data.dart';
import '../../core/models/umkm_model.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/common/bounceable.dart';

class UmkmScreen extends StatelessWidget {
  const UmkmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 95,
            flexibleSpace: _CollapsingAppbarSpace(
              title: 'UMKM Lokal',
              subtitle: 'Produk autentik pengusaha lokal Surabaya',
              expandedHeight: 95,
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              child: Row(
                children: [
                  {'n': '${UmkmData.products.length}', 'l': 'Produk'},
                  {'n': '200+', 'l': 'UMKM Aktif'},
                  {'n': '4.7★', 'l': 'Avg Rating'},
                  {'n': '90%', 'l': 'Produk Lokal'},
                ].asMap().entries.map((e) {
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: e.key < 3 ? const Border(right: BorderSide(color: AppColors.divider)) : null,
                      ),
                      child: Column(
                        children: [
                          Text(e.value['n']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.umkmFg)),
                          Text(e.value['l']!, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Filter chips (Sticky)
          SliverPersistentHeader(
            pinned: true,
            delegate: _UmkmFilterHeaderDelegate(
              child: Consumer<ExploreProvider>(
                builder: (ctx, provider, _) {
                  final filters = [
                    {'key': 'all', 'label': '🏪 Semua'},
                    {'key': 'fashion', 'label': '👗 Fashion'},
                    {'key': 'food', 'label': '🍜 Makanan'},
                    {'key': 'craft', 'label': '🎨 Kerajinan'},
                  ];

                  return ListView(
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
                  );
                },
              ),
            ),
          ),

          // Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            sliver: Consumer<ExploreProvider>(
              builder: (ctx, provider, _) {
                final filtered = provider.umkmFilter == 'all'
                    ? UmkmData.products
                    : UmkmData.products.where((p) => p.category == provider.umkmFilter).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            const Text('📦', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text('Tidak ada produk di kategori ini', style: GoogleFonts.poppins(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _UmkmCard(product: filtered[i]),
                    childCount: filtered.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UmkmCard extends StatelessWidget {
  final UmkmModel product;
  const _UmkmCard({required this.product});

  void _showProductDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image_rounded, size: 48, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Vendor & Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.seller,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Product Name
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              
              // Price
              Text(
                product.price,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.umkmFg,
                ),
              ),
              const SizedBox(height: 16),
              
              // Contact Number Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_iphone_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kontak Penjual / WhatsApp',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            product.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Contact action simulator
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Menghubungi ${product.seller} di ${product.phone} via WhatsApp...',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(
                    'Hubungi Penjual (WhatsApp)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String catLabel;
    Color catBg, catFg;
    switch (product.category) {
      case 'fashion': catLabel = '👗 Fashion'; catBg = AppColors.primarySurface; catFg = AppColors.primaryDark; break;
      case 'food': catLabel = '🍜 Makanan'; catBg = AppColors.primarySurface; catFg = AppColors.primaryDark; break;
      default: catLabel = '🎨 Kerajinan'; catBg = AppColors.umkmBg; catFg = AppColors.umkmFg;
    }

    return Bounceable(
      onTap: () => _showProductDetail(context),
      child: Container(
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
                      child: Text('★ ${product.rating}', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accentLight)),
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
      ),
    );
  }
}

class _CollapsingAppbarSpace extends StatelessWidget {
  final String title;
  final String subtitle;
  final double expandedHeight;

  const _CollapsingAppbarSpace({
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
        final double collapsedHeight = kToolbarHeight + statusBarHeight;

        // Calculate progress (1.0 = expanded, 0.0 = collapsed)
        final double progress = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.primary),

            // Collapsed Title (shows when collapsed)
            Opacity(
              opacity: (1.0 - progress).clamp(0.0, 1.0),
              child: SafeArea(
                child: Container(
                  height: kToolbarHeight,
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

            // Expanded Header (shows when expanded, title on top, subtitle on bottom)
            if (progress > 0.15)
              Opacity(
                opacity: progress,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
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

class _UmkmFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _UmkmFilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent ? AppColors.divider : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant _UmkmFilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
