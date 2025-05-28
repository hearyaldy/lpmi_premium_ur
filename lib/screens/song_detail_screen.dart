import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'full_screen_lyrics_view.dart';

// Updated SongDetailScreen with Bottom Action Bar
class SongDetailScreen extends StatefulWidget {
  final UnifiedSong song;
  final String collectionName;
  final Function(UnifiedSong) toggleFavorite;
  final bool isFavorite;
  final double fontSize;
  final String fontFamily;
  final bool isDarkTheme;
  final AudioPlayerService audioPlayerService;

  const SongDetailScreen({
    super.key,
    required this.song,
    required this.collectionName,
    required this.toggleFavorite,
    required this.isFavorite,
    required this.fontSize,
    required this.fontFamily,
    required this.isDarkTheme,
    required this.audioPlayerService,
    required List verses,
  });

  @override
  _SongDetailScreenState createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late double lyricsFontSize;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    lyricsFontSize = widget.fontSize;
    _isPlaying = widget.audioPlayerService.isPlaying;
  }

  void _shareSong(BuildContext context) {
    final String songLyrics = widget.song.verses
        .map((verse) => "${verse.verseNumber}: ${verse.lyrics}")
        .join("\n");
    final String shareContent =
        "Song: ${widget.song.songTitle}\nCollection: ${widget.collectionName}\n\nLyrics:\n$songLyrics";

    Share.share(shareContent);
  }

  void _showFontSlider() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Adjust Lyrics Font Size',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(lyricsFontSize.toStringAsFixed(1)),
                      Slider(
                        value: lyricsFontSize,
                        min: 14.0,
                        max: 28.0,
                        divisions: 14,
                        onChanged: (newSize) {
                          setModalState(() => lyricsFontSize = newSize);
                          setState(() => lyricsFontSize = newSize);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _togglePlayPause() async {
    try {
      await widget.audioPlayerService
          .playOrPause(widget.song.url ?? '', widget.song.songTitle);
      setState(() {
        _isPlaying = widget.audioPlayerService.isPlaying;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to play song.')),
      );
    }
  }

  void _goToFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenLyricsView(
          song: widget.song,
          fontSize: lyricsFontSize,
          fontFamily: widget.fontFamily,
          isDarkTheme: widget.isDarkTheme,
          audioPlayerService: widget.audioPlayerService,
        ),
      ),
    );
  }

  // Updated build method for SongDetailScreen with Original Header
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkTheme ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Keep your original header
          Container(
            height: 180,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/header_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Colors.black87 : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.song.songNumber} | ${widget.collectionName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: widget.fontFamily,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.song.songTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: widget.fontFamily,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 280, bottom: 70), // Add bottom padding for the action bar
            child: Container(
              color: widget.isDarkTheme ? Colors.black : Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: widget.song.verses.length,
                itemBuilder: (context, index) {
                  final verse = widget.song.verses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            verse.verseNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: widget.fontFamily,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verse.lyrics,
                          style: TextStyle(
                            fontSize: lyricsFontSize,
                            fontFamily: widget.fontFamily,
                            color: widget.isDarkTheme
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Add a back button at the top
          Positioned(
            top: 40,
            left: 10,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      // Bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: widget.isDarkTheme ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Play/Pause button (only for LPMI collection)
            if (widget.collectionName == 'Lagu Pujian Masa Ini')
              _buildActionButton(
                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                label: _isPlaying ? 'Pause' : 'Play',
                onPressed: _togglePlayPause,
              ),

            // Favorite button
            _buildActionButton(
              icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              label: 'Favorite',
              iconColor: widget.isFavorite ? Colors.red : null,
              onPressed: () {
                widget.toggleFavorite(widget.song);
                setState(() {});
              },
            ),

            // Full screen button
            _buildActionButton(
              icon: Icons.fullscreen,
              label: 'Full Screen',
              onPressed: _goToFullScreen,
            ),
          ],
        ),
      ),
      // Keep the FAM for additional actions
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        backgroundColor: Colors.purple,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.text_fields),
            label: 'Adjust Font Size',
            onTap: _showFontSlider,
          ),
          SpeedDialChild(
            child: const Icon(Icons.share),
            label: 'Share',
            onTap: () => _shareSong(context),
          ),
        ],
      ),
    );
  }

// Helper method to build consistent action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    final Color defaultColor =
        widget.isDarkTheme ? Colors.white70 : Colors.black87;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor ?? defaultColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: defaultColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
