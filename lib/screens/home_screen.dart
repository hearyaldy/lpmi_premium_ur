// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Define your actual widget options here
  final List<Widget> _widgetOptions = [
    const Center(child: Text('Home Tab Content')),
    const Center(child: Text('Profile Tab Content')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Get the necessary providers
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              final settingsProvider =
                  Provider.of<SettingsProvider>(context, listen: false);

              // Navigate to settings screen with all required parameters
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onFontChange: (String font) {
                      // You may need to adjust this based on your SettingsProvider implementation
                      // This is a placeholder that assumes your SettingsProvider has a method that takes a String
                      settingsProvider.setFontFamily(font);
                    },
                    onFontSizeChange: (double size) {
                      // Handle font size change
                      settingsProvider.setFontSize(size);
                    },
                    onThemeChange: (bool isDark) {
                      // Use the setDarkMode method from your ThemeProvider
                      themeProvider.setDarkMode(isDark);
                    },
                    fontSize: settingsProvider.fontSize,
                    isDarkTheme: themeProvider.isDarkMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
