// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  // Add these parameters to match what's being passed from song_list_screen.dart
  final Function(String) onFontChange;
  final Function(double) onFontSizeChange;
  final Function(bool) onThemeChange;
  final double fontSize;
  final bool isDarkTheme;

  const SettingsScreen({
    super.key,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.onThemeChange,
    required this.fontSize,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Access the settings provider
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // Theme Setting
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Enable dark color scheme'),
            value: settingsProvider.isDarkTheme,
            onChanged: (value) {
              // Use both the provider and backward compatibility
              settingsProvider.setIsDarkTheme(value);
              onThemeChange(value);
            },
            secondary: Icon(
              settingsProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              color:
                  settingsProvider.isDarkTheme ? Colors.amber : Colors.blueGrey,
            ),
          ),
          const Divider(),

          // List Style Setting
          _buildSectionHeader(context, 'List Style'),

          // Build a card for each list style option
          ...ListStyle.values.map((style) => _buildListStyleCard(
                context,
                style,
                settingsProvider.listStyle == style,
                () => settingsProvider.setListStyle(style),
              )),

          const Divider(),

          // Player Mode Setting - If your app uses PlayerMode enum
          if (PlayerMode.values.isNotEmpty) ...[
            _buildSectionHeader(context, 'Music Player'),

            // Build a card for each player mode option
            ...PlayerMode.values.map((mode) => _buildPlayerModeCard(
                  context,
                  mode,
                  settingsProvider.playerMode == mode,
                  () => settingsProvider.setPlayerMode(mode),
                )),

            const Divider(),
          ],

          // Font Settings
          _buildSectionHeader(context, 'Text Settings'),

          // Font Size Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.format_size, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Font Size',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: settingsProvider.fontSize,
                        min: AppDimensions.minFontSize,
                        max: AppDimensions.maxFontSize,
                        divisions: 14,
                        label: settingsProvider.fontSize.round().toString(),
                        onChanged: (value) {
                          // Use both the provider and backward compatibility
                          settingsProvider.setFontSize(value);
                          onFontSizeChange(value);
                        },
                      ),
                    ],
                  ),
                ),
                Text(
                  settingsProvider.fontSize.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(),

          // Font Family
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.font_download, color: Colors.blue),
                SizedBox(width: 16),
                Text('Font Family',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Font options
          ...['Montserrat', 'Roboto', 'Lato', 'Open Sans', 'Raleway'].map(
            (font) => RadioListTile<String>(
              title: Text(font, style: TextStyle(fontFamily: font)),
              value: font,
              groupValue: settingsProvider.fontFamily,
              onChanged: (value) {
                if (value != null) {
                  // Use both the provider and backward compatibility
                  settingsProvider.setFontFamily(value);
                  onFontChange(value);
                }
              },
            ),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blue),
            title: Text('App Version'),
            subtitle: Text('1.5.0'),
          ),
          const ListTile(
            leading: Icon(Icons.copyright, color: Colors.blue),
            title: Text('© 2025 HAWEEINC'),
            subtitle: Text('All rights reserved'),
          ),
        ],
      ),
    );
  }

  Widget _buildListStyleCard(BuildContext context, ListStyle style,
      bool isSelected, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2.0,
        ),
      ),
      elevation: isSelected ? 4.0 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                style.icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? Colors.blue : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getListStyleDescription(style),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  // For PlayerMode if your app uses it
  Widget _buildPlayerModeCard(BuildContext context, PlayerMode mode,
      bool isSelected, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2.0,
        ),
      ),
      elevation: isSelected ? 4.0 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                mode.icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? Colors.blue : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPlayerModeDescription(mode),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  String _getListStyleDescription(ListStyle style) {
    switch (style) {
      case ListStyle.list:
        return 'Simple list view with song details';
      case ListStyle.grid:
        return 'Grid layout with cards for each song';
      case ListStyle.grouped:
        return 'List grouped by alphabet or number ranges';
      case ListStyle.swipe:
        return 'Swipe left/right for quick actions';
      case ListStyle.compact:
        return 'Compact view to see more songs at once';
    }
  }

  // Description for player modes if your app uses PlayerMode
  String _getPlayerModeDescription(PlayerMode mode) {
    switch (mode) {
      case PlayerMode.miniPlayer:
        return 'Show a compact player at the bottom of the screen';
      case PlayerMode.fullscreenPlayer:
        return 'Open a dedicated full-screen music player';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
