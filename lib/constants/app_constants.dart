import 'package:flutter/material.dart';

// Collection constants
class AppStrings {
  static const String appTitle = 'Song Collection App';
  static const String lpmiCollection = 'Lagu Pujian Masa Ini';
  static const String srdCollection = 'Syair Rindu Dendam';
  static const String searchHint = 'Search songs...';
  static const String sortByNumber = 'Number';
  static const String sortByTitle = 'Title';
  static const String noSongsFound = 'No songs found matching your search';
  static const String noFavoritesYet = 'You have no favorite songs yet';
  static const String noSongsAvailable = 'No songs available in this collection';
  static const String retry = 'Retry';
  static const String clearSearch = 'Clear Search';
  static const String error = 'Error';
}

// Dimensions
class AppDimensions {
  static const double minFontSize = 12.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 16.0;
  static const double headerHeight = 180.0;
  static const double playerHeight = 80.0;
}

// List style enum for settings
enum ListStyle {
  list,
  grid,
  grouped,
  swipe,
  compact;

  String get displayName {
    switch (this) {
      case ListStyle.list:
        return 'Standard List';
      case ListStyle.grid:
        return 'Grid View';
      case ListStyle.grouped:
        return 'Grouped List';
      case ListStyle.swipe:
        return 'Swipeable List';
      case ListStyle.compact:
        return 'Compact List';
    }
  }

  IconData get icon {
    switch (this) {
      case ListStyle.list:
        return Icons.view_list;
      case ListStyle.grid:
        return Icons.grid_view;
      case ListStyle.grouped:
        return Icons.view_agenda;
      case ListStyle.swipe:
        return Icons.swipe;
      case ListStyle.compact:
        return Icons.view_headline;
    }
  }
}

// Extension for ListStyle
extension ListStyleExtension on ListStyle {
  static ListStyle fromString(String? name) {
    switch (name) {
      case 'grid':
        return ListStyle.grid;
      case 'grouped':
        return ListStyle.grouped;
      case 'swipe':
        return ListStyle.swipe;
      case 'compact':
        return ListStyle.compact;
      case 'list':
      default:
        return ListStyle.list;
    }
  }
}

// Player mode enum for settings
enum PlayerMode {
  miniPlayer,
  fullscreenPlayer;
  
  String get displayName {
    switch (this) {
      case PlayerMode.miniPlayer:
        return 'Mini Player';
      case PlayerMode.fullscreenPlayer:
        return 'Full Screen Player';
    }
  }
  
  IconData get icon {
    switch (this) {
      case PlayerMode.miniPlayer:
        return Icons.music_note;
      case PlayerMode.fullscreenPlayer:
        return Icons.queue_music;
    }
  }
}

// Extension for PlayerMode
extension PlayerModeExtension on PlayerMode {
  static PlayerMode fromString(String? name) {
    if (name == 'fullscreenPlayer') {
      return PlayerMode.fullscreenPlayer;
    }
    return PlayerMode.miniPlayer; // Default
  }
}