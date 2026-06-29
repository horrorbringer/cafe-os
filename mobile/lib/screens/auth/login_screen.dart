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
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
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
    if (lower.contains('phone number not found')) return 'No account found with this phone number.';
    if (lower.contains('invalid password')) return 'Incorrect password. Please try again.';
    if (lower.contains('connection') || lower.contains('socketexception') || lower.contains('timeout')) {
      return 'Unable to connect to the server. Please check your internet.';
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
      setState(() => _serverError = _friendlyError(auth.error ?? 'Login failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Hero illustration — top ~45%
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.45,
            child: Stack(
              children: [
                Image.asset('assets/images/cafe_bg.png', fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppTheme.primaryDark),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryDark.withValues(alpha: 0.45),
                        AppTheme.primary.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 40,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Image.asset('assets/images/logo_app.png', fit: BoxFit.contain),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Cafe App',
                                style: GoogleFonts.outfit(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.8,
                                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16)],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fresh brews. Fast orders.',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 0.8,
                                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Decorative wave transition
          Positioned(
            top: size.height * 0.45 - 2,
            left: 0, right: 0,
            child: CustomPaint(
              size: Size(size.width, 40),
              painter: _WavePainter(color: Colors.white),
            ),
          ),

          // Form card — bottom 60%
          Positioned(
            top: size.height * 0.44,
            left: 0, right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back.',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to your account.',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Server error
                          if (_serverError != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(_serverError!,
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.error, fontWeight: FontWeight.w600, fontSize: 13, height: 1.3,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _serverError = null),
                                    child: Icon(Icons.close_rounded, color: AppTheme.error.withValues(alpha: 0.4), size: 18),
                                  ),
                                ],
                              ),
                            ),

                          // Phone
                          _buildField(
                            controller: _phoneController,
                            hintText: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
                              final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
                              if (cleaned.length < 8 || cleaned.length > 15) return 'Phone number must be 8-15 digits';
                              if (!RegExp(r'^[0-9+]+$').hasMatch(cleaned)) return 'Phone number can only contain digits';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password
                          _buildField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  size: 20, color: AppTheme.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your password';
                              if (value.length < 4) return 'Password must be at least 4 characters';
                              return null;
                            },
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 2),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: AppTheme.primary,
                              ),
                              child: Text('Forgot Password?',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sign In button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: auth.isLoading
                                        ? LinearGradient(colors: [AppTheme.primary.withValues(alpha: 0.5), AppTheme.primaryDark.withValues(alpha: 0.5)])
                                        : LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            height: 22, width: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Sign In',
                                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3)),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.arrow_forward_rounded, size: 19),
                                            ],
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Switch to register
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Don't have an account? ",
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 14)),
                                GestureDetector(
                                  onTap: widget.onRegisterTap,
                                  child: Text('Sign Up',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
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
    final focusColor = AppTheme.primary;

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
          color: AppTheme.textSecondary.withValues(alpha: 0.7),
          fontWeight: FontWeight.w400,
          fontSize: 15,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: focusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: focusColor, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 40),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F6F3),
        errorStyle: GoogleFonts.outfit(
          color: AppTheme.error,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: focusColor.withValues(alpha: 0.4), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..quadraticBezierTo(size.width * 0.25, 24, size.width * 0.5, 0)
      ..quadraticBezierTo(size.width * 0.75, -24, size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.color != color;
}
