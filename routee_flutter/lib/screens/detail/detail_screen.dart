import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  late FlutterTts _flutterTts;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _setupVoiceForLanguage(String lang) async {
    try {
      await _flutterTts.setLanguage(lang);
      List<dynamic>? voices = await _flutterTts.getVoices;
      if (voices != null) {
        final langPrefix = lang.split('-').first.toLowerCase();
        final matchingVoices = voices.where((v) {
          final locale = v['locale']?.toString().toLowerCase().replaceAll('_', '-') ?? '';
          return locale.startsWith(langPrefix);
        }).toList();

        if (matchingVoices.isNotEmpty) {
          dynamic selectedVoice = matchingVoices.firstWhere(
            (v) {
              final name = v['name']?.toString().toLowerCase() ?? '';
              return name.contains('network') || name.contains('neural') || name.contains('wavenet');
            },
            orElse: () => matchingVoices.firstWhere(
              (v) {
                final name = v['name']?.toString().toLowerCase() ?? '';
                return name.contains('premium') || name.contains('high');
              },
              orElse: () => matchingVoices.first,
            ),
          );

          await _flutterTts.setVoice({
            "name": selectedVoice['name'],
            "locale": selectedVoice['locale'],
          });
          debugPrint('TTS: Selected voice: ${selectedVoice['name']} for $lang');
        }
      }
    } catch (e) {
      debugPrint('TTS Error setting voice: $e');
    }
  }

  Future<void> _initTts() async {
    await _setupVoiceForLanguage("id-ID");
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      if (mounted) {
        setState(() => _isPlayingAudio = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TTS Error: $msg'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAudioGuideCard(DestinationModel destination, String localeCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A3219), Color(0xFF6D4C2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.audiotrack_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeCode == 'en' ? 'Audio Guide Heritage' : 'Audio Panduan Heritage',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isPlayingAudio
                      ? (localeCode == 'en' ? 'Playing narration...' : 'Memutar narasi...')
                      : (localeCode == 'en' ? 'Listen to destination history' : 'Dengarkan sejarah destinasi'),
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Bounceable(
            onTap: () async {
              if (_isPlayingAudio) {
                await _flutterTts.stop();
                setState(() => _isPlayingAudio = false);
              } else {
                final lang = localeCode == 'en' ? "en-US" : "id-ID";
                bool isAvailable = false;
                try {
                  isAvailable = await _flutterTts.isLanguageAvailable(lang);
                } catch (e) {
                  debugPrint('TTS availability check error: $e');
                }

                if (!isAvailable && lang == "id-ID") {
                  try {
                    isAvailable = await _flutterTts.isLanguageAvailable("id");
                  } catch (_) {}
                }

                if (!isAvailable) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localeCode == 'en'
                              ? 'Text-to-Speech language ($lang) is not available or not active on this device. Please check your system settings.'
                              : 'Bahasa Text-to-Speech ($lang) tidak didukung atau belum aktif di perangkat Anda. Silakan pasang/aktifkan di pengaturan sistem.',
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }

                await _setupVoiceForLanguage(lang);
                await _flutterTts.setPitch(1.0);
                await _flutterTts.setSpeechRate(1.0);
                setState(() => _isPlayingAudio = true);
                final textToSpeak = destination.audioNarrative ?? destination.description;
                final result = await _flutterTts.speak(textToSpeak);
                if (result == 0) {
                  // TTS speak failed to start
                  setState(() => _isPlayingAudio = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localeCode == 'en'
                              ? 'Failed to start TTS playback. Please make sure media volume is up and a TTS engine is installed.'
                              : 'Gagal memulai pemutaran suara. Pastikan volume media menyala dan engine TTS terpasang.',
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlayingAudio ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
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
          // HERO IMAGE
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

          // CONTENT
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

                  // Audio Guide Heritage Integration
                  _buildAudioGuideCard(destination, language.localeCode),

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
