import 'package:flutter/material.dart';

void main() {
  runApp(const BukuCatatanApp());
}

class BukuCatatanApp extends StatelessWidget {
  const BukuCatatanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Catatan',
      theme: ThemeData(
        useMaterial3: true,
        // Menggunakan warna biru utama sesuai gambar referensi
        primaryColor: const Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NoteListPage(),
    const ToDoListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1976D2),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Catatan'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tugas'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorPage()),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text("Catatan", style: TextStyle(color: Colors.white)),
        actions: [
          const Icon(Icons.more_vert, color: Colors.white),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildColorNote("Belanja Mingguan", Colors.white),
          _buildColorNote("Catatan Kerja: Meeting 10.00 (Zoom)", const Color(0xFFFFE4FF)),
          _buildColorNote("Ide Konten", const Color(0xFFFFFDCC)),
          _buildColorNote("Kuliah", const Color(0xFFE2FFE2)),
          _buildColorNote("Journal Harian", const Color(0xFFE2F3FF)),
          _buildColorNote("Agenda Hari Ini", const Color(0xFFF2E2FF)),
        ],
      ),
    );
  }

  // Widget kartu catatan dengan warna latar belakang dinamis sesuai gambar
  Widget _buildColorNote(String title, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Icon(Icons.menu, color: Colors.grey.shade400, size: 20), // Ikon garis dua di kanan
        ],
      ),
    );
  }
}

class ToDoListPage extends StatelessWidget {
  const ToDoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text("Tugas", style: TextStyle(color: Colors.white)),
      ),
      body: const Center(child: Text("Halaman Tugas")),
    );
  }
}

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Catatan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(hintText: "Judul", border: InputBorder.none),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(hintText: "Tulis sesuatu...", border: InputBorder.none),
                maxLines: null,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}