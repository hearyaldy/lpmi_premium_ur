import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _fontFamily = 'Montserrat';
  double _fontSize = 16.0;
  bool _isDarkTheme = false;
  ListStyle _listStyle = ListStyle.list; // Default list style
  PlayerMode _playerMode = PlayerMode.miniPlayer; // Default player mode

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get isDarkTheme => _isDarkTheme;
  ListStyle get listStyle => _listStyle;
  PlayerMode get playerMode => _playerMode;

  // Load settings with Firebase support
  Future<void> loadSettings() async {
    try {
      // Try to load from Firebase if user is signed in
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId != null) {
        final settingsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('app_settings')
            .get();
            
        if (settingsDoc.exists && settingsDoc.data() != null) {
          final data = settingsDoc.data()!;
          _fontFamily = data['fontFamily'] ?? 'Montserrat';
          _fontSize = (data['fontSize'] as num?)?.toDouble() ?? 16.0;
          _isDarkTheme = data['isDarkTheme'] ?? false;
          _listStyle = ListStyleExtension.fromString(data['listStyle'] as String?);
          _playerMode = PlayerModeExtension.fromString(data['playerMode'] as String?);
          
          // Save to SharedPreferences as well for offline access
          await _saveToSharedPreferences();
          notifyListeners();
          return;
        }
      }
      
      // Fall back to shared preferences if Firebase data isn't available
      await _loadFromSharedPreferences();
      
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Fallback to shared preferences
      await _loadFromSharedPreferences();
    }
  }
  
  // Extract shared preferences loading to a separate method
  Future<void> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _fontFamily = prefs.getString('fontFamily') ?? 'Montserrat';
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _listStyle = ListStyleExtension.fromString(prefs.getString('listStyle'));
      _playerMode = PlayerModeExtension.fromString(prefs.getString('playerMode'));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings from SharedPreferences: $e');
    }
  }
  
  // Save settings to both Firebase and SharedPreferences
  Future<void> _saveSettings() async {
    try {
      // Save to shared preferences
      await _saveToSharedPreferences();
      
      // Save to Firebase if logged in
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('app_settings')
            .set({
              'fontFamily': _fontFamily,
              'fontSize': _fontSize,
              'isDarkTheme': _isDarkTheme,
              'listStyle': _listStyle.name,
              'playerMode': _playerMode.name,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
  
  // Extract shared preferences saving to a separate method
  Future<void> _saveToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('fontFamily', _fontFamily);
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setBool('isDarkTheme', _isDarkTheme);
      await prefs.setString('listStyle', _listStyle.name);
      await prefs.setString('playerMode', _playerMode.name);
    } catch (e) {
      debugPrint('Error saving settings to SharedPreferences: $e');
    }
  }

  // Update font family
  Future<void> setFontFamily(String fontFamily) async {
    if (_fontFamily != fontFamily) {
      _fontFamily = fontFamily;
      await _saveSettings();
      notifyListeners();
    }
  }

  // Update font size
  Future<void> setFontSize(double fontSize) async {
    if (_fontSize != fontSize) {
      _fontSize = fontSize;
      await _saveSettings();
      notifyListeners();
    }
  }

  // Update theme
  Future<void> setIsDarkTheme(bool isDarkTheme) async {
    if (_isDarkTheme != isDarkTheme) {
      _isDarkTheme = isDarkTheme;
      await _saveSettings();
      notifyListeners();
    }
  }
  
  // Update list style
  Future<void> setListStyle(ListStyle listStyle) async {
    if (_listStyle != listStyle) {
      _listStyle = listStyle;
      await _saveSettings();
      notifyListeners();
    }
  }
  
  // Update player mode
  Future<void> setPlayerMode(PlayerMode playerMode) async {
    if (_playerMode != playerMode) {
      _playerMode = playerMode;
      await _saveSettings();
      notifyListeners();
    }
  }
}