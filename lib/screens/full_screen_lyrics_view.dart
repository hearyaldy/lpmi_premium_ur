import 'dart:async';
import 'package:flutter/material.dart';
import '../models/song.dart'; // Ensure this imports your UnifiedSong model
import '../services/audio_player_service.dart';
import 'package:flutter/services.dart';

class FullScreenLyricsView extends StatefulWidget {
  final UnifiedSong song;
  final double fontSize;
  final String fontFamily;
  final bool isDarkTheme;
  final AudioPlayerService audioPlayerService;

  const FullScreenLyricsView({
    super.key,
    required this.song,
    required this.fontSize,
    required this.fontFamily,
    required this.isDarkTheme,
    required this.audioPlayerService,
  });

  @override
  _FullScreenLyricsViewState createState() => _FullScreenLyricsViewState();
}

class _FullScreenLyricsViewState extends State<FullScreenLyricsView> {
  late double fontSize;
  late bool isBold;
  late Color backgroundColor;
  bool isAppBarVisible = false;
  Timer? _hideControlsTimer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    fontSize = widget.fontSize;
    isBold = false;
    backgroundColor = widget.isDarkTheme ? Colors.black : Colors.white;

    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _initializePlayer();
  }

  void _initializePlayer() {
    // Only setup listeners, do not auto-start playback
    widget.audioPlayerService.positionStream.listen((position) {
      setState(() {
        _currentPosition = position ?? Duration.zero; // Handle null values
      });
    });

    widget.audioPlayerService.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero; // Handle null values
      });
    });

    // Set initial state based on player status
    _isPlaying = widget.audioPlayerService.isPlaying;
  }

  void _togglePlayPause() {
    widget.audioPlayerService.playOrPause(widget.song.url ?? '', widget.song.songTitle);
    setState(() {
      _isPlaying = widget.audioPlayerService.isPlaying;
    });
  }

  void _toggleAppBarVisibility() {
    setState(() {
      isAppBarVisible = !isAppBarVisible;
    });

    // Reset hide timer when controls are shown
    if (isAppBarVisible) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        isAppBarVisible = false;
      });
    });
  }

  @override
  void dispose() {
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _hideControlsTimer?.cancel();
    widget.audioPlayerService.stop();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showFontOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lyrics Display Options',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Font Size", style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 16.0,
                          max: 40.0,
                          divisions: 12,
                          onChanged: (newSize) {
                            setModalState(() => fontSize = newSize);
                            setState(() => fontSize = newSize);
                          },
                        ),
                      ),
                      Text(fontSize.toStringAsFixed(0), style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.color_lens, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            backgroundColor = backgroundColor == Colors.black ? Colors.white : Colors.black;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(isBold ? Icons.format_bold : Icons.format_italic, color: Colors.white),
                        onPressed: () {
                          setState(() => isBold = !isBold);
                          Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleAppBarVisibility,
            child: PageView.builder(
              itemCount: widget.song.verses.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final verse = widget.song.verses[index];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          verse.verseNumber,
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                            fontFamily: widget.fontFamily,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          verse.lyrics,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                            fontFamily: widget.fontFamily,
                            color: backgroundColor == Colors.black ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Music Player Overlay
          if (isAppBarVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentPosition.inSeconds.toDouble(),
                            max: _totalDuration.inSeconds.toDouble(),
                            onChanged: (value) {
                              widget.audioPlayerService.seek(Duration(seconds: value.toInt()));
                            },
                            activeColor: Colors.white,
                            inactiveColor: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                          onPressed: () => widget.audioPlayerService.seek(
                            _currentPosition - const Duration(seconds: 10),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                          onPressed: () => widget.audioPlayerService.seek(
                            _currentPosition + const Duration(seconds: 10),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.audioPlayerService.isLooping ? Icons.loop : Icons.loop_outlined,
                            color: widget.audioPlayerService.isLooping ? Colors.greenAccent : Colors.white,
                          ),
                          onPressed: () {
                            widget.audioPlayerService.setLoopMode(!widget.audioPlayerService.isLooping);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.white),
                          onPressed: () {
                            widget.audioPlayerService.stop();
                            setState(() => _isPlaying = false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Top app bar with controls
          if (isAppBarVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.black54,
                title: Text(
                  widget.song.songTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: widget.fontFamily,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.text_fields, color: Colors.white),
                    onPressed: _showFontOptions,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
