import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        context.go('/');
      } else {
        final language = context.read<LanguageProvider>();
        setState(() => _errorMessage = language.translateText(
          id: 'Email sudah terdaftar',
          en: 'Email is already registered',
        ));
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
              const SizedBox(height: 24),

              // Logo
              SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(
                  'assets/images/logo v2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                    child: Center(child: Text('R', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.w900))),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(AppStrings.slogan, style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.accent, fontWeight: FontWeight.w500)),

              const SizedBox(height: 24),

              Text(
                language.translateText(id: 'Buat Akun Baru', en: 'Create New Account'),
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                language.translateText(id: 'Daftar untuk menikmati semua fitur Routee', en: 'Register to enjoy all Routee features'),
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

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
                      Expanded(child: Text(_errorMessage!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: language.translateText(id: 'Nama Lengkap', en: 'Full Name'),
                        hintText: 'John Doe',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) => (v == null || v.isEmpty) 
                          ? language.translateText(id: 'Nama harus diisi', en: 'Name is required') 
                          : null,
                    ),
                    const SizedBox(height: 14),
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
                          return language.translateText(id: 'Email tidak valid', en: 'Email is not valid');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: language.translateText(id: 'Nomor HP', en: 'Phone Number'),
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) => (v == null || v.length < 10) 
                          ? language.translateText(id: 'Nomor HP minimal 10 digit', en: 'Phone number must be at least 10 digits') 
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: language.translateText(id: 'Password', en: 'Password'),
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
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: language.translateText(id: 'Konfirmasi Password', en: 'Confirm Password'),
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return language.translateText(id: 'Password tidak cocok', en: 'Passwords do not match');
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          language.translateText(id: 'Daftar', en: 'Register'),
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.translateText(id: 'Sudah punya akun? ', en: 'Already have an account? '),
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      language.translateText(id: 'Masuk', en: 'Log In'),
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(
                  language.translateText(id: 'Kembali ke Beranda', en: 'Back to Home'),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
