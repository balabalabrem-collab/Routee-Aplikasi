import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        context.go('/');
      } else {
        setState(() => _errorMessage = 'Email atau password salah');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final language = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Language Selector Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      language.setLanguage(language.currentLanguage == 'Bahasa Indonesia' ? 'English' : 'Bahasa Indonesia');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Text(language.currentLanguage == 'Bahasa Indonesia' ? '🇮🇩 ID' : '🇬🇧 EN', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.translate_rounded, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Logo
              SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(
                  'assets/images/logo v2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('R', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 36, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text('ROUTEE', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 4)),
              const SizedBox(height: 4),
              Text(AppStrings.slogan, style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.accent, fontWeight: FontWeight.w500)),

              const SizedBox(height: 40),

              // Title
              Text(
                language.translateText(id: 'Masuk ke Akunmu', en: 'Log in to your account'),
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                language.translateText(id: 'Akses fitur sewa transportasi dan lainnya', en: 'Access transport rentals and other features'),
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'contoh@email.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return language.translateText(id: 'Email harus diisi', en: 'Email is required');
                        }
                        if (!v.contains('@')) {
                          return language.translateText(id: 'Email tidak valid', en: 'Invalid email format');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return language.translateText(id: 'Password harus diisi', en: 'Password is required');
                        }
                        if (v.length < 6) {
                          return language.translateText(id: 'Password minimal 6 karakter', en: 'Password must be at least 6 characters');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showForgotPasswordDialog(context),
                        child: Text(
                          language.translateText(id: 'Lupa Password?', en: 'Forgot Password?'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          language.translateText(id: 'Masuk', en: 'Log In'),
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Enter without account (Guest mode)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () {
                          auth.logout();
                          context.go('/');
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    language.translateText(id: 'Masuk Tanpa Akun (Mode Tamu)', en: 'Enter without Account (Guest Mode)'),
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Demo Accounts Info Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          language.translateText(id: 'Info Akun Demo Uji Coba:', en: 'Demo Accounts Info:'),
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language.translateText(
                        id: '• Admin: admin@routee.id (Sandi: adminRoutee2026)\n• Karyawan: karyawan@routee.id (Sandi: staffRoutee2026)',
                        en: '• Admin: admin@routee.id (Pass: adminRoutee2026)\n• Staff: karyawan@routee.id (Pass: staffRoutee2026)',
                      ),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.translateText(id: 'Belum punya akun? ', en: 'Don\'t have an account? '),
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text(
                      language.translateText(id: 'Daftar Sekarang', en: 'Register Now'),
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final language = context.read<LanguageProvider>();
    final auth = context.read<AuthProvider>();

    final emailCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confPassCtrl = TextEditingController();

    final formKey1 = GlobalKey<FormState>();
    final formKey2 = GlobalKey<FormState>();
    final formKey3 = GlobalKey<FormState>();

    int currentStep = 1; // 1: Email, 2: OTP, 3: New Password
    String? localError;
    String targetEmail = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    currentStep == 1
                        ? Icons.email_outlined
                        : currentStep == 2
                            ? Icons.security_rounded
                            : Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentStep == 1
                        ? language.translateText(id: 'Lupa Password?', en: 'Forgot Password?')
                        : currentStep == 2
                            ? language.translateText(id: 'Verifikasi Kode', en: 'Verify Code')
                            : language.translateText(id: 'Password Baru', en: 'New Password'),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (localError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withOpacity(0.2)),
                        ),
                        child: Text(
                          localError!,
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.error),
                        ),
                      ),
                    ],

                    // Step 1: Input Email
                    if (currentStep == 1)
                      Form(
                        key: formKey1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.translateText(
                                id: 'Masukkan alamat email Anda yang terdaftar pada sistem Routee.',
                                en: 'Enter your email address registered with the Routee system.',
                              ),
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'contoh@email.com',
                                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                labelStyle: GoogleFonts.poppins(fontSize: 13),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return language.translateText(id: 'Email harus diisi', en: 'Email is required');
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return language.translateText(id: 'Format email tidak valid', en: 'Invalid email format');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                    // Step 2: Verification Code OTP
                    if (currentStep == 2)
                      Form(
                        key: formKey2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.translateText(
                                id: 'Kami mensimulasikan pengiriman kode verifikasi 4-digit ke $targetEmail.',
                                en: 'We simulated sending a 4-digit verification code to $targetEmail.',
                              ),
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      language.translateText(
                                        id: 'Gunakan kode demo: 1234',
                                        en: 'Use demo code: 1234',
                                      ),
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: otpCtrl,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 8),
                              decoration: InputDecoration(
                                labelText: language.translateText(id: 'Kode OTP', en: 'OTP Code'),
                                labelStyle: GoogleFonts.poppins(fontSize: 13),
                                counterText: '',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return language.translateText(id: 'Kode verifikasi harus diisi', en: 'Verification code is required');
                                }
                                if (v != '1234') {
                                  return language.translateText(id: 'Kode verifikasi tidak sesuai', en: 'Incorrect verification code');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                    // Step 3: New Password
                    if (currentStep == 3)
                      Form(
                        key: formKey3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.translateText(
                                id: 'Buat kata sandi baru untuk akun Anda.',
                                en: 'Create a new password for your account.',
                              ),
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: newPassCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: language.translateText(id: 'Kata Sandi Baru', en: 'New Password'),
                                labelStyle: GoogleFonts.poppins(fontSize: 13),
                                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return language.translateText(id: 'Password harus diisi', en: 'Password is required');
                                }
                                if (v.length < 6) {
                                  return language.translateText(id: 'Password minimal 6 karakter', en: 'Password must be at least 6 characters');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: confPassCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: language.translateText(id: 'Konfirmasi Sandi', en: 'Confirm Password'),
                                labelStyle: GoogleFonts.poppins(fontSize: 13),
                                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              ),
                              validator: (v) {
                                if (v != newPassCtrl.text) {
                                  return language.translateText(id: 'Password tidak cocok', en: 'Passwords do not match');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    language.translateText(id: 'Batal', en: 'Cancel'),
                    style: GoogleFonts.poppins(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => localError = null);
                    if (currentStep == 1) {
                      if (formKey1.currentState!.validate()) {
                        final email = emailCtrl.text.trim();
                        if (auth.userExists(email)) {
                          setState(() {
                            targetEmail = email;
                            currentStep = 2;
                          });
                        } else {
                          setState(() {
                            localError = language.translateText(
                              id: 'Email tidak terdaftar dalam sistem Routee',
                              en: 'Email is not registered in Routee system',
                            );
                          });
                        }
                      }
                    } else if (currentStep == 2) {
                      if (formKey2.currentState!.validate()) {
                        setState(() {
                          currentStep = 3;
                        });
                      }
                    } else if (currentStep == 3) {
                      if (formKey3.currentState!.validate()) {
                        final success = auth.resetPassword(targetEmail, newPassCtrl.text);
                        if (success) {
                          Navigator.pop(ctx);
                          _showResetSuccessDialog(context, targetEmail);
                        } else {
                          setState(() {
                            localError = language.translateText(
                              id: 'Gagal mengatur ulang kata sandi. Silakan coba lagi.',
                              en: 'Failed to reset password. Please try again.',
                            );
                          });
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    currentStep == 3
                        ? language.translateText(id: 'Simpan', en: 'Save')
                        : language.translateText(id: 'Lanjutkan', en: 'Continue'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetSuccessDialog(BuildContext context, String email) {
    final language = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              const SizedBox(width: 8),
              Text(
                language.translateText(id: 'Password Diperbarui', en: 'Password Updated'),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            language.translateText(
              id: 'Kata sandi untuk $email berhasil diubah secara lokal. Silakan masuk kembali dengan password baru Anda.',
              en: 'Password for $email has been successfully updated locally. Please log in with your new password.',
            ),
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                language.translateText(id: 'Mengerti', en: 'Got it'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
