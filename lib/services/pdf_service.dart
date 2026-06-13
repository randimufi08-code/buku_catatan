import 'dart:typed_data';
import 'dart:io'; // For File and Directory
import 'package:flutter/foundation.dart' show kIsWeb; // For kIsWeb
import 'package:universal_html/html.dart' as web_html; // For web download

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Import pdf widgets
import 'package:path_provider/path_provider.dart' as path_provider; // For getting directories
import 'package:open_filex/open_filex.dart'; // For opening files on non-web

import '../models/transaction_model.dart';
import '../utils/formatter.dart';

class PdfService {
  static Future<void> saveReportPdf({required List<TransactionModel> rows, required DateTime date}) async {
    if (rows.isEmpty) return;

    final doc = pw.Document();

    final title = 'LAPORAN KEUANGAN';
    final ymd = Formatter.dateYmd(date); // Gunakan Formatter untuk tanggal

    final filename = 'laporan_keuangan_$ymd.pdf';
    num totalMasuk = rows.where((e) => e.type == 'Pemasukan').fold(0, (a, b) => a + b.amount);
    num totalKeluar = rows.where((e) => e.type == 'Pengeluaran').fold(0, (a, b) => a + b.amount);
    num saldoAkhir = totalMasuk - totalKeluar;

    // Bangun baris tabel
    final List<pw.TableRow> tableRows = [];

    // Baris Header
    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromHex('1976D2')),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tanggal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Keterangan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pemasukan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pengeluaran', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Saldo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
        ],
      ),
    );

    // Baris Data
    num saldoBerjalan = 0;
    for (var e in rows) {
      final isMasuk = e.type == 'Pemasukan';
      final amount = e.amount;
      saldoBerjalan += (isMasuk ? amount : -amount);

      tableRows.add(
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(Formatter.dateYmd(e.date), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e.description, style: const pw.TextStyle(fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(isMasuk ? Formatter.idr(amount) : '-', style: pw.TextStyle(fontSize: 10, color: PdfColors.green), textAlign: pw.TextAlign.right)),
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(!isMasuk ? Formatter.idr(amount) : '-', style: pw.TextStyle(fontSize: 10, color: PdfColors.red), textAlign: pw.TextAlign.right)),
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(Formatter.idr(saldoBerjalan), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          ],
        ),
      );
    }

    // Baris Footer untuk Total
    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.SizedBox(), // Kolom Tanggal (Kosong)
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(Formatter.idr(totalMasuk), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green), textAlign: pw.TextAlign.right)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(Formatter.idr(totalKeluar), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red), textAlign: pw.TextAlign.right)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(Formatter.idr(saldoAkhir), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1976D2')), textAlign: pw.TextAlign.right)),
        ],
      ),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('1976D2'),
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Tanggal: $ymd', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5), // Tanggal
                  1: const pw.FlexColumnWidth(3),   // Keterangan
                  2: const pw.FlexColumnWidth(2),   // Pemasukan
                  3: const pw.FlexColumnWidth(2),   // Pengeluaran
                  4: const pw.FlexColumnWidth(2),   // Saldo
                },
                children: tableRows,
              ),
            ],
          );
        },
      ),
    );

    final Uint8List pdfBytes = await doc.save();

    if (kIsWeb) {
      // For web, trigger a direct download using universal_html
      final blob = web_html.Blob([pdfBytes], 'application/pdf');
      final url = web_html.Url.createObjectUrlFromBlob(blob);
      final anchor = web_html.AnchorElement(href: url)
        ..setAttribute("download", filename);
      web_html.document.body?.append(anchor); // Temporarily add to DOM to ensure click works
      anchor.click();
      anchor.remove(); // Remove after click
      web_html.Url.revokeObjectUrl(url);
    } else {
      // For non-web platforms (mobile, desktop)
      final directory = await _getAppropriateDirectory();
      await directory.create(recursive: true); // Ensure directory exists

      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);

      // Optionally, open the file after saving
      try {
        await OpenFilex.open(filePath);
      } catch (e) {
        // Handle error if file cannot be opened
        print('Error opening PDF file: $e');
      }
    }
  }

  // Helper function to get an appropriate directory for saving files
  static Future<Directory> _getAppropriateDirectory() async {
    Directory? directory;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      directory = await path_provider.getDownloadsDirectory();
    }
    // If getDownloadsDirectory is null (e.g., on mobile or if it failed on desktop),
    // or if it's a mobile platform, use application documents directory.
    if (directory == null || Platform.isAndroid || Platform.isIOS) {
      directory = await path_provider.getApplicationDocumentsDirectory();
    }
    return directory; // This should now always return a non-null Directory
  }
}
