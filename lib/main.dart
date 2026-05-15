import 'package:flutter/material.dart';

// Notifier untuk memantau status Mode Gelap secara global
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const BukuCatatanApp());
}

class BukuCatatanApp extends StatelessWidget {
  const BukuCatatanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Buku Catatan',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF1976D2),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: const MainNavigation(),
        );
      },
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteEditorPage()));
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  // Data dummy aplikasi
  final List<Map<String, dynamic>> _allNotes = [
    {"title": "Belanja Mingguan", "color": Colors.white},
    {"title": "Catatan Kerja: Meeting 10.00(Zoom)", "color": const Color(0xFFFFE4FF)},
    {"title": "Ide Konten", "color": const Color(0xFFFFFDCC)},
    {"title": "Kuliah", "color": const Color(0xFFE2FFE2)},
    {"title": "Journal Harian", "color": const Color(0xFFE2F3FF)},
    {"title": "Agenda Hari Ini", "color": const Color(0xFFF2E2FF)},
  ];

  List<Map<String, dynamic>> _foundNotes = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _foundNotes = List.from(_allNotes);
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allNotes;
    } else {
      results = _allNotes
          .where((note) => note["title"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundNotes = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : const Color(0xFF1976D2),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Cari catatan...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => _runFilter(value),
              )
            : const Text("Catatan", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _foundNotes = _allNotes;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'dark_mode') {
                themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dark_mode',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Mode Gelap"),
                    Icon(
                      themeNotifier.value == ThemeMode.dark ? Icons.toggle_on : Icons.toggle_off,
                      color: themeNotifier.value == ThemeMode.dark ? Colors.blue : Colors.grey,
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(value: 'backup', child: Text("Cadangkan / Pulihkan")),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _foundNotes.length,
        itemBuilder: (context, index) {
          final note = _foundNotes[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              final removedNote = note;
              final originalIndex = _allNotes.indexOf(note);
              setState(() {
                _allNotes.removeAt(originalIndex);
                _foundNotes = List.from(_allNotes);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${removedNote['title']} dihapus"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () => setState(() {
                      _allNotes.insert(originalIndex, removedNote);
                      _foundNotes = List.from(_allNotes);
                    }),
                  ),
                ),
              );
            },
            child: _buildColorNote(note['title'], isDarkMode ? Colors.grey[850]! : note['color']),
          );
        },
      ),
    );
  }

  Widget _buildColorNote(String title, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Icon(Icons.menu, color: Colors.grey.shade400, size: 20),
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? null : const Color(0xFF1976D2),
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
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Judul", border: InputBorder.none),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: "Tulis sesuatu...", border: InputBorder.none),
                maxLines: null,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}