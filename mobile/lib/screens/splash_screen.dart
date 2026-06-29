import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _titleOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.75, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B1B13),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cafe_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(child: _CoffeeGradient()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      ScaleTransition(
                        scale: _logoScale,
                        child: const _LogoBadge(),
                      ),
                      const SizedBox(height: 34),
                      SlideTransition(
                        position: _titleOffset,
                        child: const _BrandCopy(),
                      ),
                      const Spacer(flex: 2),
                      const _LoadingPanel(),
                      const SizedBox(height: 42),
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

class _CoffeeGradient extends StatelessWidget {
  const _CoffeeGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2B1B13).withValues(alpha: 0.44),
            const Color(0xFF3E2C23).withValues(alpha: 0.82),
            const Color(0xFF2B1B13).withValues(alpha: 0.64),
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      height: 176,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF7ED),
            Color(0xFFE4C4A2),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.32),
            blurRadius: 42,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.42),
            blurRadius: 22,
            offset: const Offset(-10, -10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 136,
          height: 136,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3E2C23),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo_app.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _BrandCopy extends StatelessWidget {
  const _BrandCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'CODE CAFE',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.64),
              width: 1,
            ),
          ),
          child: Text(
            'Fresh brews. Fast orders. Warm moments.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDark,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            color: AppTheme.primaryDark,
            backgroundColor: Colors.white.withValues(alpha: 0.4),
            strokeCap: StrokeCap.round,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Preparing your cafe experience',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
