import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../models/song.dart';
import '../providers/settings_provider.dart';
import '../providers/song_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/player_controls.dart';
import '../widgets/song_tile.dart';
import 'song_detail_screen.dart';
import 'settings_screen.dart';

class SongListScreen extends StatefulWidget {
  // Keep these parameters for backward compatibility
  final String fontFamily;
  final double fontSize;
  final bool isDarkTheme;
  final Function(String) onFontChange;
  final Function(double) onFontSizeChange;
  final Function(bool) onThemeChange;

  const SongListScreen({
    super.key,
    required this.fontFamily,
    required this.fontSize,
    required this.isDarkTheme,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.onThemeChange,
  });

  @override
  SongListScreenState createState() => SongListScreenState();
}

class SongListScreenState extends State<SongListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Helper class for debouncing search
  Timer? _debounceTimer;

  void _debounce(VoidCallback callback,
      {Duration duration = const Duration(milliseconds: 500)}) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style to make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Initialize animation controller for mini player
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _searchController.addListener(_onSearchChanged);

    // Initialize data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // Get song provider
      final songProvider = Provider.of<SongProvider>(context, listen: false);

      // Load songs and favorites
      await songProvider.loadSongsAndFavorites();

      // Initialize audio player
      await songProvider.initializeAudioPlayer();

      // If a song is already playing, show the mini player
      if (songProvider.playingSongNumber != null) {
        _animationController.forward();
      }
    } catch (e) {
      _handleError(e, 'initializing data');
    }
  }

  void _onSearchChanged() {
    _debounce(() {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      songProvider.filterSongs(_searchController.text);
    });
  }

  Future<void> _refreshData() async {
    try {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      await songProvider.loadSongsAndFavorites();
    } catch (e) {
      _handleError(e, 'refreshing data');
    }
  }

  void _handleError(dynamic error, String operation) {
    debugPrint('Error during $operation: $error');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $operation failed. Please try again.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.retry,
          onPressed: () {
            _refreshIndicatorKey.currentState?.show();
          },
        ),
      ),
    );
  }

  void _toggleSort() {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.toggleSortOption();
  }

  void _selectCollection(String collection) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.setCurrentCollection(collection);
  }

  void _navigateToSongDetail(BuildContext context, UnifiedSong song) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongDetailScreen(
          song: song,
          collectionName: songProvider.currentCollection,
          toggleFavorite: (song) => songProvider.toggleFavorite(song),
          isFavorite: songProvider.favoriteSongs.contains(song),
          fontSize: widget.fontSize,
          fontFamily: widget.fontFamily,
          isDarkTheme: widget.isDarkTheme,
          audioPlayerService: songProvider.audioPlayerService,
          verses: song.verses,
        ),
      ),
    );
  }

  void _shareSong(UnifiedSong song) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final collectionName = songProvider.currentCollection;

    final String songLyrics = song.verses
        .map((verse) => "${verse.verseNumber}: ${verse.lyrics}")
        .join("\n");

    final String shareContent =
        "Song: ${song.songTitle}\nCollection: $collectionName\n\nLyrics:\n$songLyrics";

    Share.share(shareContent);
  } // Add this method to show an about dialog

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Song Collection App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 16),
            const Text('Version 1.4.0'),
            const SizedBox(height: 8),
            const Text(
                'A beautiful app to browse and enjoy your favorite song collections.'),
            const SizedBox(height: 16),
            const Text('© 2025 HAWEEINC', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SongProvider songProvider) {
    return Container(
      height: 220, // Increased height to accommodate status bar
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/header_image.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Menu button
          Positioned(
            top: 50, // Positioned below status bar
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          // Collection and date info
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collection name with larger font
                Hero(
                  tag: 'collection-title',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      songProvider.currentCollection,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Current date
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 2.0,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                // View type indicator moved to subtitle position
                const SizedBox(height: 8),
                Text(
                  _currentIndex == 0 ? 'All Songs' : 'Favorites',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        _currentIndex == 0 ? Colors.blue[200] : Colors.red[200],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 24, 16, 16), // Added more top padding
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  hintStyle: TextStyle(
                    color:
                        widget.isDarkTheme ? Colors.grey[400] : Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color:
                        widget.isDarkTheme ? Colors.grey[400] : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: widget.isDarkTheme
                                ? Colors.grey[400]
                                : Colors.black54,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<SongProvider>(context, listen: false)
                                .filterSongs('');
                          },
                        )
                      : null,
                ),
                style: TextStyle(
                  color: widget.isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          // Sort button now inline with search field
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: widget.isDarkTheme ? Colors.grey[800] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Consumer<SongProvider>(
              builder: (context, songProvider, _) {
                return IconButton(
                  icon: Icon(
                    songProvider.sortOption == AppStrings.sortByNumber
                        ? Icons.format_list_numbered
                        : Icons.sort_by_alpha,
                    color: Colors.blue,
                  ),
                  onPressed: _toggleSort,
                  tooltip: 'Toggle Sort',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongListByStyle(SongProvider songProvider,
      SettingsProvider settingsProvider, List<UnifiedSong> displaySongs) {
    if (songProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (displaySongs.isEmpty) {
      return EmptyState(
        icon: _searchController.text.isNotEmpty
            ? Icons.search_off
            : _currentIndex == 1
                ? Icons.favorite_border
                : Icons.music_off,
        message: _searchController.text.isNotEmpty
            ? AppStrings.noSongsFound
            : _currentIndex == 1
                ? AppStrings.noFavoritesYet
                : AppStrings.noSongsAvailable,
        actionLabel:
            _searchController.text.isNotEmpty ? AppStrings.clearSearch : null,
        onAction: _searchController.text.isNotEmpty
            ? () {
                _searchController.clear();
                songProvider.filterSongs('');
              }
            : null,
      );
    }

    // Render the appropriate list style based on the setting
    switch (settingsProvider.listStyle) {
      case ListStyle.grid:
        return _buildSongsGrid(songProvider, displaySongs);
      case ListStyle.grouped:
        return _buildGroupedSongsList(songProvider, displaySongs);
      case ListStyle.swipe:
        return _buildSwiperSongsList(songProvider, displaySongs);
      case ListStyle.compact:
        return _buildCompactSectionedList(songProvider, displaySongs);
      case ListStyle.list:
      default:
        return _buildStandardSongsList(songProvider, displaySongs);
    }
  }

  // 1. Standard List View Implementation
  Widget _buildStandardSongsList(
      SongProvider songProvider, List<UnifiedSong> displaySongs) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displaySongs.length,
        itemBuilder: (context, index) {
          final song = displaySongs[index];
          final isPlaying = songProvider.playingSongNumber == song.songNumber;
          final isFavorite = songProvider.favoriteSongs.contains(song);

          return SongTile(
            song: song,
            fontFamily: widget.fontFamily,
            fontSize: widget.fontSize,
            isPlaying: isPlaying,
            isFavorite: isFavorite,
            onTap: () => _navigateToSongDetail(context, song),
            onPlayPause: () => songProvider.playOrPauseSong(song),
            onToggleFavorite: () => songProvider.toggleFavorite(song),
            canPlay:
                songProvider.currentCollection == AppStrings.lpmiCollection,
          );
        },
      ),
    );
  }

  // 2. Grid Layout Implementation
  Widget _buildSongsGrid(
      SongProvider songProvider, List<UnifiedSong> displaySongs) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: displaySongs.length,
        itemBuilder: (context, index) {
          final song = displaySongs[index];
          final isPlaying = songProvider.playingSongNumber == song.songNumber;
          final isFavorite = songProvider.favoriteSongs.contains(song);

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              onTap: () => _navigateToSongDetail(context, song),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      song.songNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      song.songTitle,
                      style: TextStyle(
                        fontFamily: widget.fontFamily,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (songProvider.currentCollection ==
                          AppStrings.lpmiCollection)
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: isPlaying ? Colors.blue : Colors.grey,
                          ),
                          iconSize: 28,
                          onPressed: () => songProvider.playOrPauseSong(song),
                        ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        iconSize: 28,
                        onPressed: () => songProvider.toggleFavorite(song),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  } // 3. Grouped List Implementation

  Widget _buildGroupedSongsList(
      SongProvider songProvider, List<UnifiedSong> displaySongs) {
    // Group songs by their first letter or number
    Map<String, List<UnifiedSong>> groupedSongs = {};

    if (songProvider.sortOption == AppStrings.sortByNumber) {
      // Group by first digit for numerical sorting
      for (var song in displaySongs) {
        String firstChar = song.songNumber[0];
        if (!groupedSongs.containsKey(firstChar)) {
          groupedSongs[firstChar] = [];
        }
        groupedSongs[firstChar]!.add(song);
      }
    } else {
      // Group by first letter for alphabetical sorting
      for (var song in displaySongs) {
        String firstChar = song.songTitle[0].toUpperCase();
        if (!groupedSongs.containsKey(firstChar)) {
          groupedSongs[firstChar] = [];
        }
        groupedSongs[firstChar]!.add(song);
      }
    }

    // Get sorted keys
    List<String> sortedKeys = groupedSongs.keys.toList()..sort();

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          String key = sortedKeys[index];
          List<UnifiedSong> songsInGroup = groupedSongs[key]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: widget.isDarkTheme ? Colors.grey[900] : Colors.grey[200],
                width: double.infinity,
                child: Text(
                  key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
              ...songsInGroup.map((song) {
                final isPlaying =
                    songProvider.playingSongNumber == song.songNumber;
                final isFavorite = songProvider.favoriteSongs.contains(song);

                return SongTile(
                  song: song,
                  fontFamily: widget.fontFamily,
                  fontSize: widget.fontSize,
                  isPlaying: isPlaying,
                  isFavorite: isFavorite,
                  onTap: () => _navigateToSongDetail(context, song),
                  onPlayPause: () => songProvider.playOrPauseSong(song),
                  onToggleFavorite: () => songProvider.toggleFavorite(song),
                  canPlay: songProvider.currentCollection ==
                      AppStrings.lpmiCollection,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // 4. Swipe Actions Implementation
  Widget _buildSwiperSongsList(
      SongProvider songProvider, List<UnifiedSong> displaySongs) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displaySongs.length,
        itemBuilder: (context, index) {
          final song = displaySongs[index];
          final isPlaying = songProvider.playingSongNumber == song.songNumber;
          final isFavorite = songProvider.favoriteSongs.contains(song);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Slidable(
              // Slide actions on the right side of the list item
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  // Play/Pause action
                  if (songProvider.currentCollection ==
                      AppStrings.lpmiCollection)
                    SlidableAction(
                      onPressed: (_) => songProvider.playOrPauseSong(song),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: isPlaying ? Icons.pause : Icons.play_arrow,
                      label: isPlaying ? 'Pause' : 'Play',
                      borderRadius: BorderRadius.circular(8),
                    ),
                  // Favorite action
                  SlidableAction(
                    onPressed: (_) => songProvider.toggleFavorite(song),
                    backgroundColor: isFavorite ? Colors.red : Colors.grey,
                    foregroundColor: Colors.white,
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    label: isFavorite ? 'Unfavorite' : 'Favorite',
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Share action
                  SlidableAction(
                    onPressed: (_) => _shareSong(song),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.share,
                    label: 'Share',
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),

              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDarkTheme ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: isPlaying
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    child: Text(
                      song.songNumber,
                      style: TextStyle(
                        color: isPlaying ? Colors.blue : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    song.songTitle,
                    style: TextStyle(
                      fontFamily: widget.fontFamily,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? Colors.blue : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlaying)
                        const Icon(Icons.graphic_eq, color: Colors.blue),
                      if (isFavorite)
                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _navigateToSongDetail(context, song),
                ),
              ),
            ),
          );
        },
      ),
    );
  } // 5. Compact List Implementation

  Widget _buildCompactSectionedList(
      SongProvider songProvider, List<UnifiedSong> displaySongs) {
    // Define theme colors based on the collection
    final Color primaryColor =
        songProvider.currentCollection == AppStrings.lpmiCollection
            ? Colors.blue
            : Colors.purple;

    final Color secondaryColor =
        songProvider.currentCollection == AppStrings.lpmiCollection
            ? Colors.lightBlue
            : Colors.purpleAccent;

    final Color bgColor =
        widget.isDarkTheme ? Colors.grey[900]! : Colors.grey[50]!;

    final Color textColor = widget.isDarkTheme ? Colors.white : Colors.black87;

    // Create sections based on ranges of songs
    List<List<UnifiedSong>> sections = [];

    if (songProvider.sortOption == AppStrings.sortByNumber) {
      // Create sections of 10 songs each (or another appropriate grouping)
      for (int i = 0; i < displaySongs.length; i += 10) {
        sections.add(displaySongs.sublist(
            i, i + 10 > displaySongs.length ? displaySongs.length : i + 10));
      }
    } else {
      // For alphabetical sorting, group by first letter
      Map<String, List<UnifiedSong>> letterGroups = {};
      for (var song in displaySongs) {
        String firstLetter = song.songTitle[0].toUpperCase();
        if (!letterGroups.containsKey(firstLetter)) {
          letterGroups[firstLetter] = [];
        }
        letterGroups[firstLetter]!.add(song);
      }

      // Convert map to list of sections
      letterGroups.forEach((_, songs) {
        sections.add(songs);
      });
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          List<UnifiedSong> sectionSongs = sections[sectionIndex];
          String sectionTitle;

          if (songProvider.sortOption == AppStrings.sortByNumber) {
            // Section title for number groups
            sectionTitle =
                "${sectionSongs.first.songNumber} - ${sectionSongs.last.songNumber}";
          } else {
            // Section title for alphabetical groups
            sectionTitle = sectionSongs.first.songTitle[0].toUpperCase();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: primaryColor.withOpacity(0.1),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      songProvider.sortOption == AppStrings.sortByNumber
                          ? Icons.format_list_numbered
                          : Icons.sort_by_alpha,
                      color: primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sectionTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              ...sectionSongs.map((song) {
                final isPlaying =
                    songProvider.playingSongNumber == song.songNumber;
                final isFavorite = songProvider.favoriteSongs.contains(song);

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: isPlaying ? primaryColor.withOpacity(0.1) : bgColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isPlaying ? primaryColor : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => _navigateToSongDetail(context, song),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      child: Row(
                        children: [
                          // Song number
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: isPlaying
                                  ? primaryColor
                                  : primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              song.songNumber,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPlaying ? Colors.white : primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Song title
                          Expanded(
                            child: Text(
                              song.songTitle,
                              style: TextStyle(
                                fontFamily: widget.fontFamily,
                                fontSize: widget.fontSize -
                                    1, // Slightly smaller for compact view
                                color: isPlaying ? primaryColor : textColor,
                                fontWeight: isPlaying
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Actions
                          if (songProvider.currentCollection ==
                                  AppStrings.lpmiCollection &&
                              !isPlaying)
                            IconButton(
                              icon: const Icon(Icons.play_arrow, size: 20),
                              color: primaryColor,
                              onPressed: () =>
                                  songProvider.playOrPauseSong(song),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 36, minHeight: 36),
                            ),
                          if (isPlaying)
                            IconButton(
                              icon: const Icon(Icons.pause, size: 20),
                              color: primaryColor,
                              onPressed: () =>
                                  songProvider.playOrPauseSong(song),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 36, minHeight: 36),
                            ),
                          IconButton(
                            icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20),
                            color: isFavorite ? Colors.red : Colors.grey,
                            onPressed: () => songProvider.toggleFavorite(song),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Add some spacing between sections
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayer(SongProvider songProvider) {
    final playingSong = songProvider.getCurrentPlayingSong();

    if (playingSong == null) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_animation),
      child: PlayerControls(
        song: playingSong,
        position: songProvider.currentPosition,
        duration: songProvider.totalDuration,
        isPlaying: songProvider.isPlaying,
        isLooping: songProvider.isLooping,
        isDarkTheme: widget.isDarkTheme,
        onPlayPause: () => songProvider.playOrPauseSong(playingSong),
        onStop: () => songProvider.stopSong(),
        onSeek: (position) => songProvider.seekTo(position),
        onToggleLoop: () => songProvider.toggleLoopMode(),
        onRewindTen: () =>
            songProvider.seekRelative(const Duration(seconds: -10)),
        onForwardTen: () =>
            songProvider.seekRelative(const Duration(seconds: 10)),
      ),
    );
  }

  // Modified build method with full-screen header and no app bar
  @override
  Widget build(BuildContext context) {
    // Get providers
    final songProvider = Provider.of<SongProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Determine which songs to display based on current view
    List<UnifiedSong> displaySongs = _currentIndex == 1
        ? songProvider.favoriteSongs
        : songProvider.filteredSongs;

    // Show mini player if a song is playing
    if (songProvider.playingSongNumber != null &&
        !_animationController.isAnimating) {
      _animationController.forward();
    } else if (songProvider.playingSongNumber == null &&
        !_animationController.isDismissed) {
      _animationController.reverse();
    }

    return Scaffold(
      key: _scaffoldKey,
      // No app bar - we're using a custom header
      // that extends to the top of the screen
      extendBodyBehindAppBar: true,

      // Drawer menu (keep this as is)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Colors.grey[900] : Colors.blue,
                image: const DecorationImage(
                  image: AssetImage('assets/images/header_image.png'),
                  fit: BoxFit.cover,
                  opacity: 0.7,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Song Collections',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore and manage your songs',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Views section with "Songs" and "Favorites"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'VIEWS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Songs'),
              selected: _currentIndex == 0,
              selectedTileColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              selected: _currentIndex == 1,
              selectedTileColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(),
            // Collections section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'COLLECTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.library_music),
              title: const Text('Lagu Pujian Masa Ini'),
              selected:
                  songProvider.currentCollection == 'Lagu Pujian Masa Ini',
              selectedTileColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
              onTap: () {
                _selectCollection('Lagu Pujian Masa Ini');
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Syair Rindu Dendam'),
              selected: songProvider.currentCollection == 'Syair Rindu Dendam',
              selectedTileColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
              onTap: () {
                _selectCollection('Syair Rindu Dendam');
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(),
            // Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onFontChange: widget.onFontChange,
                      onFontSizeChange: widget.onFontSizeChange,
                      onThemeChange: widget.onThemeChange,
                      fontSize: widget.fontSize,
                      isDarkTheme: widget.isDarkTheme,
                    ),
                  ),
                );
              },
            ),
            // About item
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),

      // Modified body structure with header at the top
      body: Column(
        children: [
          // Custom header that extends to the top of the screen
          _buildHeader(songProvider),

          // Search bar
          _buildSearchBar(),

          // Song list content
          Expanded(
            child: _buildSongListByStyle(
                songProvider, settingsProvider, displaySongs),
          ),
        ],
      ),

      // Keep the FloatingActionButton
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.blue,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.library_music),
            label: 'Lagu Pujian Masa Ini',
            backgroundColor:
                songProvider.currentCollection == 'Lagu Pujian Masa Ini'
                    ? Colors.blue
                    : Colors.grey,
            onTap: () => _selectCollection('Lagu Pujian Masa Ini'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.library_books),
            label: 'Syair Rindu Dendam',
            backgroundColor:
                songProvider.currentCollection == 'Syair Rindu Dendam'
                    ? Colors.blue
                    : Colors.grey,
            onTap: () => _selectCollection('Syair Rindu Dendam'),
          ),
        ],
      ),

      // Bottom section for mini player
      bottomSheet: _buildMiniPlayer(songProvider),
    );
  }
}

// Add this to any screen temporarily to test icons

class IconDebugWidget extends StatelessWidget {
  const IconDebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Icon Debug Test'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.home, size: 30),
                  Text('Home'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.music_note, size: 30),
                  Text('Music'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.email, size: 30),
                  Text('Email'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.lock, size: 30),
                  Text('Lock'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.visibility, size: 30, color: Colors.blue),
              Icon(Icons.visibility_off, size: 30, color: Colors.red),
              Icon(Icons.favorite, size: 30, color: Colors.pink),
              Icon(Icons.star, size: 30, color: Colors.amber),
            ],
          ),
          SizedBox(height: 16),
          Text('Material Design: ${Theme.of(context).useMaterial3}'),
          Text('Platform: ${Theme.of(context).platform}'),
        ],
      ),
    );
  }
}

// Usage: Add this widget temporarily to your login screen or any screen:
// IconDebugWidget(),
