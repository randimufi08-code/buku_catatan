import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction_model.dart';
import '../utils/formatter.dart';

class ReportDataCard extends StatelessWidget {
  final List<TransactionModel> rows;
  const ReportDataCard({super.key, required this.rows});

  num _totalSaldoAkhir() {
    num saldoBerjalan = 0;
    for (final e in rows) {
      final isIn = e.type == 'Pemasukan';
      saldoBerjalan += (isIn ? e.amount : -e.amount);
    }
    return saldoBerjalan;
  }

  DataColumn _buildHeaderColumn({
    required String label,
    required IconData icon,
  }) {
    return DataColumn(
      label: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldoAkhir = _totalSaldoAkhir();

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Keuangan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 14),

            if (rows.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 54, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada transaksi',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth < 720 ? 980 : constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowHeight: 56,
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 60,
                        columnSpacing: 14,
                        horizontalMargin: 8,
                        columns: [
                          _buildHeaderColumn(
                            label: 'Tanggal',
                            icon: Icons.calendar_today_rounded,
                          ),
                          _buildHeaderColumn(
                            label: 'Keterangan',
                            icon: Icons.description_rounded,
                          ),
                          _buildHeaderColumn(
                            label: 'Pemasukan',
                            icon: Icons.arrow_downward_rounded,
                          ),
                          _buildHeaderColumn(
                            label: 'Pengeluaran',
                            icon: Icons.arrow_upward_rounded,
                          ),
                          _buildHeaderColumn(
                            label: 'Saldo',
                            icon: Icons.trending_up_rounded,
                          ),
                        ],
                        rows: (() {
                          num saldoBerjalan = 0;
                          return List.generate(rows.length, (index) {
                            final e = rows[index];
                            final isIn = e.type == 'Pemasukan';
                            final income = isIn ? e.amount : 0;
                            final expense = isIn ? 0 : e.amount;
                            saldoBerjalan += (isIn ? e.amount : -e.amount);

                            final zebra = index.isEven ? Colors.white : const Color(0xFFF7FAFC);
                            final textStyleBase = GoogleFonts.poppins(fontWeight: FontWeight.w600);
                            final Color numberColor = isIn ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

                            return DataRow(
                              color: WidgetStateProperty.all(zebra),
                              cells: [
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      Formatter.dateYmd(e.date),
                                      style: textStyleBase.copyWith(color: Colors.black87),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          e.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyleBase.copyWith(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      isIn ? Formatter.idr(income) : '-',
                                      style: textStyleBase.copyWith(
                                        color: isIn ? numberColor : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      !isIn ? Formatter.idr(expense) : '-',
                                      style: textStyleBase.copyWith(
                                        color: !isIn ? numberColor : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      Formatter.idr(saldoBerjalan),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                        })(),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 14),

            // Total saldo bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.summarize_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Saldo Akhir',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Formatter.idr(saldoAkhir),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
