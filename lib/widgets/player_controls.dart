import 'package:flutter/material.dart';
import '../models/song.dart';

class PlayerControls extends StatelessWidget {
  final UnifiedSong song;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLooping;
  final bool isDarkTheme;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final Function(Duration) onSeek;
  final VoidCallback onToggleLoop;
  final VoidCallback onRewindTen;
  final VoidCallback onForwardTen;

  const PlayerControls({
    super.key,
    required this.song,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isLooping,
    required this.isDarkTheme,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
    required this.onToggleLoop,
    required this.onRewindTen,
    required this.onForwardTen,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[850] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Music animation image
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.asset(
                  'assets/images/music_note.gif',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Song title with number
                    Text(
                      "${song.songNumber} - ${song.songTitle}",
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(
                      thickness: 1,
                      height: 10,
                    ),
                    // Seek slider
                    Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                      onChanged: (value) {
                        onSeek(Duration(seconds: value.toInt()));
                      },
                      activeColor: isDarkTheme ? Colors.white : Colors.blue,
                      inactiveColor:
                          isDarkTheme ? Colors.grey : Colors.grey[300],
                    ),
                    // Position and duration indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: TextStyle(
                            color:
                                isDarkTheme ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color:
                                isDarkTheme ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.replay_10,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
                onPressed: onRewindTen,
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: Icon(
                  Icons.forward_10,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
                onPressed: onForwardTen,
              ),
              IconButton(
                icon: Icon(
                  isLooping ? Icons.loop : Icons.loop_outlined,
                  color: isLooping
                      ? (isDarkTheme ? Colors.greenAccent : Colors.green)
                      : (isDarkTheme ? Colors.white : Colors.black87),
                ),
                onPressed: onToggleLoop,
              ),
              IconButton(
                icon: Icon(
                  Icons.stop,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
                onPressed: onStop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
