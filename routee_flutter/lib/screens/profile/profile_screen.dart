import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rental_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/bookmark_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/common/bounceable.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Notification toggle states
  bool _tripAlerts = true;
  bool _promoAlerts = false;
  bool _chatNotifications = true;

  // Selected Language
  String _currentLang = 'Bahasa Indonesia';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rental = context.watch<RentalProvider>();
    final language = context.watch<LanguageProvider>();
    final bookmark = context.watch<BookmarkProvider>();
    final isLoggedIn = auth.isLoggedIn;
    final user = auth.currentUser;
    
    _currentLang = language.currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          language.translate('profile'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Keluar',
              onPressed: () => _showLogoutDialog(context, auth),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Center(
                      child: isLoggedIn && user != null
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: AppColors.textMuted,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name & Status Label
                  if (isLoggedIn && user != null) ...[
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent, width: 1),
                      ),
                      child: Text(
                        '⭐ ' + language.translate('member_silver'),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      language.translate('guest_mode'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.translateText(
                        id: 'Masuk untuk akses fitur pemesanan & rental',
                        en: 'Log in to access booking & rental features',
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Bounceable(
                      onTap: () => context.go('/login'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          language.translate('login_cta'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Statistics Row (only for logged in users)
            if (isLoggedIn) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    _buildStatCard(
                      context,
                      language.translate('total_trips'),
                      bookmark.visitedCount.toString(),
                      Icons.route_rounded,
                      AppColors.primary,
                      () => _showVisitedDestinationsBottomSheet(context, bookmark, language),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      language.translate('saved_destinations'),
                      bookmark.savedCount.toString(),
                      Icons.bookmark_rounded,
                      AppColors.accent,
                      () => _showSavedDestinationsBottomSheet(context, bookmark, language),
                    ),
                  ],
                ),
              ),
            ],

            // Menu Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoggedIn && user?.role == 'admin') ...[
                    Text(
                      language.translateText(id: 'Panel Administrator', en: 'Administrator Panel'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.dashboard_rounded,
                      title: language.translateText(id: 'Dashboard Keuangan', en: 'Financial Dashboard'),
                      subtitle: language.translateText(id: 'Laporan pendapatan, rental, dan statistik transaksi', en: 'Income report, rentals, and transaction stats'),
                      onTap: () => _showAdminFinanceBottomSheet(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.people_rounded,
                      title: language.translateText(id: 'Manajemen Karyawan & Driver', en: 'Employee & Driver Management'),
                      subtitle: language.translateText(id: 'Daftar staff operational dan driver aktif', en: 'Active operational staff and driver list'),
                      onTap: () => _showAdminEmployeesBottomSheet(context),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (isLoggedIn && user?.role == 'karyawan') ...[
                    Text(
                      language.translateText(id: 'Panel Karyawan', en: 'Employee Panel'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.assignment_rounded,
                      title: language.translateText(id: 'Tugas Operasional', en: 'Operational Tasks'),
                      subtitle: language.translateText(id: 'Monitoring penjemputan ojek dan status unit', en: 'Ojek pickup monitoring and unit status'),
                      onTap: () => _showKaryawanOpsBottomSheet(context),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    language.translate('account_security'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: language.translate('change_profile'),
                    subtitle: language.translate('change_profile_sub'),
                    onTap: isLoggedIn
                        ? () => _showEditProfileBottomSheet(context, auth)
                        : null,
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_reset_rounded,
                    title: language.translate('change_pass'),
                    subtitle: language.translate('change_pass_sub'),
                    onTap: isLoggedIn
                        ? () => _showEditPasswordBottomSheet(context, auth)
                        : null,
                  ),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: language.translate('tx_history'),
                    subtitle: language.translate('tx_history_sub'),
                    onTap: isLoggedIn
                        ? () => _showTransactionHistoryBottomSheet(context, rental)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    language.translate('app_help'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: language.translate('notifications'),
                    subtitle: language.translate('notifications_sub'),
                    onTap: () => _showNotificationsBottomSheet(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.language_rounded,
                    title: language.translate('language'),
                    subtitle: _currentLang,
                    trailing: Text(
                      _currentLang == 'English' ? 'EN' : 'ID',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    onTap: () => _showLanguageBottomSheet(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: language.translate('about'),
                    subtitle: language.translate('about_sub'),
                    onTap: () => _showAboutBottomSheet(context),
                  ),
                  if (isLoggedIn) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, auth),
                        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                        label: Text(
                          language.translate('logout'),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Bounceable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surface : AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withOpacity(0.7)),
        ),
        child: ListTile(
          onTap: onTap,
          enabled: isEnabled,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.primarySurface : AppColors.divider.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: isEnabled ? AppColors.textMuted : AppColors.divider,
                size: 18,
              ),
        ),
      ),
    );
  }

  // --- ACTIONS & SHEETS ---

  void _showEditProfileBottomSheet(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.currentUser?.name ?? '');
    final emailCtrl = TextEditingController(text: auth.currentUser?.email ?? '');
    final phoneCtrl = TextEditingController(text: auth.currentUser?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ubah Data Diri',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                validator: (v) => v == null || v.length < 9 ? 'Nomor telepon tidak valid' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      auth.updateProfile(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      _showMockToast(context, 'Profil berhasil diperbarui!');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: Text('Simpan Perubahan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPasswordBottomSheet(BuildContext context, AuthProvider auth) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ubah Kata Sandi',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Lama'),
                validator: (v) => v == null || v.isEmpty ? 'Sandi lama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Baru'),
                validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi Sandi Baru'),
                validator: (v) {
                  if (v != newPassCtrl.text) return 'Konfirmasi sandi tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final success = auth.updatePassword(oldPassCtrl.text, newPassCtrl.text);
                      if (success) {
                        Navigator.pop(ctx);
                        _showMockToast(context, 'Password berhasil diubah!');
                      } else {
                        _showMockToast(context, 'Password lama Anda salah!');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: Text('Perbarui Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionHistoryBottomSheet(BuildContext context, RentalProvider rental) {
    final activePay = rental.currentPayment;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (c, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Riwayat Transaksi',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Active rental if present
                    if (activePay != null) ...[
                      _buildTransactionCard(
                        title: 'Sewa ${activePay.vehicleType} (Aktif)',
                        ref: activePay.referenceNumber,
                        date: 'Hari ini',
                        amount: 'Rp ${activePay.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        status: activePay.status.toUpperCase(),
                        statusColor: AppColors.primary,
                        icon: activePay.vehicleType == 'Motor' ? Icons.motorcycle_rounded : Icons.directions_car_rounded,
                      ),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                context.read<LanguageProvider>().localeCode == 'en'
                                    ? 'No transaction history'
                                    : 'Belum ada riwayat transaksi',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String ref,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('Ref: $ref • $date', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text(amount, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pengaturan Notifikasi',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                activeColor: AppColors.primary,
                title: Text('Notifikasi Perjalanan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Status pemesanan & chat driver', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                value: _tripAlerts,
                onChanged: (v) {
                  setSheetState(() => _tripAlerts = v);
                  setState(() => _tripAlerts = v);
                },
              ),
              SwitchListTile(
                activeColor: AppColors.primary,
                title: Text('Promo & Diskon', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Informasi penawaran rental menarik', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                value: _promoAlerts,
                onChanged: (v) {
                  setSheetState(() => _promoAlerts = v);
                  setState(() => _promoAlerts = v);
                },
              ),
              SwitchListTile(
                activeColor: AppColors.primary,
                title: Text('Chat dari Admin', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Bantuan langsung terkait perjalanan', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                value: _chatNotifications,
                onChanged: (v) {
                  setSheetState(() => _chatNotifications = v);
                  setState(() => _chatNotifications = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final language = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Bahasa / Select Language',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
              title: Text('Bahasa Indonesia', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: language.currentLanguage == 'Bahasa Indonesia' ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () {
                language.setLanguage('Bahasa Indonesia');
                Navigator.pop(ctx);
                _showMockToast(context, 'Bahasa diubah ke Indonesia');
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text('English', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: language.currentLanguage == 'English' ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () {
                language.setLanguage('English');
                Navigator.pop(ctx);
                _showMockToast(context, 'Language changed to English');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Center(child: Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Routee Mobile App', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Versi 1.1.0 (Release)', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Routee adalah aplikasi Surabaya Heritage Trip Planner terintegrasi yang memudahkan wisatawan lokal maupun mancanegara menjelajahi nilai sejarah & pesona heritage Kota Surabaya dengan mudah, aman, dan nyaman.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              '© 2026 Routee Surabaya. Hak Cipta Dilindungi.',
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar Akun?',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun Routee?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              auth.logout();
              Navigator.pop(ctx);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showMockToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showVisitedDestinationsBottomSheet(BuildContext context, BookmarkProvider bookmark, LanguageProvider language) {
    final visitedIds = bookmark.visitedDestinationIds;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        height: MediaQuery.of(ctx).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              language.localeCode == 'en' ? 'Visited Destinations' : 'Destinasi yang Dikunjungi',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: visitedIds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.route_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            language.localeCode == 'en' ? 'No visited destinations yet' : 'Belum ada destinasi yang dikunjungi',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            language.localeCode == 'en' ? 'Start a trip navigation to check them off!' : 'Mulai navigasi trip untuk mencatat kunjunganmu!',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: visitedIds.length,
                      itemBuilder: (context, index) {
                        final destId = visitedIds[index];
                        final dest = DestinationsData.findById(destId);
                        if (dest == null) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                dest.image,
                                width: 52, height: 52, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: AppColors.surfaceVariant),
                              ),
                            ),
                            title: Text(dest.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            subtitle: Text(dest.category, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                language.localeCode == 'en' ? 'Visited' : 'Dikunjungi',
                                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.success),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.push('/detail/${dest.id}');
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedDestinationsBottomSheet(BuildContext context, BookmarkProvider bookmark, LanguageProvider language) {
    final savedIds = bookmark.savedDestinationIds;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                language.localeCode == 'en' ? 'Saved Destinations' : 'Destinasi Disimpan',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: savedIds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              language.localeCode == 'en' ? 'No saved destinations' : 'Belum ada destinasi tersimpan',
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              language.localeCode == 'en' ? 'Bookmark from destination details!' : 'Simpan dari halaman detail destinasi!',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: savedIds.length,
                        itemBuilder: (context, index) {
                          final destId = savedIds[index];
                          final dest = DestinationsData.findById(destId);
                          if (dest == null) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  dest.image,
                                  width: 52, height: 52, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: AppColors.surfaceVariant),
                                ),
                              ),
                              title: Text(dest.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              subtitle: Text(dest.category, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                              trailing: IconButton(
                                icon: const Icon(Icons.bookmark_rounded, color: AppColors.accent),
                                onPressed: () {
                                  bookmark.toggleSaveDestination(dest.id);
                                  if (bookmark.savedCount == 0) {
                                    Navigator.pop(ctx);
                                  } else {
                                    setSheetState(() {});
                                  }
                                },
                              ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  context.push('/detail/${dest.id}');
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
          ),
        ),
      ),
    );
  }

    void _showAdminFinanceBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(ctx).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Dashboard Keuangan Routee',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Ringkasan arus kas, pendapatan sewa, dan komisi ojek online.',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        'Juni 2026 (Bulan Ini)',
                        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Total Revenue Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4A3219), Color(0xFF6D4C2A)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Pendapatan Bersih', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('Rp 4.250.000', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Target Bulanan', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                          Text('85% Terpenuhi', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accentLight)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Statistic Chart Section
                Text('Statistik Kontribusi Keuangan', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 26,
                            sections: [
                              PieChartSectionData(
                                color: AppColors.primary,
                                value: 2400000,
                                title: '56%',
                                radius: 24,
                                titleStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: AppColors.accent,
                                value: 1150000,
                                title: '27%',
                                radius: 24,
                                titleStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF6D4C2A),
                                value: 700000,
                                title: '17%',
                                radius: 24,
                                titleStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(AppColors.primary, 'Mobil', '56.5%'),
                            const SizedBox(height: 6),
                            _buildLegendItem(AppColors.accent, 'Motor', '27.1%'),
                            const SizedBox(height: 6),
                            _buildLegendItem(const Color(0xFF6D4C2A), 'RO-JEK', '16.4%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Rincian Sumber Pendapatan', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                _buildFinanceItem(Icons.directions_car_rounded, 'Sewa Mobil Nyaman', 'Rp 2.400.000', '60 unit dipesan'),
                _buildFinanceItem(Icons.two_wheeler_rounded, 'Sewa Motor Murah', 'Rp 1.150.000', '115 unit dipesan'),
                _buildFinanceItem(Icons.sports_motorsports_rounded, 'Ojek Online RO-JEK', 'Rp 700.000', '35 pesanan selesai'),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildLegendItem(Color color, String name, String percent) {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const Spacer(),
          Text(percent, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      );
    }

    Widget _buildFinanceItem(IconData icon, String label, String value, String desc) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(desc, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
      );
    }

    void _showAdminEmployeesBottomSheet(BuildContext context) {
      final auth = context.read<AuthProvider>();

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setSheetState) {
            final employees = auth.employees;

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(ctx).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Karyawan & Driver',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daftar staff operational yang bertugas di Gubeng.',
                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
                        tooltip: 'Tambah Karyawan',
                        onPressed: () {
                          _showAddEditEmployeeDialog(context, auth, null, () {
                            setSheetState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: employees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada karyawan',
                                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: employees.length,
                            itemBuilder: (context, idx) {
                              final emp = employees[idx];
                              final name = emp['name'] ?? '';
                              final email = emp['email'] ?? '';
                              final phone = emp['phone'] ?? '';
                              final initials = name.isNotEmpty ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'ST';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                                      child: Center(
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                                          Text(email, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                                          Text(phone, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, color: AppColors.accent, size: 20),
                                      onPressed: () {
                                        _showAddEditEmployeeDialog(context, auth, emp, () {
                                          setSheetState(() {});
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                                      onPressed: () {
                                        _showDeleteEmployeeConfirmDialog(context, auth, email, () {
                                          setSheetState(() {});
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    void _showAddEditEmployeeDialog(BuildContext context, AuthProvider auth, Map<String, String>? employee, VoidCallback onRefresh) {
      final isEdit = employee != null;
      final nameCtrl = TextEditingController(text: employee?['name'] ?? '');
      final emailCtrl = TextEditingController(text: employee?['email'] ?? '');
      final phoneCtrl = TextEditingController(text: employee?['phone'] ?? '');
      final passCtrl = TextEditingController(text: employee?['password'] ?? '');
      final formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Ubah Data Karyawan' : 'Tambah Karyawan Baru',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Karyawan',
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nomor telepon wajib diisi';
                      if (v.trim().length < 10) return 'Nomor telepon minimal 10 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Sandi Akun',
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                      if (v.length < 6) return 'Sandi minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  bool success;
                  if (isEdit) {
                    success = auth.updateEmployee(
                      originalEmail: employee['email']!,
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                    );
                  } else {
                    success = auth.addEmployee(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                    );
                  }

                  if (success) {
                    Navigator.pop(ctx);
                    onRefresh();
                    _showMockToast(context, isEdit ? 'Data karyawan berhasil diubah' : 'Karyawan berhasil ditambahkan');
                  } else {
                    _showMockToast(context, 'Email sudah terdaftar!');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                isEdit ? 'Simpan' : 'Tambah',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    void _showDeleteEmployeeConfirmDialog(BuildContext context, AuthProvider auth, String email, VoidCallback onRefresh) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Karyawan?',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus akun karyawan dengan email $email?',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                auth.deleteEmployee(email);
                Navigator.pop(ctx);
                onRefresh();
                _showMockToast(context, 'Karyawan berhasil dihapus');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
    }

    void _showKaryawanOpsBottomSheet(BuildContext context) {
      final List<Map<String, dynamic>> opsList = [
        {'id': 1, 'task': 'Penjemputan Ojek Gubeng', 'time': '13:00 WIB', 'status': 'Menuju Lokasi', 'color': AppColors.primary},
        {'id': 2, 'task': 'Pemeriksaan Unit Avanza', 'time': '14:30 WIB', 'status': 'Selesai', 'color': AppColors.success},
        {'id': 3, 'task': 'Pengembalian Vario 160', 'time': '16:00 WIB', 'status': 'Belum Selesai', 'color': AppColors.accent},
        {'id': 4, 'task': 'Pemberian Helm & Jas Hujan', 'time': '17:15 WIB', 'status': 'Belum Selesai', 'color': AppColors.accent},
      ];

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setSheetState) => Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Portal Tugas Operasional Karyawan',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monitoring status unit sewa, pengembalian kendaraan, dan penjemputan ojek.',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: opsList.length,
                    itemBuilder: (context, idx) {
                      final task = opsList[idx];
                      final color = task['color'] as Color;
                      final status = task['status'] as String;
                      final isSelesai = status == 'Selesai';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['task'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      decoration: isSelesai ? TextDecoration.lineThrough : null,
                                      color: isSelesai ? AppColors.textMuted : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Jadwal: ${task['time']}', style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted)),
                                  if (!isSelesai) ...[
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Membuka rute ke lokasi ${task['task']} di Google Maps...',
                                              style: GoogleFonts.poppins(fontSize: 11),
                                            ),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.map_rounded, size: 12, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Buka Google Maps',
                                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Bounceable(
                              onTap: () {
                                setSheetState(() {
                                  if (status == 'Belum Selesai') {
                                    task['status'] = 'Menuju Lokasi';
                                    task['color'] = AppColors.primary;
                                  } else if (status == 'Menuju Lokasi') {
                                    task['status'] = 'Selesai';
                                    task['color'] = AppColors.success;
                                  } else {
                                    task['status'] = 'Belum Selesai';
                                    task['color'] = AppColors.accent;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      status,
                                      style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: color),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.sync_rounded, size: 10, color: color),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
