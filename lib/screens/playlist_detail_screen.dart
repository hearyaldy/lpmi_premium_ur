import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../providers/song_provider.dart';
import '../providers/playlist_provider.dart';
import '../constants/app_constants.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final bool isDarkTheme;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.isDarkTheme,
  });

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<UnifiedSong> _playlistSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      final List<UnifiedSong> songs = [];

      // Process each song ID in the playlist
      for (final songId in widget.playlist.songIds) {
        // Extract song number and collection
        final parts = songId.split('_');
        if (parts.length != 2) continue;

        final songNumber = parts[0];
        final collectionName = parts[1];

        UnifiedSong? song;
        if (collectionName == AppStrings.lpmiCollection) {
          // Look in LPMI collection
          song = songProvider.lpmiSongs.firstWhere(
            (s) => s.songNumber == songNumber,
            orElse: () => UnifiedSong(
              songNumber: songNumber,
              songTitle: 'Unknown Song',
              verses: [],
            ),
          );
        } else if (collectionName == AppStrings.srdCollection) {
          // Look in SRD collection
          song = songProvider.srdSongs.firstWhere(
            (s) => s.songNumber == songNumber,
            orElse: () => UnifiedSong(
              songNumber: songNumber,
              songTitle: 'Unknown Song',
              verses: [],
            ),
          );
        }

        if (song != null) {
          songs.add(song);
        }
      }

      setState(() {
        _playlistSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading playlist songs: $e');
    }
  }

  Future<void> _removeSongFromPlaylist(UnifiedSong song, int index) async {
    final collection = widget.playlist.songIds[index].split('_')[1];
    final songId = "${song.songNumber}_$collection";

    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final success = await playlistProvider.removeSongFromPlaylist(
      widget.playlist.id,
      songId,
    );

    if (success) {
      setState(() {
        _playlistSongs.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song removed from playlist'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove song from playlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlistSongs.isEmpty
              ? _buildEmptyPlaylist()
              : _buildPlaylistSongsList(songProvider),
    );
  }

  Widget _buildEmptyPlaylist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No songs in this playlist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add songs to this playlist from the song details screen',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistSongsList(SongProvider songProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Playlist info section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Playlist description
              if (widget.playlist.description.isNotEmpty) ...[
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.playlist.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              // Playlist stats
              Row(
                children: [
                  Icon(
                    Icons.music_note,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_playlistSongs.length} songs',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        
        // Song list header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Songs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Play all button
              if (_playlistSongs.isNotEmpty && 
                  _playlistSongs[0].url != null)
                TextButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play All'),
                  onPressed: () {
                    // Play first song
                    songProvider.playOrPauseSong(_playlistSongs[0]);
                  },
                ),
            ],
          ),
        ),
        
        // Song list
        Expanded(
          child: ListView.builder(
            itemCount: _playlistSongs.length,
            itemBuilder: (context, index) {
              final song = _playlistSongs[index];
              final isPlaying = songProvider.playingSongNumber == song.songNumber;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPlaying ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
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
                    fontWeight: FontWeight.bold,
                    color: isPlaying ? Colors.blue : null,
                  ),
                ),
                subtitle: Text(
                  widget.playlist.songIds[index].split('_')[1],
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (song.url != null)
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: isPlaying ? Colors.blue : null,
                        ),
                        onPressed: () {
                          songProvider.playOrPauseSong(song);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeSongFromPlaylist(song, index);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to song detail
                },
              );
            },
          ),
        ),
      ],
    );
  }
}