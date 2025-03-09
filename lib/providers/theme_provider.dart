// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme {
  blue,
  green,
  purple,
  orange,
  red,
}

enum FontFamily {
  roboto,
  openSans,
  lato,
  montserrat,
  poppins,
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  AppTheme _currentTheme = AppTheme.blue;
  FontFamily _fontFamily = FontFamily.roboto;
  double _fontSize = 1.0; // Multiplier for text sizes

  // Getters
  bool get isDarkMode => _isDarkMode;
  AppTheme get currentTheme => _currentTheme;
  FontFamily get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  ThemeData get themeData => _buildThemeData();

  // Constructor
  ThemeProvider() {
    _loadPreferences();
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _currentTheme = AppTheme.values[prefs.getInt('themeIndex') ?? 0];
      _fontFamily = FontFamily.values[prefs.getInt('fontFamilyIndex') ?? 0];
      _fontSize = prefs.getDouble('fontSize') ?? 1.0;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading theme preferences: $e");
    }
  }

  // Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setInt('themeIndex', _currentTheme.index);
      await prefs.setInt('fontFamilyIndex', _fontFamily.index);
      await prefs.setDouble('fontSize', _fontSize);
    } catch (e) {
      debugPrint("Error saving theme preferences: $e");
    }
  }

  // Set dark mode
  void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  // Set theme color
  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    _savePreferences();
    notifyListeners();
  }

  // Set font family
  void setFontFamily(FontFamily fontFamily) {
    _fontFamily = fontFamily;
    _savePreferences();
    notifyListeners();
  }

  // Set font size
  void setFontSize(double fontSize) {
    _fontSize = fontSize;
    _savePreferences();
    notifyListeners();
  }

  // Get the primary color for the current theme
  Color get primaryColor {
    switch (_currentTheme) {
      case AppTheme.blue:
        return Colors.blue;
      case AppTheme.green:
        return Colors.green;
      case AppTheme.purple:
        return Colors.purple;
      case AppTheme.orange:
        return Colors.orange;
      case AppTheme.red:
        return Colors.red;
    }
  }

  // Get the font family
  String get fontFamilyName {
    switch (_fontFamily) {
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.lato:
        return 'Lato';
      case FontFamily.montserrat:
        return 'Montserrat';
      case FontFamily.poppins:
        return 'Poppins';
    }
  }

  // Build the theme data
  ThemeData _buildThemeData() {
    // Get the base theme
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;
    
    // Create base theme to inherit from
    final baseTheme = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    
    // Get the correct TextTheme using Google Fonts
    TextTheme textTheme;
    
    switch (_fontFamily) {
      case FontFamily.roboto:
        textTheme = GoogleFonts.robotoTextTheme(baseTheme.textTheme);
        break;
      case FontFamily.openSans:
        textTheme = GoogleFonts.openSansTextTheme(baseTheme.textTheme);
        break;
      case FontFamily.lato:
        textTheme = GoogleFonts.latoTextTheme(baseTheme.textTheme);
        break;
      case FontFamily.montserrat:
        textTheme = GoogleFonts.montserratTextTheme(baseTheme.textTheme);
        break;
      case FontFamily.poppins:
        textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme);
        break;
    }
    
    // Apply font size multiplier
    textTheme = textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontSize: 96 * _fontSize),
      displayMedium: textTheme.displayMedium?.copyWith(fontSize: 60 * _fontSize),
      displaySmall: textTheme.displaySmall?.copyWith(fontSize: 48 * _fontSize),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontSize: 40 * _fontSize),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontSize: 34 * _fontSize),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: 24 * _fontSize),
      titleLarge: textTheme.titleLarge?.copyWith(fontSize: 20 * _fontSize),
      titleMedium: textTheme.titleMedium?.copyWith(fontSize: 16 * _fontSize),
      titleSmall: textTheme.titleSmall?.copyWith(fontSize: 14 * _fontSize),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16 * _fontSize),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14 * _fontSize),
      bodySmall: textTheme.bodySmall?.copyWith(fontSize: 12 * _fontSize),
      labelLarge: textTheme.labelLarge?.copyWith(fontSize: 14 * _fontSize),
      labelMedium: textTheme.labelMedium?.copyWith(fontSize: 12 * _fontSize),
      labelSmall: textTheme.labelSmall?.copyWith(fontSize: 10 * _fontSize),
    );
    
    // Define card and dialog colors for dark mode
    final cardColor = brightness == Brightness.dark 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
    
    final dialogBackgroundColor = brightness == Brightness.dark 
        ? const Color(0xFF2D2D2D) 
        : Colors.white;
    
    // Build the theme
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: brightness == Brightness.light 
          ? Colors.white 
          : const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light 
            ? primaryColor 
            : const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: dialogBackgroundColor,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
      ),
      dividerTheme: DividerThemeData(
        color: brightness == Brightness.dark 
            ? Colors.white24 
            : Colors.black12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // Ensure label and hint text are visible in both modes
        labelStyle: TextStyle(
          color: brightness == Brightness.dark 
              ? Colors.white70 
              : Colors.black54,
        ),
        hintStyle: TextStyle(
          color: brightness == Brightness.dark 
              ? Colors.white38 
              : Colors.black38,
        ),
        // Filled text fields in dark mode
        fillColor: brightness == Brightness.dark 
            ? Colors.white10 
            : Colors.black.withOpacity(0.03),
      ),
    );
  }
}