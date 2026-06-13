import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../utils/constants.dart';
import '../screens/dashboard_screen.dart';
import '../screens/backup_screen.dart';
import '../screens/restore_screen.dart';
import '../screens/about_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../providers/auth_provider.dart'; // Moved here to avoid conflict with ThemeProvider

class AppDrawer extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;

  const AppDrawer({
    super.key,
    required this.themeProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildDivider() {
      return Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.white12 : const Color(0xFFF0F0F0),
        indent: 24,
        endIndent: 24,
      );
    }

    return Drawer(
      child: Column(
        children: [
          // ─── Header ──────────────────────────────────────
          ClipRRect(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Stack(
                children: [
                  // Decorative shapes to match the abstract background in the design
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Transform.rotate(
                      angle: 0.5,
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -60,
                    child: Transform.rotate(
                      angle: 0.5,
                      child: Container(
                        width: 120,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  // Header Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 35),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          authProvider.userName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          authProvider.userEmail,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Menu Items ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: authProvider.isLoggedIn ? Icons.person_rounded : Icons.login_rounded,
                  label: authProvider.isLoggedIn ? 'Profil Pengguna' : 'Login',
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          authProvider: authProvider,
                          themeProvider: themeProvider,
                        ),
                      ),
                    );
                  },
                ),
                buildDivider(),
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Dashboard',
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(themeProvider: themeProvider, authProvider: authProvider),
                      ),
                    );
                  },
                ),
                buildDivider(),
                _DrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat Transaksi',
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                    );
                  },
                ),
                buildDivider(),
                _DrawerItem(
                  icon: Icons.cloud_upload_rounded,
                  label: 'Backup Data',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BackupScreen(),
                      ),
                    );
                  },
                ),
                buildDivider(),
                _DrawerItem(
                  icon: Icons.cloud_download_rounded,
                  label: 'Restore Data',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RestoreScreen(),
                      ),
                    );
                  },
                ),
                buildDivider(),
                // Tema Gelap / Terang
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: SwitchListTile(
                    title: Text(
                      'Tema Gelap / Terang',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppTheme.primaryBlue,
                    secondary: Icon(Icons.brightness_high_rounded, color: isDark ? Colors.white70 : AppTheme.primaryBlue, size: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
                buildDivider(),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang Aplikasi',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                if (authProvider.isLoggedIn) ...[
                  buildDivider(),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    iconColor: AppTheme.danger,
                    textColor: AppTheme.danger,
                    onTap: () async {
                      Navigator.of(context).pop(); // Close drawer
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text('Anda yakin ingin logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Tidak')),
                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ya')),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await authProvider.logout();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil logout')));
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = isDark ? Colors.white70 : AppTheme.primaryBlue;
    final defaultTextColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(icon, color: iconColor ?? defaultIconColor, size: 22),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor ?? defaultTextColor,
          ),
        ),
        onTap: onTap,
        hoverColor: AppTheme.primaryBlue.withOpacity(0.08),
        splashColor: AppTheme.primaryBlue.withOpacity(0.12),
      ),
    );
  }
}
