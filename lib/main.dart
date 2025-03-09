import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/song_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/playlist_provider.dart';
import 'screens/song_list_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initializeFirebase();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create providers
  final SettingsProvider _settingsProvider = SettingsProvider();
  final SongProvider _songProvider = SongProvider();
  final AuthProvider _authProvider = AuthProvider();
  final PlaylistProvider _playlistProvider = PlaylistProvider();

  @override
  void initState() {
    super.initState();
    // Initialize settings
    _settingsProvider.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _settingsProvider),
        ChangeNotifierProvider.value(value: _songProvider),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _playlistProvider),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, _) {
          return MaterialApp(
            title: 'Song Collection App',
            theme: ThemeData(
              brightness: settingsProvider.isDarkTheme ? Brightness.dark : Brightness.light,
              fontFamily: settingsProvider.fontFamily,
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: settingsProvider.fontFamily,
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            themeMode: settingsProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: authProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : authProvider.isAuthenticated
                    ? SongListScreen(
                        fontSize: settingsProvider.fontSize,
                        fontFamily: settingsProvider.fontFamily,
                        isDarkTheme: settingsProvider.isDarkTheme,
                        onFontChange: (font) => settingsProvider.setFontFamily(font),
                        onFontSizeChange: (size) => settingsProvider.setFontSize(size),
                        onThemeChange: (dark) => settingsProvider.setIsDarkTheme(dark),
                      )
                    : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => SongListScreen(
                    fontSize: settingsProvider.fontSize,
                    fontFamily: settingsProvider.fontFamily,
                    isDarkTheme: settingsProvider.isDarkTheme,
                    onFontChange: (font) => settingsProvider.setFontFamily(font),
                    onFontSizeChange: (size) => settingsProvider.setFontSize(size),
                    onThemeChange: (dark) => settingsProvider.setIsDarkTheme(dark),
                  ),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}