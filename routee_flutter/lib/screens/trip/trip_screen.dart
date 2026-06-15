import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/terminal_data.dart';
import '../../core/data/destinations_data.dart';
import '../../core/models/itinerary_model.dart';
import '../../providers/trip_provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/bounceable.dart';
import '../../providers/language_provider.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 95,
            flexibleSpace: _CollapsingAppbarSpace(
              title: language.translate('trip_planner'),
              subtitle: language.translate('trip_subtitle'),
              expandedHeight: 95,
            ),
          ),

          SliverToBoxAdapter(
            child: Consumer<TripProvider>(
              builder: (ctx, trip, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Config panel
                    _ConfigPanel(trip: trip),

                    // Result or placeholder
                    if (trip.isGenerating)
                      _LoadingView()
                    else if (trip.currentItinerary != null)
                      _ItineraryView(itinerary: trip.currentItinerary!)
                    else
                      _EmptyState(),

                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CONFIG PANEL
// ═══════════════════════════════════════════════════════
class _ConfigPanel extends StatelessWidget {
  final TripProvider trip;
  const _ConfigPanel({required this.trip});

  void _showDestinationPicker(BuildContext context, TripProvider trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DestinationPickerSheet(trip: trip),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Departure Terminal Selection
          Text('📍 Titik Keberangkatan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: TerminalData.terminals.map((t) {
              final isSelected = trip.selectedTerminalId == t.id;
              return GestureDetector(
                onTap: () => context.read<TripProvider>().selectTerminal(t.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    '${t.icon} ${t.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Planning Mode Selection Toggle
          Text('⚙️ Metode Perencanaan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => trip.setCustomMode(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !trip.isCustomMode ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !trip.isCustomMode ? AppColors.primary : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '🤖 Rute Otomatis',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: !trip.isCustomMode ? FontWeight.w700 : FontWeight.w500,
                          color: !trip.isCustomMode ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => trip.setCustomMode(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: trip.isCustomMode ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: trip.isCustomMode ? AppColors.primary : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '✍️ Rute Kustom',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: trip.isCustomMode ? FontWeight.w700 : FontWeight.w500,
                          color: trip.isCustomMode ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Conditional Section: Automatic vs Custom
          if (!trip.isCustomMode) ...[
            Text('⏱️ Durasi Perjalanan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [4, 6, 8].map((h) {
                final isSelected = trip.selectedHours == h;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: h < 8 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => context.read<TripProvider>().selectHours(h),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$h Jam',
                              style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${h == 4 ? "2" : h == 6 ? "3" : "4"} destinasi',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isSelected ? Colors.white70 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🗺️ Destinasi Pilihanmu', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (trip.customSelectedDestinations.isNotEmpty)
                  Text(
                    '${trip.customSelectedDestinations.length} terpilih',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (trip.customSelectedDestinations.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada destinasi terpilih.\nPilih destinasi yang ingin kamu kunjungi.',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trip.customSelectedDestinations.length,
                itemBuilder: (context, index) {
                  final dest = trip.customSelectedDestinations[index];
                  return Card(
                    key: ValueKey(dest.id),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.surfaceVariant,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          dest.image,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset('assets/images/placeholder.jpg', width: 40, height: 40, fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(
                        '${index + 1}. ${dest.name}',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        dest.category,
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                            onPressed: () => trip.toggleDestinationSelection(dest),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.drag_handle, color: AppColors.textMuted, size: 20),
                        ],
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  trip.reorderCustomDestinations(oldIndex, newIndex);
                },
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDestinationPicker(context, trip),
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: Text(
                  trip.customSelectedDestinations.isEmpty ? 'Pilih Destinasi' : 'Tambah / Edit Destinasi',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Generate Itinerary Button
          SizedBox(
            width: double.infinity,
            child: Bounceable(
              onTap: () {
                if (trip.isCustomMode && trip.customSelectedDestinations.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pilih minimal 1 destinasi terlebih dahulu!',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                trip.generateItinerary();
              },
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Generate Itinerary'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
// LOADING VIEW
// ═══════════════════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          const SizedBox(height: 20),
          Text('Menganalisis Rute...', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Routee sedang menyusun itinerary terbaik dari titik awalmu', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...[
            '✅ Memindai wisata terdekat',
            '⏳ Menghitung estimasi waktu & biaya',
            '⏳ Menyusun jadwal perjalanan',
          ].map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(s, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ITINERARY VIEW
// ═══════════════════════════════════════════════════════
class _ItineraryView extends StatelessWidget {
  final ItineraryModel itinerary;
  const _ItineraryView({required this.itinerary});

  String _formatRp(int amount) {
    if (amount == 0) return 'Gratis';
    final f = NumberFormat('#,###', 'id_ID');
    return 'Rp ${f.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final trip = context.watch<TripProvider>();
    final isNavigating = trip.isNavigating;
    final totalSpots = itinerary.spots.length;
    final visitedCount = trip.visitedSpots.length;
    final progress = totalSpots > 0 ? visitedCount / totalSpots : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📅 Itinerary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text(itinerary.terminalName, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
                child: Text('${itinerary.hours} Jam', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),

          if (isNavigating) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language.localeCode == 'en' ? '🚀 Trip Progress' : '🚀 Progres Perjalanan',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% ${language.localeCode == 'en' ? 'Completed' : 'Selesai'} ($visitedCount/$totalSpots)',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white,
                      color: AppColors.primary,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Cost Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFEF9E7), Color(0xFFFEF3C7)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('💰 ' + (language.localeCode == 'en' ? 'Estimated Total' : 'Estimasi Total'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(_formatRp(itinerary.totalCost), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
                  ],
                ),
                const SizedBox(height: 8),
                _CostRow('🎟 ' + language.translate('ticket'), _formatRp(itinerary.totalTicket)),
                _CostRow('🍜 ' + (language.localeCode == 'en' ? 'Food & Drinks' : 'Makan & Minum'), _formatRp(itinerary.totalFood)),
                _CostRow('🛵 ' + (language.localeCode == 'en' ? 'Transportation' : 'Transportasi'), '~ ${_formatRp(itinerary.totalTransport)}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transport options
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.localeCode == 'en' ? '🚌 Transport Options from ${itinerary.terminalName}' : '🚌 Opsi Transportasi dari ${itinerary.terminalName}',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                const SizedBox(height: 6),
                ...itinerary.transport.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(t, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryDark)),
                  ]),
                )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Timeline
          Text('🗓 ' + (language.localeCode == 'en' ? 'Travel Schedule' : 'Jadwal Perjalanan'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // Spots + Lunch
          ...(() {
            final List<Widget> items = [];
            for (int i = 0; i < itinerary.spots.length; i++) {
              final spot = itinerary.spots[i];
              items.add(_TimelineItem(
                spot: spot,
                index: i,
                isLast: false,
              ));

              // Insert transit step if there's a next spot
              if (i < itinerary.spots.length - 1) {
                items.add(_TransitStep(
                  distance: itinerary.spots[i + 1].distance,
                  nextSpotName: itinerary.spots[i + 1].name,
                ));
              }

              // Insert lunch break after spot 2
              if (i == 1) {
                items.add(_LunchBreak(food: itinerary.food, formatRp: _formatRp));
              }
            }

            items.add(_TripEnd(spotCount: itinerary.spots.length));
            return items;
          })(),

          const SizedBox(height: 16),

          // ── START NAVIGATION BUTTON ──────────────────────
          Bounceable(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.directions_car_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Butuh Transportasi?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  content: Text(
                    'Apakah Anda akan menggunakan Sewa Kendaraan atau Ojek RO-JEK?',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<TripProvider>().startNavigation();
                        context.go('/map?mode=navigate');
                      },
                      child: Text('Tidak, Lewati', style: GoogleFonts.poppins(color: AppColors.textMuted)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/rental');
                      },
                      child: Text('Ya, Sewa/Ojek', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    language.translate('start_journey_map'),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reset button
          Center(
            child: TextButton.icon(
              onPressed: () => context.read<TripProvider>().resetItinerary(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(language.localeCode == 'en' ? 'Create New Itinerary' : 'Buat Itinerary Baru'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  const _CostRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ItinerarySpot spot;
  final int index;
  final bool isLast;
  const _TimelineItem({required this.spot, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripProvider>();
    final isNavigating = trip.isNavigating;
    final isVisited = trip.visitedSpots.contains(index);

    Color catColor;
    switch (spot.category) {
      case 'Heritage': catColor = AppColors.heritageFg; break;
      case 'Religi': catColor = AppColors.religiFg; break;
      default: catColor = AppColors.culinaryFg;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time + line
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(spot.timeLabel, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                Text('WIB', style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          ),
          // Dot + line (Checkbox when navigating)
          Column(
            children: [
              GestureDetector(
                onTap: isNavigating ? () => trip.toggleSpotVisited(index) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isNavigating ? 22 : 16,
                  height: isNavigating ? 22 : 16,
                  decoration: BoxDecoration(
                    color: isNavigating
                        ? (isVisited ? AppColors.success : Colors.white)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: isNavigating && !isVisited
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: isNavigating
                        ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Center(
                    child: isNavigating
                        ? (isVisited
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : Text('${index + 1}', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary)))
                        : Text('${index + 1}', style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
              if (!isLast) Container(width: 2, height: 80, color: AppColors.primarySurface),
            ],
          ),
          const SizedBox(width: 10),
          // Card
          Expanded(
            child: Bounceable(
              onTap: () => context.push('/detail/${spot.id}'),
              child: Opacity(
                opacity: isVisited ? 0.65 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: isVisited ? Border.all(color: AppColors.divider, width: 1) : null,
                    boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80, height: 80,
                        child: Image.asset(spot.image, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('Stop ${index + 1}', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: catColor)),
                                  ),
                                  if (isVisited)
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                        const SizedBox(width: 3),
                                        Text('Selesai', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success)),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(spot.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _SmallTag('⏱ ${spot.duration}'),
                                  const SizedBox(width: 4),
                                  _SmallTag(spot.ticketPrice == 0 ? '🎟 Gratis' : '🎟 Rp ${NumberFormat('#,###', 'id_ID').format(spot.ticketPrice)}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ),
                    ],
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

class _SmallTag extends StatelessWidget {
  final String text;
  const _SmallTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary)),
    );
  }
}

class _LunchBreak extends StatelessWidget {
  final ItineraryFood food;
  final String Function(int) formatRp;
  const _LunchBreak({required this.food, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text('12:00', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                Text('WIB', style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Center(child: Text('🍽', style: TextStyle(fontSize: 8))),
              ),
              Container(width: 2, height: 80, color: AppColors.accentSurface),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🕌 Istirahat & Ibadah', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Silakan mencari Mushola/Masjid terdekat di area ini untuk menunaikan ibadah.', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 48, height: 48,
                            child: Image.asset(food.image, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🍽 Rekomendasi Makan', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                              Text(food.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(formatRp(food.price), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.culinaryFg, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripEnd extends StatelessWidget {
  final int spotCount;
  const _TripEnd({required this.spotCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 60),
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: const Center(child: Text('🏁', style: TextStyle(fontSize: 8))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.religiBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🏁', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Perjalanan Selesai!', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.religiFg)),
                      Text('Total $spotCount destinasi dikunjungi', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.religiFg.withOpacity(0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('Siap Merencanakan?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Pilih titik keberangkatan dan durasi di atas,\nlalu tekan tombol Generate Itinerary!', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['5 Terminal/Stasiun', '3 Pilihan Durasi', 'Estimasi Biaya', 'Kuliner Rekomendasi'].map((f) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16)),
                child: Text('✅ $f', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ).toList(),
          ),
        ],
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

// ═══════════════════════════════════════════════════════
// DESTINATION PICKER SHEET (BOTTOM SHEET)
// ═══════════════════════════════════════════════════════
class _DestinationPickerSheet extends StatefulWidget {
  final TripProvider trip;
  const _DestinationPickerSheet({required this.trip});

  @override
  State<_DestinationPickerSheet> createState() => _DestinationPickerSheetState();
}

class _DestinationPickerSheetState extends State<_DestinationPickerSheet> {
  String _searchQuery = '';
  String _activeTab = 'Semua'; // 'Semua', 'Heritage', 'Religi'
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final allDestinations = DestinationsData.destinations;

    final filteredDestinations = allDestinations.where((dest) {
      final matchesSearch = dest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dest.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTab = _activeTab == 'Semua' || dest.category == _activeTab;
      return matchesSearch && matchesTab;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Indicator handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Destinasi Wisata',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.trip.customSelectedDestinations.length} Terpilih',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari destinasi atau lokasi...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchCtrl.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ['Semua', 'Heritage', 'Religi'].map((tab) {
                    final isActive = _activeTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTab = tab;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? AppColors.primary : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            tab,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),

              // Destinations list
              Expanded(
                child: filteredDestinations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'Destinasi tidak ditemukan',
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDestinations.length,
                        itemBuilder: (context, idx) {
                          final dest = filteredDestinations[idx];
                          final isSelected = widget.trip.customSelectedDestinations.any((d) => d.id == dest.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.divider,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cardShadow.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  dest.image,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset('assets/images/placeholder.jpg', width: 56, height: 56, fit: BoxFit.cover),
                                ),
                              ),
                              title: Text(
                                dest.name,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dest.category} • 🕒 ${dest.hours}',
                                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    dest.ticket.toLowerCase().contains('gratis') ? 'Gratis' : '🎟️ ${dest.ticket}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: dest.ticket.toLowerCase().contains('gratis') ? Colors.green : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  widget.trip.toggleDestinationSelection(dest);
                                  setState(() {});
                                },
                              ),
                              onTap: () {
                                widget.trip.toggleDestinationSelection(dest);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Actions Panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.trip.clearCustomDestinations();
                            setState(() {});
                          },
                          child: Text(
                            'Hapus Semua',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.redAccent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Selesai (${widget.trip.customSelectedDestinations.length})',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransitStep extends StatelessWidget {
  final String distance;
  final String nextSpotName;

  const _TransitStep({
    required this.distance,
    required this.nextSpotName,
  });

  @override
  Widget build(BuildContext context) {
    double distKm = 2.0;
    final match = RegExp(r'^([\d\.]+)').firstMatch(distance);
    if (match != null) {
      distKm = double.tryParse(match.group(1) ?? '') ?? 2.0;
    }

    final int motorMin = (distKm * 3).round().clamp(2, 60);
    final int carMin = (distKm * 5).round().clamp(3, 90);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time offset
          const SizedBox(width: 60),
          // Vertical line segment matching timeline dots
          Column(
            children: [
              Container(width: 2, height: 75, color: AppColors.primarySurface),
            ],
          ),
          const SizedBox(width: 18),
          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4, right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.navigation_outlined, size: 12, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ke $nextSpotName ($distance)',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.motorcycle, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '~$motorMin mnt',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_car, size: 12, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '~$carMin mnt',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

