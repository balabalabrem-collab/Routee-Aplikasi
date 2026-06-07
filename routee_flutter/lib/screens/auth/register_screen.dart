import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

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
        setState(() => _errorMessage = 'Email sudah terdaftar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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

              Text('Buat Akun Baru', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Daftar untuk menikmati semua fitur Routee', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),

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
                        labelText: 'Nama Lengkap',
                        hintText: 'John Doe',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Nama harus diisi' : null,
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
                        if (v == null || v.isEmpty) return 'Email harus diisi';
                        if (!v.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) => (v == null || v.length < 10) ? 'Nomor HP minimal 10 digit' : null,
                    ),
                    const SizedBox(height: 14),
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
                        if (v == null || v.isEmpty) return 'Password harus diisi';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) return 'Password tidak cocok';
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
                      : Text('Daftar', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun? ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Masuk', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text('Kembali ke Beranda', style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
