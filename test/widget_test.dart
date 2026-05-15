import 'package:flutter_test/flutter_test.dart';
import 'package:buku_catatan/main.dart'; // Pastikan nama package sesuai

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Bangun aplikasi kita dan pemicu frame.
    await tester.pumpWidget(const BukuCatatanApp()); // Gunakan nama kelas yang baru

    // Verifikasi bahwa tampilan awal sudah benar
    expect(find.text('Catatan'), findsOneWidget);
  });
}