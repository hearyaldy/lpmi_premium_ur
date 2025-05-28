import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final UnifiedSong song;
  final String fontFamily;
  final double fontSize;
  final bool isPlaying;
  final bool isFavorite;
  final bool canPlay;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onToggleFavorite;

  const SongTile({
    super.key,
    required this.song,
    required this.fontFamily,
    required this.fontSize,
    required this.isPlaying,
    required this.isFavorite,
    required this.onTap,
    required this.onPlayPause,
    required this.onToggleFavorite,
    this.canPlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              // Optional: Add a small icon or number indicator
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  song.songNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Song title with hero animation
              Expanded(
                child: Hero(
                  tag: 'song-title-${song.songNumber}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      song.songTitle,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Action buttons
              if (canPlay)
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: isPlaying ? Colors.blue : Colors.grey,
                  ),
                  onPressed: onPlayPause,
                ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
