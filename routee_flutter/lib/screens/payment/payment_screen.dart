import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/rental_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/common/bounceable.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _currentStep = 0; // 0: summary, 1: method, 2: confirm, 3: webview/pending, 4: success
  final _formatter = NumberFormat('#,###', 'id_ID');

  String _formatRp(int amount) => 'Rp ${_formatter.format(amount)}';

  @override
  Widget build(BuildContext context) {
    final rental = context.watch<RentalProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentStep < 3
          ? AppBar(
              title: Text(
                _currentStep == 0
                    ? 'Ringkasan Pesanan'
                    : _currentStep == 1
                        ? 'Metode Pembayaran'
                        : 'Konfirmasi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (_currentStep > 0 && _currentStep < 3) {
                    setState(() => _currentStep--);
                  } else {
                    context.pop();
                  }
                },
              ),
            )
          : null,
      body: Column(
        children: [
          // Progress Stepper
          if (_currentStep < 3)
            _buildStepper(),

          // Content
          Expanded(
            child: _buildStep(rental),
          ),

          // Bottom button
          if (_currentStep < 3)
            _buildBottomBar(rental),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 14,
            left: 32,
            right: 32,
            child: Container(height: 2, color: AppColors.divider),
          ),
          Positioned(
            top: 14,
            left: 32,
            right: 32,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double widthFactor = (_currentStep / 3.0).clamp(0.0, 1.0);
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widthFactor,
                  child: Container(height: 2, color: AppColors.primary),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              final labels = ['Ringkasan', 'Bayar', 'Konfirmasi', 'Selesai'];
              final isActive = i <= _currentStep;
              return SizedBox(
                width: 76,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: i < _currentStep
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isActive ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(RentalProvider rental) {
    switch (_currentStep) {
      case 0:
        return _SummaryStep(rental: rental, formatter: _formatRp);
      case 1:
        return _PaymentMethodStep(rental: rental);
      case 2:
        return _ConfirmStep(rental: rental, formatter: _formatRp);
      case 3:
        // COD: tampilkan halaman khusus COD
        if (rental.isCodPayment) {
          return _CodStep(
            rental: rental,
            formatter: _formatRp,
            onConfirm: () => setState(() => _currentStep = 4),
          );
        }
        // Midtrans: tampilkan WebView atau pending check
        return _MidtransWebViewStep(
          rental: rental,
          formatter: _formatRp,
          onPaymentSuccess: () => setState(() => _currentStep = 4),
        );
      default:
        return _SuccessStep(rental: rental, formatter: _formatRp);
    }
  }

  Widget _buildBottomBar(RentalProvider rental) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_currentStep == 2) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Bayar',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  Text(_formatRp(rental.totalAmount),
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canProceed(rental) ? () => _nextStep(rental) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: AppColors.divider,
                ),
                child: Text(
                  _currentStep == 2 ? 'Bayar Sekarang' : 'Lanjutkan',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed(RentalProvider rental) {
    if (_currentStep == 1 && rental.paymentMethod.isEmpty) return false;
    return true;
  }

  void _nextStep(RentalProvider rental) async {
    if (_currentStep == 2) {
      // COD: langsung proses tanpa Midtrans
      if (rental.isCodPayment) {
        rental.processCodPayment();
        setState(() => _currentStep = 3);
        return;
      }

      // Midtrans: initiate payment
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text('Menghubungi server pembayaran...',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );

      final result = await rental.initiatePayment();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        if (result['success'] == true) {
          setState(() => _currentStep = 3);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memulai pembayaran'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => _nextStep(rental),
              ),
            ),
          );
        }
      }
    } else {
      setState(() => _currentStep++);
    }
  }
}

// ═══════════════════════════════════════════
// STEP 1: SUMMARY
// ═══════════════════════════════════════════
class _SummaryStep extends StatelessWidget {
  final RentalProvider rental;
  final String Function(int) formatter;
  const _SummaryStep({required this.rental, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final driver = rental.selectedDriver;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver?.name ?? '-',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                      Row(children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                        Text(' ${driver?.rating ?? 0}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                        Text('  •  ${driver?.totalTrips ?? 0} trips',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Kendaraan', value: driver?.vehicleName ?? '-'),
                const Divider(color: AppColors.divider, height: 20),
                _InfoRow(label: 'Jenis', value: rental.selectedVehicleType),
                const Divider(color: AppColors.divider, height: 20),
                _InfoRow(label: 'Plat Nomor', value: driver?.plateNumber ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Duration selector
          if (!rental.isOjek) ...[
            Text('Durasi Sewa',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [4, 8, 12].map((h) {
                final isSelected = rental.durationHours == h;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: h != 12 ? 8 : 0),
                    child: Bounceable(
                      onTap: () => rental.setDuration(h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text('$h jam',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.textPrimary)),
                            Text(
                                h == 4
                                    ? 'Setengah hari'
                                    : h == 8
                                        ? 'Seharian'
                                        : 'Full day+',
                                style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: isSelected ? Colors.white70 : AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ] else ...[
            Text('Estimasi Waktu Penjemputan',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Jemput pukul ${rental.pickupTime}',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Trip route info
          ...(() {
            final trip = context.watch<TripProvider>();
            final itinerary = trip.currentItinerary;
            final isCustomMode = trip.isCustomMode;
            final spots = rental.isOjek
                ? rental.ojekRoute
                : (isCustomMode
                    ? trip.customSelectedDestinations.map((d) => d.name).toList()
                    : itinerary?.spots.map((s) => s.name).toList() ?? []);

            if (spots.isEmpty) return <Widget>[];

            return <Widget>[
              const SizedBox(height: 20),
              Text(
                  rental.isOjek ? 'Rute Kunjungan Ojek' : 'Rute Kunjungan Destinasi',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rental.isOjek
                          ? 'Konfirmasi rute pengantaran ojek ke destinasi berikut menggunakan ${rental.selectedVehicleType}:'
                          : 'Konfirmasi perjalanan ke destinasi berikut menggunakan ${rental.selectedVehicleType} ${rental.selectedDriver?.vehicleName ?? ""}:',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    ...spots.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final name = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary, shape: BoxShape.circle),
                              child: Center(
                                child: Text('${idx + 1}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ];
          })(),

          const SizedBox(height: 20),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                if (rental.isOjek) ...[
                  _InfoRow(label: 'Penyewaan Kendaraan (Motor)', value: formatter(15000)),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Jasa Driver & BBM', value: formatter(rental.rentalPrice - 15000)),
                ] else ...[
                  _InfoRow(
                      label: 'Harga sewa (${rental.durationHours} jam)',
                      value: formatter(rental.rentalPrice)),
                ],
                const SizedBox(height: 8),
                _InfoRow(label: 'Biaya layanan (10%)', value: formatter(rental.serviceFee)),
                const Divider(color: AppColors.accent, height: 20),
                _InfoRow(label: 'Total', value: formatter(rental.totalAmount), isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP 2: PAYMENT METHOD
// ═══════════════════════════════════════════
class _PaymentMethodStep extends StatelessWidget {
  final RentalProvider rental;
  const _PaymentMethodStep({required this.rental});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {
        'group': 'E-Wallet',
        'options': [
          {'id': 'gopay', 'name': 'GoPay', 'icon': Icons.account_balance_wallet},
          {'id': 'ovo', 'name': 'OVO', 'icon': Icons.account_balance_wallet_outlined},
          {'id': 'dana', 'name': 'DANA', 'icon': Icons.wallet},
          {'id': 'shopeepay', 'name': 'ShopeePay', 'icon': Icons.shopping_bag_outlined},
        ]
      },
      {
        'group': 'Transfer Bank (Virtual Account)',
        'options': [
          {'id': 'bca', 'name': 'BCA Virtual Account', 'icon': Icons.account_balance},
          {'id': 'bri', 'name': 'BRI Virtual Account', 'icon': Icons.account_balance},
          {'id': 'bni', 'name': 'BNI Virtual Account', 'icon': Icons.account_balance},
          {'id': 'mandiri', 'name': 'Mandiri Virtual Account', 'icon': Icons.account_balance},
        ]
      },
      {
        'group': 'Gerai / Minimarket',
        'options': [
          {'id': 'alfamart', 'name': 'Alfamart', 'icon': Icons.store},
          {'id': 'indomaret', 'name': 'Indomaret', 'icon': Icons.store_mall_directory},
        ]
      },
      {
        'group': 'Bayar di Tempat',
        'options': [
          {'id': 'cod', 'name': 'Cash on Delivery (COD)', 'icon': Icons.payments_rounded},
        ]
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Metode Pembayaran',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pembayaran diproses secara aman melalui Midtrans.',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ...methods.map((group) {
            final options = group['options'] as List<Map<String, dynamic>>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group['group'] as String,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                ...options.map((opt) {
                  final isSelected = rental.paymentMethod == opt['id'];
                  final isCod = opt['id'] == 'cod';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Bounceable(
                      onTap: () => rental.setPaymentMethod(opt['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primarySurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(opt['icon'] as IconData,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                                size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opt['name'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: AppColors.textPrimary)),
                                  if (isCod)
                                    Text('Konfirmasi lewat WhatsApp Admin',
                                        style: GoogleFonts.poppins(
                                            fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP 3: CONFIRM
// ═══════════════════════════════════════════
class _ConfirmStep extends StatelessWidget {
  final RentalProvider rental;
  final String Function(int) formatter;
  const _ConfirmStep({required this.rental, required this.formatter});

  String _methodName(String id) {
    const names = {
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'dana': 'DANA',
      'shopeepay': 'ShopeePay',
      'bca': 'BCA VA',
      'bri': 'BRI VA',
      'bni': 'BNI VA',
      'mandiri': 'Mandiri VA',
      'alfamart': 'Alfamart',
      'indomaret': 'Indomaret',
      'cod': 'Cash on Delivery (COD)',
    };
    return names[id] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Pesanan',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Driver', value: rental.selectedDriver?.name ?? '-'),
                const Divider(color: AppColors.divider, height: 20),
                _InfoRow(label: 'Kendaraan', value: rental.selectedDriver?.vehicleName ?? '-'),
                const Divider(color: AppColors.divider, height: 20),
                _InfoRow(label: 'Plat', value: rental.selectedDriver?.plateNumber ?? '-'),
                const Divider(color: AppColors.divider, height: 20),
                if (!rental.isOjek) ...[
                  _InfoRow(label: 'Durasi', value: '${rental.durationHours} jam'),
                  const Divider(color: AppColors.divider, height: 20),
                ] else ...[
                  _InfoRow(label: 'Penjemputan', value: rental.pickupTime),
                  const Divider(color: AppColors.divider, height: 20),
                ],
                _InfoRow(label: 'Metode Bayar', value: _methodName(rental.paymentMethod)),
                const Divider(color: AppColors.divider, height: 20),
                if (rental.isOjek) ...[
                  _InfoRow(label: 'Penyewaan Kendaraan', value: formatter(15000)),
                  const Divider(color: AppColors.divider, height: 20),
                  _InfoRow(
                      label: 'Jasa Driver & BBM',
                      value: formatter(rental.rentalPrice - 15000)),
                ] else ...[
                  _InfoRow(label: 'Harga Sewa', value: formatter(rental.rentalPrice)),
                ],
                const SizedBox(height: 4),
                _InfoRow(label: 'Biaya Layanan', value: formatter(rental.serviceFee)),
                const Divider(color: AppColors.primary, height: 20),
                _InfoRow(label: 'TOTAL', value: formatter(rental.totalAmount), isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (rental.isCodPayment)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dengan memilih COD, Anda akan menghubungi admin via WhatsApp untuk konfirmasi pesanan. Pembayaran dilakukan saat driver tiba.',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP 4A: COD — Konfirmasi via WhatsApp
// ═══════════════════════════════════════════
class _CodStep extends StatelessWidget {
  final RentalProvider rental;
  final String Function(int) formatter;
  final VoidCallback onConfirm;

  const _CodStep({
    required this.rental,
    required this.formatter,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final payment = rental.currentPayment;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk_rounded, size: 48, color: Color(0xFF25D366)),
            ),
            const SizedBox(height: 20),
            Text('Konfirmasi Pesanan COD',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Pesanan Anda telah dicatat. Hubungi admin via WhatsApp untuk konfirmasi dan jadwalkan penjemputan.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Order ref card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text('Nomor Pesanan',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(payment?.referenceNumber ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1)),
                  const Divider(height: 20),
                  _InfoRow(
                      label: 'Total Bayar',
                      value: formatter(payment?.totalAmount ?? rental.totalAmount),
                      isBold: true),
                  const SizedBox(height: 4),
                  _InfoRow(
                      label: 'Metode',
                      value: 'Cash on Delivery',
                      isBold: false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // WhatsApp button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  final ref = payment?.referenceNumber ?? '-';
                  final total = formatter(payment?.totalAmount ?? rental.totalAmount);
                  final driver = rental.selectedDriver?.name ?? '-';
                  final msg = Uri.encodeComponent(
                      'Halo Admin Routee! 👋\n\nSaya ingin konfirmasi pesanan COD:\n'
                      '📋 No. Pesanan: $ref\n'
                      '🚗 Driver: $driver\n'
                      '💰 Total: $total\n'
                      '📅 Tanggal: ${rental.rentalDate.isNotEmpty ? rental.rentalDate : "Secepatnya"}\n\n'
                      'Mohon konfirmasi dan info jadwal penjemputan. Terima kasih!');
                  launchUrl(
                    Uri.parse('https://wa.me/${AppStrings.adminWhatsApp.replaceAll('+', '')}?text=$msg'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.chat_rounded),
                label: Text('Hubungi Admin via WhatsApp',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Selesai button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text('Sudah Hubungi Admin, Lanjutkan',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP 4B: MIDTRANS — WebView in-app + Status Check
// ═══════════════════════════════════════════
class _MidtransWebViewStep extends StatefulWidget {
  final RentalProvider rental;
  final String Function(int) formatter;
  final VoidCallback onPaymentSuccess;

  const _MidtransWebViewStep({
    required this.rental,
    required this.formatter,
    required this.onPaymentSuccess,
  });

  @override
  State<_MidtransWebViewStep> createState() => _MidtransWebViewStepState();
}

class _MidtransWebViewStepState extends State<_MidtransWebViewStep> {
  bool _isChecking = false;

  Future<void> _openPaymentInBrowser() async {
    final payment = widget.rental.currentPayment;
    if (payment == null) return;

    if (payment.referenceNumber.startsWith('MOCK-')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mode Demo: Membuka simulator pembayaran. (Jika HP offline, silakan kembali dan langsung klik Cek Status Pembayaran)'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      final uri = Uri.parse('https://simulator.sandbox.midtrans.com');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      // Use the Midtrans Snap redirect URL — the order_id is referenceNumber
      final snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/${payment.referenceNumber}';
      final uri = Uri.parse(snapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Memverifikasi pembayaran...',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );

    final success = await widget.rental.checkPaymentStatus();

    if (mounted) {
      Navigator.pop(context);
      setState(() => _isChecking = false);

      if (success) {
        widget.onPaymentSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran belum terdeteksi. Selesaikan transaksi terlebih dahulu.'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _checkStatus,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.rental.currentPayment;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pending_actions_rounded, size: 48, color: AppColors.warning),
            ),
            const SizedBox(height: 20),
            Text('Menunggu Pembayaran',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Selesaikan pembayaran melalui portal Midtrans yang telah dibuka.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Order ID Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text('ID Transaksi',
                      style:
                          GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(payment?.referenceNumber ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5)),
                  const Divider(height: 24),
                  _InfoRow(
                      label: 'Total Pembayaran',
                      value: widget.formatter(payment?.totalAmount ?? 0),
                      isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Open in browser
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openPaymentInBrowser,
                icon: const Icon(Icons.open_in_browser_rounded),
                label: Text('Buka Halaman Pembayaran',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Check status
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isChecking ? null : _checkStatus,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Cek Status Pembayaran',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info tips
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text('Cara Bayar',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...[
                    '1. Tekan "Buka Halaman Pembayaran" di atas',
                    '2. Pilih metode bayar dan selesaikan transaksi',
                    '3. Kembali ke aplikasi ini',
                    '4. Tekan "Cek Status Pembayaran"',
                  ].map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(t,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textSecondary)),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP 5: SUCCESS
// ═══════════════════════════════════════════
class _SuccessStep extends StatelessWidget {
  final RentalProvider rental;
  final String Function(int) formatter;
  const _SuccessStep({required this.rental, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final payment = rental.currentPayment;
    final isCod = payment?.method == 'cod';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
            ),
            const SizedBox(height: 20),
            Text(
              isCod ? 'Pesanan Dikonfirmasi! 🎉' : 'Pembayaran Berhasil! 🎉',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isCod
                  ? 'Admin akan menghubungi Anda untuk konfirmasi jadwal'
                  : 'Driver sedang menuju lokasi penjemputan',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Reference number
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(isCod ? 'Nomor Pesanan' : 'Nomor Referensi',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(payment?.referenceNumber ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Driver', value: rental.selectedDriver?.name ?? '-'),
                  const Divider(color: AppColors.divider, height: 20),
                  _InfoRow(
                      label: 'Kendaraan',
                      value:
                          '${rental.selectedDriver?.vehicleName ?? ''} (${rental.selectedDriver?.plateNumber ?? ''})'),
                  const Divider(color: AppColors.divider, height: 20),
                  if (rental.isOjek) ...[
                    _InfoRow(label: 'Penjemputan', value: rental.pickupTime),
                    const Divider(color: AppColors.divider, height: 20),
                  ],
                  _InfoRow(
                      label: isCod ? 'Total (Bayar di Tempat)' : 'Total Bayar',
                      value: formatter(payment?.totalAmount ?? 0),
                      isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  final driverId = rental.selectedDriver?.id ?? '';
                  context.push('/chat/$driverId');
                },
                icon: const Icon(Icons.chat_rounded),
                label: Text('Chat Driver',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (!isCod)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final paymentId = payment?.id ?? '';
                    context.push('/driver-tracking/$paymentId');
                  },
                  icon: const Icon(Icons.map_rounded),
                  label: Text('Lacak Driver',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            if (!isCod) const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text('Kembali ke Beranda',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _InfoRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                  fontSize: isBold ? 14 : 12,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: isBold ? AppColors.primary : AppColors.textPrimary)),
        ),
      ],
    );
  }
}
