import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/language_provider.dart';

class HeritagePassportSheet extends StatelessWidget {
  const HeritagePassportSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const HeritagePassportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmark = context.watch<BookmarkProvider>();
    final trip = context.watch<TripProvider>();
    final language = context.watch<LanguageProvider>();
    final isEn = language.localeCode == 'en';

    // Calculate progress for each badge
    final visitedIds = bookmark.visitedDestinationIds;
    int heritageVisited = 0;
    int religiVisited = 0;
    int culinaryVisited = 0;

    for (var id in visitedIds) {
      final dest = DestinationsData.findById(id);
      if (dest != null) {
        if (dest.category == 'Heritage') heritageVisited++;
        if (dest.category == 'Religi') religiVisited++;
        if (dest.category == 'Kuliner') culinaryVisited++;
      }
    }

    final hasHeritageBadge = heritageVisited >= 3;
    final hasReligiBadge = religiVisited >= 2;
    final hasCulinaryBadge = culinaryVisited >= 2;
    final hasTripCompletedBadge = trip.visitedSpots.isNotEmpty && trip.visitedSpots.length >= (trip.currentItinerary?.spots.length ?? 999);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🛂', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                isEn ? 'Heritage Passport' : 'Paspor Heritage',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? 'Your virtual badge collection of Surabaya adventures'
                : 'Koleksi lencana bukti petualangan sejarah Anda di Surabaya',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Badges Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildBadgeCard(
                icon: '🏛',
                title: 'Heritage Explorer',
                desc: isEn ? 'Visit 3+ historical spots' : 'Kunjungi 3+ tempat sejarah',
                current: heritageVisited,
                target: 3,
                isUnlocked: hasHeritageBadge,
                color: AppColors.heritageFg,
              ),
              _buildBadgeCard(
                icon: '🕌',
                title: 'Spiritual Pilgrim',
                desc: isEn ? 'Visit 2+ religious sites' : 'Kunjungi 2+ tempat religi',
                current: religiVisited,
                target: 2,
                isUnlocked: hasReligiBadge,
                color: AppColors.religiFg,
              ),
              _buildBadgeCard(
                icon: '🍜',
                title: 'Surabaya Foodie',
                desc: isEn ? 'Visit 2+ culinary spots' : 'Kunjungi 2+ kuliner lokal',
                current: culinaryVisited,
                target: 2,
                isUnlocked: hasCulinaryBadge,
                color: AppColors.culinaryFg,
              ),
              _buildBadgeCard(
                icon: '🏅',
                title: 'Active Voyager',
                desc: isEn ? 'Complete 1 itinerary route' : 'Selesaikan 1 rute trip',
                current: hasTripCompletedBadge ? 1 : 0,
                target: 1,
                isUnlocked: hasTripCompletedBadge,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required String icon,
    required String title,
    required String desc,
    required int current,
    required int target,
    required bool isUnlocked,
    required Color color,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? color.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.3) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon wrapper
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.12) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Description
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Progress indicator & label
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Unlocked',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: AppColors.textMuted,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$current / $target',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
