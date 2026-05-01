import 'package:flutter/material.dart';

// WAJIB ADA: Pintu masuk aplikasi
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
        colorSchemeSeed: const Color(0xFFEAB308),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFEAB308),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Catatan'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tugas'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const NoteEditorPage())
          );
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Color(0xFFEAB308), size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Catatan", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()))
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Cari catatan...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFECEEF0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildNoteCard("Rencana Hari Ini", "12/27/2025"),
                  _buildNoteCard("Ide Projek Flutter", "12/27/2025", hasImage: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(String title, String date, {bool hasImage = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (hasImage) const Expanded(child: Center(child: Icon(Icons.image, color: Colors.amber, size: 50))),
          const Spacer(),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Tugas", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.circle_outlined), title: Text("Selesaikan tugas koding")),
          ListTile(leading: Icon(Icons.circle_outlined), title: Text("Update GitHub")),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.person_outline), title: Text("Profil")),
          ListTile(leading: Icon(Icons.dark_mode_outlined), title: Text("Mode Gelap")),
          ListTile(leading: Icon(Icons.info_outline), title: Text("Tentang Aplikasi")),
        ],
      ),
    );
  }
}

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFEAB308)), 
            onPressed: () => Navigator.pop(context)
          )
        ]
      ),
      body: Padding( // Hapus 'const' di sini agar TextField tidak eror
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(hintText: "Judul", border: InputBorder.none), 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const Divider(),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(hintText: "Mulai menulis...", border: InputBorder.none), 
                maxLines: null,
                style: const TextStyle(fontSize: 18),
              )
            ),
          ],
        ),
      ),
    );
  }
}