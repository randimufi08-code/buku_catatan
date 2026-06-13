import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../theme/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/formatter.dart';
import '../widgets/app_drawer.dart';
import 'report_data_card.dart';

class DashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;

  const DashboardScreen({
    super.key,
    required this.themeProvider,
    required this.authProvider,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = StorageService();

  final _tanggalController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _jumlahController = TextEditingController();

  String _tipe = 'Pemasukan';
  DateTime _selectedDate = DateTime.now();

  List<TransactionModel> _rows = [];

  num get _totalPemasukan =>
      _rows.where((e) => e.type == 'Pemasukan').fold<num>(0, (a, b) => a + b.amount);

  num get _totalPengeluaran => _rows
      .where((e) => e.type == 'Pengeluaran')
      .fold<num>(0, (a, b) => a + b.amount);

  num get _saldoAkhir => _totalPemasukan - _totalPengeluaran;

  @override
  void initState() {
    super.initState();
    _tanggalController.text = Formatter.dateYmd(_selectedDate);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _storage.getAll();
    if (!mounted) return;
    setState(() {
      _rows = data;
    });
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _keteranganController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = Formatter.dateYmd(picked);
      });
    }
  }

  Future<void> _addTransaction() async {
    final ket = _keteranganController.text.trim();
    final jumlahRaw = _jumlahController.text.trim();
    final jumlah = num.tryParse(jumlahRaw.replaceAll(',', '.'));

    if (ket.isEmpty || jumlah == null) return;

    await _storage.add(
      TransactionModel(
        date: _selectedDate,
        description: ket,
        type: _tipe,
        amount: jumlah,
      ),
    );

    _keteranganController.clear();
    _jumlahController.clear();
    await _loadData();
  }

  Future<void> _hapusSemua() async {
    await _storage.clearAll();
    await _loadData();
  }

  Future<void> _hapusBarisTerakhir() async {
    await _storage.removeLast();
    await _loadData();
  }

  Future<void> _savePdf() async {
    if (_rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada data untuk disimpan PDF')),
      );
      return;
    }

    await PdfService.saveReportPdf(rows: _rows, date: _selectedDate);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF berhasil disimpan/dibuat')),
    );
  }

  Widget _buildFormLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEAEEF2);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF0D6EFD).withOpacity(0.8)),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFEAEEF2),
        ),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _tipe,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem(
              value: 'Pemasukan',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF198754).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.arrow_upward, size: 16, color: Color(0xFF198754)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pemasukan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Pengeluaran',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC3545).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.arrow_downward, size: 16, color: Color(0xFFDC3545)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pengeluaran',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _tipe = v);
          },
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: _addTransaction,
          icon: const Icon(Icons.add),
          label: const Text('Simpan'),
        ),
        OutlinedButton.icon(
          onPressed: _hapusBarisTerakhir,
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('Hapus Terakhir'),
        ),
        OutlinedButton.icon(
          onPressed: _hapusSemua,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Hapus Semua'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
          ),
        ),
        OutlinedButton.icon(
          onPressed: _savePdf,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Simpan PDF'),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final isNarrow = width < 500;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isNarrow ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(
              title: 'Pemasukan',
              amount: _totalPemasukan,
              icon: Icons.arrow_upward,
              color: const Color(0xFF198754),
              bgColor: isDark ? const Color(0xFF1B2E24) : const Color(0xFFEAF5EA),
              isDark: isDark,
            ),
            _buildStatCard(
              title: 'Pengeluaran',
              amount: _totalPengeluaran,
              icon: Icons.arrow_downward,
              color: const Color(0xFFDC3545),
              bgColor: isDark ? const Color(0xFF3B1E21) : const Color(0xFFFDECEA),
              isDark: isDark,
            ),
            _buildStatCard(
              title: 'Saldo Akhir',
              amount: _saldoAkhir,
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF0D6EFD),
              bgColor: isDark ? const Color(0xFF14244B) : const Color(0xFFE8F2FC),
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required num amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatter.idr(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const appBlue = Color(0xFF0D6EFD);
    const green = Color(0xFF198754);
    const red = Color(0xFFDC3545);
    const blueCard = Color(0xFF0D6EFD);

    // UI-only: tidak mengubah logic CRUD apa pun.
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      drawer: AppDrawer(
        themeProvider: widget.themeProvider,
        authProvider: widget.authProvider,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: appBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'CATATAN KEUANGAN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mengelola Keuangan Anda Dengan Lebih Baik',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              // ===== Card Ringkasan (3 card berjajar) =====
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildSummaryCardWhite(
                        label: 'Pemasukan',
                        amount: Formatter.idr(_totalPemasukan),
                        borderColor: green,
                        icon: Icons.arrow_upward,
                        iconColor: green,
                        bgColor: const Color(0xFFEAF5EA),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCardWhite(
                        label: 'Pengeluaran',
                        amount: Formatter.idr(_totalPengeluaran),
                        borderColor: red,
                        icon: Icons.arrow_downward,
                        iconColor: red,
                        bgColor: const Color(0xFFFDECEA),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCardWhite(
                        label: 'Saldo Akhir',
                        amount: Formatter.idr(_saldoAkhir),
                        borderColor: blueCard,
                        icon: Icons.account_balance_wallet,
                        iconColor: blueCard,
                        bgColor: const Color(0xFFE8F2FC),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ===== Form Tambah Transaksi =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFEAEAEA),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '☰',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: appBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Tambah Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFBDBDBD),
                    ),
                    const SizedBox(height: 18),

                    _buildFormLabel('Tanggal:', isDark),
                    _buildTextField(
                      controller: _tanggalController,
                      hint: 'dd/mm/yyyy',
                      suffixIcon: const Icon(Icons.calendar_today),
                      readOnly: true,
                      onTap: _pickDate,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    _buildFormLabel('Keterangan:', isDark),
                    _buildTextField(
                      controller: _keteranganController,
                      hint: 'Masukkan keterangan transaksi',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    _buildFormLabel('Tipe Transaksi:', isDark),
                    _buildDropdown(isDark),
                    const SizedBox(height: 14),

                    _buildFormLabel('Jumlah (Rp):', isDark),
                    _buildTextField(
                      controller: _jumlahController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 18),

                    // ===== Tombol Aksi Grid 2x2 =====
                    LayoutBuilder(
                      builder: (context, c) {
                        final gap = 12.0;
                        final w = c.maxWidth;
                        final itemW = (w - (gap)) / 2; // 2 kolom
                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: itemW,
                                  child: _actionCardButton(
                                    color: green,
                                    icon: Icons.add_circle_outline,
                                    text: 'Tambah Transaksi',
                                    onPressed: _addTransaction,
                                  ),
                                ),
                                SizedBox(width: gap),
                                SizedBox(
                                  width: itemW,
                                  child: _actionCardButton(
                                    color: red,
                                    icon: Icons.delete_outline,
                                    text: 'Hapus Semua Data',
                                    onPressed: _hapusSemua,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: gap),

                            Row(
                              children: [
                                SizedBox(
                                  width: itemW,
                                  child: _actionCardButton(
                                    color: appBlue,
                                    icon: Icons.save_outlined,
                                    text: 'Simpan PDF',
                                    onPressed: _savePdf,
                                  ),
                                ),
                                SizedBox(width: gap),
                                SizedBox(
                                  width: itemW,
                                  child: _actionCardButton(
                                    color: const Color(0xFFE6A817),
                                    icon: Icons.delete_sweep_outlined,
                                    text: 'Hapus Baris Terakhir',
                                    onPressed: _hapusBarisTerakhir,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== Report Card =====
              if (rows.isNotEmpty)
                ReportDataCard(rows: rows)
              else
                const SizedBox.shrink(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCardWhite({
    required String label,
    required String amount,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon + Label in a row (matching mobile design)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.transparent : Colors.white,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Amount below
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCardButton({
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
