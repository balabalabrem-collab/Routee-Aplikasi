import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/transport_data.dart';
import '../../core/models/transport_model.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilihan Transportasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6D4C2A), Color(0xFF4A3219)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🚗', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih Transportasi', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Pilihan kendaraan sesuai kebutuhan perjalanan heritage Surabaya', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...TransportData.options.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _TransportCard(transport: t),
          )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TransportCard extends StatefulWidget {
  final TransportModel transport;
  const _TransportCard({required this.transport});

  @override
  State<_TransportCard> createState() => _TransportCardState();
}

class _TransportCardState extends State<_TransportCard> {
  bool _expanded = false;

  Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(widget.transport.colorHex);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Main content
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(widget.transport.icon, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(widget.transport.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(widget.transport.badge, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.transport.price,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(widget.transport.desc, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),
          ),

          // Expandable pros/cons
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✅ Keunggulan', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                            const SizedBox(height: 6),
                            ...widget.transport.pros.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                                  const SizedBox(width: 5),
                                  Expanded(child: Text(p, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('⚠️ Keterbatasan', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning)),
                            const SizedBox(height: 6),
                            ...widget.transport.cons.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_rounded, size: 13, color: AppColors.warning),
                                  const SizedBox(width: 5),
                                  Expanded(child: Text(c, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
