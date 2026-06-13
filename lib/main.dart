import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {});
    });
    _authProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Keuangan',
      themeMode: _themeProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: DashboardScreen(
        themeProvider: _themeProvider,
        authProvider: _authProvider,
      ),
    );
  }
}
