import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../services/storage_service.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedFile;
  String? _selectedFilePath;
  bool _isRestoring = false;

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

  Future<void> _pickFile() async {
    try {
      // Mencari file backup di folder dokumen aplikasi
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();
      
      final backupFiles = files.where((f) => f.path.endsWith('.json')).toList();
      
      if (backupFiles.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ditemukan file backup di folder aplikasi.')),
        );
        return;
      }

      // Urutkan berdasarkan tanggal modifikasi (terbaru di atas)
      backupFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      setState(() {
        _selectedFilePath = backupFiles.first.path;
        _selectedFile = backupFiles.first.path.split(Platform.pathSeparator).last;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File backup terbaru dipilih otomatis')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari file: $e')),
      );
    }
  }

  Future<void> _doRestore() async {
    if (_selectedFilePath == null) {
      // Jika belum ada file, coba cari otomatis dulu
      await _pickFile();
      if (_selectedFilePath == null) return;
    }

    setState(() => _isRestoring = true);
    
    try {
      final File file = File(_selectedFilePath!);
      final String content = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(content);
      
      final List<TransactionModel> transactions = jsonData
          .map((item) => TransactionModel.fromJson(item))
          .toList();
          
      await _storageService.saveAll(transactions);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dipulihkan!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal restore data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                        'Restore Data',
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
                      // ── Cloud Download Icon ──
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
                          Icons.cloud_download_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Restore Data',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pulihkan data transaksi dari file backup yang sebelumnya dibuat',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Restore Button ──
                      if (_isRestoring)
                        Column(
                          children: [
                            const SizedBox(
                              width: 50,
                              height: 50,
                              child:
                                  CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Memulihkan data...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.white54 : Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else
                        GradientButton(
                          label: 'Restore Sekarang',
                          icon: Icons.cloud_download_rounded,
                          onPressed: _doRestore,
                        ),

                      const SizedBox(height: 40),
                      // ── Selected File Info ──
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
                                  Icons.insert_drive_file_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'File Terpilih',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_selectedFile != null) ...[
                              _infoRow(
                                  'Nama', _selectedFile!, isDark),
                              const SizedBox(height: 6),
                              _infoRow('Ukuran', '1.1 MB', isDark),
                            ] else
                              Text(
                                'Belum ada file yang dipilih',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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
                              'Pastikan file backup yang dipilih adalah file yang valid (.json) untuk menghindari kegagalan pemulihan data.',
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

  Widget _infoRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
