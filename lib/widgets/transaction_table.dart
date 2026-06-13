import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/formatter.dart';

class TransactionTable extends StatelessWidget {
  final List<TransactionModel> rows;

  const TransactionTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    num saldoBerjalan = 0;

    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 700),
            child: DataTable(
              columnSpacing: 18,
              headingRowHeight: 48,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              columns: const [
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Keterangan')),
                DataColumn(label: Text('Pemasukan (Rp)')),
                DataColumn(label: Text('Pengeluaran (Rp)')),
                DataColumn(label: Text('Saldo (Rp)')),
              ],
              rows: rows.map((e) {
                final isIn = e.type == 'Pemasukan';
                final income = isIn ? e.amount : 0;
                final expense = isIn ? 0 : e.amount;

                // Saldo kumulatif: saldo berjalan + (pemasukan - pengeluaran)
                saldoBerjalan += (isIn ? e.amount : -e.amount);

                return DataRow(
                  cells: [
                    DataCell(Text(Formatter.dateYmd(e.date))),
                    DataCell(Text(e.description)),
                    DataCell(Text(isIn ? Formatter.idr(income) : '-')),
                    DataCell(Text(!isIn ? Formatter.idr(expense) : '-')),
                    DataCell(Text(Formatter.idr(saldoBerjalan))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
