import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/models/culinary_model.dart';
import 'common/bounceable.dart';

class CulinaryCard extends StatelessWidget {
  final CulinaryModel culinary;
  const CulinaryCard({super.key, required this.culinary});

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => context.push('/detail/${culinary.id}'),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
          SizedBox(
            width: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  culinary.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          culinary.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '★ ${culinary.rating}',
                        style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    culinary.price,
                    style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.culinaryFg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          culinary.area,
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.culinaryBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      culinary.distance,
                      style: GoogleFonts.poppins(
                        fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.culinaryFg,
                      ),
                    ),
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
