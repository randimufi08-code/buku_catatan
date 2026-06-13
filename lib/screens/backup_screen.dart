import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../services/storage_service.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> with SingleTickerProviderStateMixin {
  bool _isBackingUp = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _doBackup() async {
    setState(() => _isBackingUp = true);

    try {
      // 1. Ambil semua data transaksi dari storage
      final List<TransactionModel> data = await _storageService.getAll();

      if (data.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data transaksi untuk dicadangkan.')),
        );
        return;
      }

      // 2. Konversi data transaksi ke format JSON (List of Maps)
      final List<Map<String, dynamic>> jsonData = data.map((t) => t.toJson()).toList();

      final String jsonString = jsonEncode(jsonData);

      // 3. Tentukan lokasi penyimpanan (Folder Documents di Windows/Android/iOS)
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'backup_keuangan_${DateTime.now().millisecondsSinceEpoch}.json';
      final File file = File('${directory.path}/$fileName');

      // 4. Tulis file JSON ke penyimpanan
      await file.writeAsString(jsonString);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil! File cadangan disimpan di: ${file.path}'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat backup: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Backup Data',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ── Cloud Upload Icon ──
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cloud_upload_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Backup Data',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simpan semua data transaksi ke file backup (.json) untuk mengamankan data Anda',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Backup Button ──
                      if (_isBackingUp)
                        Column(
                          children: [
                            const SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Membuat backup...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.white54 : Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else
                        GradientButton(
                          label: 'Backup Sekarang',
                          icon: Icons.cloud_upload_rounded,
                          onPressed: _doBackup,
                        ),

                      const SizedBox(height: 40),

                      // ── Info Block ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? [] : AppTheme.cardShadow,
                          border: isDark ? Border.all(color: borderColor) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Informasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Pastikan file backup disimpan di tempat yang aman. Anda dapat menggunakan file ini untuk memulihkan data kapan saja.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
