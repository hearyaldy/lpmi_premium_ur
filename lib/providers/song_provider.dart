import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';
import '../constants/app_constants.dart';

class SongProvider extends ChangeNotifier {
  // Data collections
  List<UnifiedSong> _lpmiSongs = [];
  List<UnifiedSong> _srdSongs = [];
  List<UnifiedSong> _filteredSongs = [];
  final List<UnifiedSong> _favoriteSongs = [];

  // Current state
  String _currentCollection = AppStrings.lpmiCollection;
  String _sortOption = AppStrings.sortByNumber;
  String _searchQuery = '';
  bool _isLoading = true;

  // Audio player service
  late AudioPlayerService _audioPlayerService;
  String? _playingSongNumber;
  bool _isShowingFullPlayer = false;

  // Audio player state
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLooping = false;

  // Getters
  List<UnifiedSong> get lpmiSongs => _lpmiSongs;
  List<UnifiedSong> get srdSongs => _srdSongs;
  List<UnifiedSong> get filteredSongs => _filteredSongs;
  List<UnifiedSong> get favoriteSongs => _favoriteSongs;

  String get currentCollection => _currentCollection;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  AudioPlayerService get audioPlayerService => _audioPlayerService;
  String? get playingSongNumber => _playingSongNumber;
  bool get isShowingFullPlayer => _isShowingFullPlayer;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  bool get isLooping => _isLooping;

  // SharedPreferences keys
  static const String _favoritesKey = 'favorites';

  // Initialize and load songs
  Future<void> loadSongsAndFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load songs from JSON files
      await _loadLPMISongs();
      await _loadSRDSongs();

      // Load favorites from SharedPreferences
      await _loadFavorites();

      // Apply current sorting and filtering
      _applySortingAndFiltering();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Initialize audio player
  Future<void> initializeAudioPlayer() async {
    _audioPlayerService = AudioPlayerService();

    // Set up position listener
    _audioPlayerService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Set up duration listener
    _audioPlayerService.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    // Set up playback state listener
    _audioPlayerService.playbackStateStream.listen((isPlaying) {
      _isPlaying = isPlaying;
      notifyListeners();
    });
  }

  // Load LPMI songs from assets
  Future<void> _loadLPMISongs() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/lpmi.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    _lpmiSongs = jsonData.map((json) => UnifiedSong.fromJson(json)).toList();
  }

  // Load SRD songs from assets
  Future<void> _loadSRDSongs() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/srd.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    _srdSongs = jsonData.map((json) => UnifiedSong.fromJson(json)).toList();
  }

  // Load favorite songs from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = prefs.getStringList(_favoritesKey) ?? [];

    // Clear current favorites
    _favoriteSongs.clear();

    // Add songs from both collections that match favorite IDs
    for (String id in favoriteIds) {
      // Look in LPMI collection
      final lpmiMatch = _lpmiSongs
          .where(
              (song) => "${song.songNumber}_${AppStrings.lpmiCollection}" == id)
          .toList();
      if (lpmiMatch.isNotEmpty) {
        _favoriteSongs.add(lpmiMatch.first);
      }

      // Look in SRD collection
      final srdMatch = _srdSongs
          .where(
              (song) => "${song.songNumber}_${AppStrings.srdCollection}" == id)
          .toList();
      if (srdMatch.isNotEmpty) {
        _favoriteSongs.add(srdMatch.first);
      }
    }
  }

  // Apply current sorting and filtering to the filtered songs list
  void _applySortingAndFiltering() {
    // Get songs from current collection
    List<UnifiedSong> collectionSongs =
        _currentCollection == AppStrings.lpmiCollection
            ? _lpmiSongs
            : _srdSongs;

    // Apply search filter if query is not empty
    if (_searchQuery.isEmpty) {
      _filteredSongs = List.from(collectionSongs);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredSongs = collectionSongs.where((song) {
        return song.songTitle.toLowerCase().contains(query) ||
            song.songNumber.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    _applySorting();
  }

  // Apply sorting to filtered songs
  void _applySorting() {
    if (_sortOption == AppStrings.sortByNumber) {
      // Sort by song number
      _filteredSongs.sort((a, b) {
        // Extract numeric part if possible
        int? numA =
            int.tryParse(a.songNumber.replaceAll(RegExp(r'[^0-9]'), ''));
        int? numB =
            int.tryParse(b.songNumber.replaceAll(RegExp(r'[^0-9]'), ''));

        if (numA != null && numB != null) {
          return numA.compareTo(numB);
        }
        return a.songNumber.compareTo(b.songNumber);
      });
    } else {
      // Sort by song title
      _filteredSongs.sort((a, b) => a.songTitle.compareTo(b.songTitle));
    }
  }

  // Set current collection
  void setCurrentCollection(String collection) {
    if (_currentCollection != collection) {
      _currentCollection = collection;
      _applySortingAndFiltering();
      notifyListeners();
    }
  }

  // Toggle sort option between number and title
  void toggleSortOption() {
    _sortOption = _sortOption == AppStrings.sortByNumber
        ? AppStrings.sortByTitle
        : AppStrings.sortByNumber;
    _applySorting();
    notifyListeners();
  }

  // Filter songs based on search query
  void filterSongs(String query) {
    _searchQuery = query;
    _applySortingAndFiltering();
    notifyListeners();
  }

  // Toggle favorite status for a song
  Future<void> toggleFavorite(UnifiedSong song) async {
    // Check if song is already favorited
    final bool isFavorite = _favoriteSongs.contains(song);

    if (isFavorite) {
      // Remove from favorites
      _favoriteSongs.removeWhere((s) =>
          s.songNumber == song.songNumber &&
          ((_currentCollection == AppStrings.lpmiCollection &&
                  _lpmiSongs.contains(s)) ||
              (_currentCollection == AppStrings.srdCollection &&
                  _srdSongs.contains(s))));
    } else {
      // Add to favorites
      _favoriteSongs.add(song);
    }

    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = _favoriteSongs.map((s) {
      final collection = _lpmiSongs.contains(s)
          ? AppStrings.lpmiCollection
          : AppStrings.srdCollection;
      return "${s.songNumber}_$collection";
    }).toList();

    await prefs.setStringList(_favoritesKey, favoriteIds);
    notifyListeners();
  }

  // Play or pause a song
  Future<void> playOrPauseSong(UnifiedSong song) async {
    if (_playingSongNumber == song.songNumber && _isPlaying) {
      // Pause currently playing song
      await _audioPlayerService
          .pause(); // Keep await since it returns Future<void>
      _isPlaying = false; // Set state directly
    } else if (_playingSongNumber == song.songNumber && !_isPlaying) {
      // Resume paused song
      await _audioPlayerService
          .resume(); // Keep await since it returns Future<void>
      _isPlaying = true; // Set state directly
    } else {
      // Play new song
      final String songUrl = song.url ?? '';
      if (songUrl.isNotEmpty) {
        await _audioPlayerService.playOrPause(
            songUrl, song.songTitle); // Keep await
        _playingSongNumber = song.songNumber;
        _isPlaying = true; // Set state directly
      }
    }

    notifyListeners();
  }

  // Get the currently playing song
  UnifiedSong? getCurrentPlayingSong() {
    if (_playingSongNumber == null) return null;

    // Look in current collection first
    List<UnifiedSong> currentSongs =
        _currentCollection == AppStrings.lpmiCollection
            ? _lpmiSongs
            : _srdSongs;

    for (var song in currentSongs) {
      if (song.songNumber == _playingSongNumber) return song;
    }

    // If not found, look in the other collection
    List<UnifiedSong> otherSongs =
        _currentCollection == AppStrings.lpmiCollection
            ? _srdSongs
            : _lpmiSongs;

    for (var song in otherSongs) {
      if (song.songNumber == _playingSongNumber) return song;
    }

    return null;
  }

  // Stop the currently playing song
  Future<void> stopSong() async {
    await _audioPlayerService
        .stop(); // Keep await since it returns Future<void>
    _playingSongNumber = null;
    _isPlaying = false; // Explicitly set playing status to false
    notifyListeners();
  }

  // Seek to a specific position
  Future<void> seekTo(Duration position) async {
    _audioPlayerService
        .seek(position); // This doesn't need await as it's not a Future
  }

  // Seek relative to current position
  Future<void> seekRelative(Duration offset) async {
    final newPosition = _currentPosition + offset;
    _audioPlayerService
        .seek(newPosition); // This doesn't need await as it's not a Future
  }

  // Toggle loop mode
  void toggleLoopMode() {
    _audioPlayerService.setLoopMode(!_isLooping);
    _isLooping = !_isLooping;
    notifyListeners();
  }

  // Show full player screen
  void showFullPlayer() {
    _isShowingFullPlayer = true;
    notifyListeners();
  }

  // Hide full player screen
  void hideFullPlayer() {
    _isShowingFullPlayer = false;
    notifyListeners();
  }
}
