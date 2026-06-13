import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import '../utils/formatter.dart';
import '../theme/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();
  List<TransactionModel> _transactions = [];
  DateTime? _selectedDateFilter;
  String _selectedTypeFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final allTransactions = await _storageService.getAll();
    setState(() {
      _transactions = allTransactions;
    });
  }

  Future<bool?> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(String id) async {
    await _storageService.delete(id);
    if (mounted) {
      _loadTransactions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus')),
      );
    }
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Semua', 'Pemasukan', 'Pengeluaran'].map((type) => ListTile(
          title: Text(type),
          onTap: () {
            setState(() => _selectedTypeFilter = type);
            Navigator.pop(context);
          },
          trailing: _selectedTypeFilter == type ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
        )).toList(),
      ),
    );
  }

  Future<void> _pickDateFilter() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateFilter = null;
    });
  }

  List<TransactionModel> get _filteredTransactions {
    List<TransactionModel> filtered = _transactions;

    if (_selectedDateFilter != null) {
      filtered = filtered.where((t) {
        return t.date.year == _selectedDateFilter!.year &&
            t.date.month == _selectedDateFilter!.month &&
            t.date.day == _selectedDateFilter!.day;
      }).toList();
    }

    if (_selectedTypeFilter != 'Semua') {
      filtered = filtered.where((t) => t.type == _selectedTypeFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => t.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  num get _totalPemasukan => _filteredTransactions.where((e) => e.type == 'Pemasukan').fold<num>(0, (a, b) => a + b.amount);
  num get _totalPengeluaran => _filteredTransactions.where((e) => e.type == 'Pengeluaran').fold<num>(0, (a, b) => a + b.amount);
  num get _saldoAkhir => _totalPemasukan - _totalPengeluaran;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Riwayat Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search and Action Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                              hintText: 'Cari keterangan...',
                              hintStyle: GoogleFonts.poppins(color: isDark ? Colors.white38 : Colors.black38),
                              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryBlue)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.filter_alt_outlined, color: isDark ? Colors.white70 : Colors.black87),
                            onPressed: _showTypeFilter,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Date Field
                    Text(
                      'Filter Tanggal',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDateFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateFilter == null ? 'Pilih tanggal' : Formatter.dateYmd(_selectedDateFilter!),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _selectedDateFilter == null ? (isDark ? Colors.white38 : Colors.black38) : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            Row(
                              children: [
                                if (_selectedDateFilter != null)
                                  GestureDetector(
                                    onTap: _clearDateFilter,
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Icon(Icons.close, size: 20, color: Colors.red),
                                    ),
                                  ),
                                Icon(Icons.calendar_today, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
              ),
            ),

            // Scrollable List
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada transaksi',
                        style: GoogleFonts.poppins(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final t = _filteredTransactions[index];
                        final isPemasukan = t.type == 'Pemasukan';
                        return Dismissible(
                          key: Key(t.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) => _showDeleteConfirmation(),
                          onDismissed: (direction) => _deleteTransaction(t.id.toString()),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: cardBg,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: (isPemasukan ? const Color(0xFF00C851) : const Color(0xFFFF4444)).withOpacity(0.1),
                                child: Icon(
                                  isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isPemasukan ? const Color(0xFF00C851) : const Color(0xFFFF4444),
                                  size: 20,
                                ),
                              ),
                              title: Text(t.description, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                              subtitle: Text(Formatter.dateYmd(t.date), style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                              trailing: Text(
                                Formatter.idr(t.amount),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: isPemasukan ? const Color(0xFF00C851) : const Color(0xFFFF4444),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Summary Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pemasukan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          Formatter.idr(_totalPemasukan),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00C851),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pengeluaran',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          Formatter.idr(_totalPengeluaran),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF4444),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo Akhir',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          Formatter.idr(_saldoAkhir),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Geser ke kiri pada item untuk menghapus',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}