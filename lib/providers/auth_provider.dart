import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const _loggedInKey = 'isLoggedIn';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';
  static const _userProfilePicKey = 'userProfilePic';

  bool _isLoggedIn = false;
  String _userName = 'Guest';
  String _userEmail = 'guest@example.com';
  String? _userProfilePic; // Path to profile picture

  AuthProvider() {
    _loadAuthStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userProfilePic => _userProfilePic;

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    _userName = prefs.getString(_userNameKey) ?? 'Guest';
    _userEmail = prefs.getString(_userEmailKey) ?? 'guest@example.com';
    _userProfilePic = prefs.getString(_userProfilePicKey);
    notifyListeners();
  }

  Future<void> login(String name, String email) async {
    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = 'Guest';
    _userEmail = 'guest@example.com';
    _userProfilePic = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userProfilePicKey);
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email, String? profilePicPath}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _userName = name;
      await prefs.setString(_userNameKey, name);
    }
    if (email != null) {
      _userEmail = email;
      await prefs.setString(_userEmailKey, email);
    }
    if (profilePicPath != null) {
      _userProfilePic = profilePicPath;
      await prefs.setString(_userProfilePicKey, profilePicPath);
    }
    notifyListeners();
  }
}