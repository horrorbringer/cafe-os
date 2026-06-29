import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customer = auth.customer;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/cafe_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.background.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 24, right: 24, bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background.withValues(alpha: 0.95),
                    AppTheme.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.settings_outlined, size: 20, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Content
          RefreshIndicator(
            onRefresh: () => auth.refreshProfile(),
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Avatar + Name
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFFFF7ED), Color(0xFFE4C4A2)],
                                  ),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.2),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _buildAvatarInitial(customer?.name),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            customer?.name ?? 'Premium Member',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_outlined, size: 13, color: AppTheme.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                customer?.phone ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // VIP Card
                    _buildVIPCard(context, customer),
                    
                    const SizedBox(height: 36),

                    // Account Details
                    _buildSectionHeader('Account Details'),
                    const SizedBox(height: 16),
                    _infoTile(
                      icon: Icons.phone_iphone_rounded,
                      label: 'Phone Number',
                      value: customer?.phone ?? '-',
                    ),
                    _infoTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email Address',
                      value: customer?.email ?? 'Not provided',
                    ),
                    _infoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Primary Address',
                      value: '88 Sothearos Blvd, Phnom Penh',
                    ),

                    const SizedBox(height: 36),

                    // Preferences
                    _buildSectionHeader('Preferences'),
                    const SizedBox(height: 16),
                    _prefTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      trailing: Switch.adaptive(
                        value: true,
                        onChanged: (_) {},
                        activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                        inactiveTrackColor: AppTheme.surfaceLight,
                      ),
                    ),
                    _prefTile(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      trailing: Text(
                        'English',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => _confirmLogout(context, auth),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, size: 18, color: AppTheme.error),
                            const SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitial(String? name) {
    if (name != null && name.isNotEmpty) {
      return Text(
        name[0].toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      );
    }
    return const Icon(Icons.person_outline_rounded, size: 44, color: AppTheme.primary);
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, size: 28, color: AppTheme.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign Out',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  auth.logout();
                  Navigator.pop(ctx);
                  onLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Yes, Sign Out',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVIPCard(BuildContext context, dynamic customer) {
    final points = customer?.loyaltyPoints ?? 0;
    final rate = customer?.loyaltyRedeemRate ?? 0.1;
    final level = (customer?.membershipLevel ?? 'BRONZE').toUpperCase();
    final pointsValue = (points * rate).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned(
            right: -20, top: -20,
            child: Icon(Icons.stars_rounded, size: 140, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            left: -30, bottom: -30,
            child: Icon(Icons.coffee_rounded, size: 100, color: Colors.white.withValues(alpha: 0.04)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier badge + icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            level,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Points
                Text(
                  'YOUR BALANCE',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$points',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 42,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'pts',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '=\$$pointsValue',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: AppTheme.surfaceLight)),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.surfaceLight, size: 22),
        ],
      ),
    );
  }

  Widget _prefTile({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
