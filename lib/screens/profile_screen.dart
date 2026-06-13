import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;

  const ProfileScreen({
    super.key,
    required this.authProvider,
    required this.themeProvider,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.authProvider.userName;
    _emailController.text = widget.authProvider.userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showEditSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Profil',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.authProvider.updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil berhasil diperbarui!')),
                      );
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.white38 : Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.white38 : Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Avatar with camera badge
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.authProvider.userName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              widget.authProvider.userEmail,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Info Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFF0F0F0),
                ),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Nama Lengkap',
                    subtitle: widget.authProvider.userName,
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFF0F0F0), indent: 16, endIndent: 16),
                  _buildProfileTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email',
                    subtitle: widget.authProvider.userEmail,
                    isDark: isDark,
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFF0F0F0), indent: 16, endIndent: 16),
                  _buildProfileTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Kata Sandi',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Ubah Kata Sandi belum tersedia')));
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Edit Profil Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _showEditSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Edit Profil',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 26),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: subtitle != null ? 13 : 15,
          color: subtitle != null 
              ? (isDark ? Colors.white54 : Colors.black54)
              : (isDark ? Colors.white : Colors.black87),
          fontWeight: subtitle != null ? FontWeight.w500 : FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null ? Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 24),
    );
  }
}