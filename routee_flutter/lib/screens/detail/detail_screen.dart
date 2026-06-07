import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../core/data/culinary_data.dart';
import '../../core/models/destination_model.dart';
import '../../widgets/common/bounceable.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/language_provider.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final bookmark = context.watch<BookmarkProvider>();
    final isSaved = bookmark.isSaved(widget.id);

    DestinationModel? dest = DestinationsData.findById(widget.id);
    if (dest == null) {
      try {
        final cul = CulinaryData.culinary.firstWhere((c) => c.id == widget.id);
        dest = DestinationModel(
          id: cul.id,
          name: cul.name,
          category: 'Kuliner',
          image: cul.image,
          shortDesc: cul.desc,
          description: cul.desc,
          location: cul.area,
          hours: '09:00 – 22:00',
          ticket: cul.price,
          duration: cul.duration,
          rating: cul.rating,
          lat: 0.0,
          lng: 0.0,
        );
      } catch (_) {
        dest = DestinationsData.destinations.first;
      }
    }
    final destination = dest;

    Color catBg, catFg;
    String catIcon;
    switch (destination.category) {
      case 'Heritage':
        catBg = AppColors.heritageBg;
        catFg = AppColors.heritageFg;
        catIcon = '🏛';
        break;
      case 'Religi':
        catBg = AppColors.religiBg;
        catFg = AppColors.religiFg;
        catIcon = '🕌';
        break;
      default:
        catBg = AppColors.culinaryBg;
        catFg = AppColors.culinaryFg;
        catIcon = '🍜';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ─── HERO IMAGE (SliverAppBar with stretch & parallax) ─────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            stretchTriggerOffset: 120,
            backgroundColor: AppColors.primary,
            leading: Bounceable(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      double offset = 0.0;
                      if (_scrollController.hasClients) {
                        offset = _scrollController.offset;
                      }
                      // Parallax translation: move image slower than scroll
                      final translation = offset > 0 ? offset * 0.38 : 0.0;
                      return Transform.translate(
                        offset: Offset(0, translation),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      destination.image,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: AppColors.primarySurface,
                        child: const Icon(Icons.image_rounded, size: 60, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: catBg.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$catIcon ${destination.category}',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: catFg)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          destination.name,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📷 Sumber: ${destination.imageSource}',
                          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── CONTENT ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating + Action Buttons Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${destination.rating} (${language.translate('visitor_rating')})',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Save/Bookmark Button
                      Bounceable(
                        onTap: () {
                          bookmark.toggleSaveDestination(destination.id);
                          final msg = bookmark.isSaved(destination.id)
                              ? (language.localeCode == 'en' ? 'Saved to bookmarks' : 'Destinasi berhasil disimpan')
                              : (language.localeCode == 'en' ? 'Removed from bookmarks' : 'Destinasi dihapus dari simpanan');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSaved ? AppColors.accentSurface : AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isSaved ? AppColors.accent : AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share Button
                      Bounceable(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(language.translate('share_copied')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share_rounded, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.schedule_rounded,
                          label: language.translate('opening_hours'),
                          value: destination.hours,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.local_activity_rounded,
                          label: language.translate('ticket'),
                          value: destination.ticket,
                          color: destination.ticket.toLowerCase().contains('gratis')
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.timer_rounded,
                          label: language.translate('duration'),
                          value: destination.duration,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.location_on_rounded,
                          label: language.translate('location'),
                          value: destination.location,
                          color: AppColors.error,
                          isLong: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(language.translate('about_dest'),
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.7),
                  ),

                  const SizedBox(height: 28),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: Bounceable(
                      onTap: () {
                        context.go('/trip');
                      },
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.route_rounded),
                        label: Text(language.translate('add_to_trip')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Bounceable(
                      onTap: () {
                        context.go('/map');
                      },
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map_rounded),
                        label: Text(language.translate('view_on_map')),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLong;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: isLong ? 10 : 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: isLong ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
