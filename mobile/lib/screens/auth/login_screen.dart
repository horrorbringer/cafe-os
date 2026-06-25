import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';


class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterTap;

  const LoginScreen({super.key, this.onRegisterTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _serverError;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('phone number not found')) {
      return 'No account found with this phone number. Please check or sign up.';
    }
    if (lower.contains('invalid password')) {
      return 'Incorrect password. Please try again.';
    }
    if (lower.contains('connection') || lower.contains('socketexception') || lower.contains('timeout')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }
    final cleaned = raw.replaceFirst(RegExp(r'^(ApiException|Exception):\s*', caseSensitive: false), '');
    return cleaned.isNotEmpty ? cleaned : 'Something went wrong. Please try again.';
  }

  Future<void> _login() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!success && mounted) {
      setState(() {
        _serverError = _friendlyError(auth.error ?? 'Login failed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with gradient overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/cafe_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppTheme.background),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.black26, Colors.black45],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 48,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.surface,
                                border: Border.all(color: AppTheme.surfaceLight, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Image.asset(
                                  'assets/images/logo_app.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // App name
                            Text(
                              'Cafe App',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Welcome back! Sign in to continue.',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Server error banner
                            if (_serverError != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _serverError!,
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.error,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Phone field
                            _buildField(
                              controller: _phoneController,
                              hintText: 'Phone number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
                                if (cleaned.length < 8 || cleaned.length > 15) {
                                  return 'Phone number must be 8-15 digits';
                                }
                                if (!RegExp(r'^[0-9+]+$').hasMatch(cleaned)) {
                                  return 'Phone number can only contain digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            _buildField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 4) {
                                  return 'Password must be at least 4 characters';
                                }
                                return null;
                              },
                              onSubmitted: (_) => _login(),
                            ),
                            const SizedBox(height: 4),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: AppTheme.primary,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign In Button
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                                      elevation: 0,
                                      shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            height: 22, width: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                          )
                                        : Text('Sign In',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                              letterSpacing: 0.3,
                                            )),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 28),

                            // OR divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppTheme.surfaceLight, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('OR',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      )),
                                ),
                                Expanded(child: Divider(color: AppTheme.surfaceLight, thickness: 1)),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Register link
                            GestureDetector(
                              onTap: widget.onRegisterTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?  ",
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Sign Up',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.outfit(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(icon, color: AppTheme.textSecondary, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 24),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surface,
        errorStyle: GoogleFonts.outfit(
          color: AppTheme.error,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.surfaceLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.surfaceLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.error.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
