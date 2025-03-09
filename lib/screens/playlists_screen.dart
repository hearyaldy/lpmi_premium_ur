import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/auth_provider.dart';
import '../models/playlist.dart';
import './playlist_detail_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  final bool isDarkTheme;

  const PlaylistsScreen({
    Key? key,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  _PlaylistsScreenState createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load playlists when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlaylists();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await playlistProvider.loadPlaylists();
    }
  }

  void _showCreatePlaylistDialog() {
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Playlist Name',
                  hintText: 'Enter playlist name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter playlist description',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
                final success = await playlistProvider.createPlaylist(
                  _nameController.text,
                  description: _descriptionController.text,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Playlist created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create playlist. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlists'),
      ),
      body: authProvider.isAuthenticated
          ? Consumer<PlaylistProvider>(
              builder: (context, playlistProvider, _) {
                if (playlistProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (playlistProvider.playlists.isEmpty) {
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
                          'No playlists yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first playlist to organize your favorite songs',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showCreatePlaylistDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Playlist'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: playlistProvider.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlistProvider.playlists[index];
                    return _buildPlaylistCard(playlist);
                  },
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login Required',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please login to create and view your playlists',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
                ],
              ),
            ),
      floatingActionButton: authProvider.isAuthenticated
          ? FloatingActionButton(
              onPressed: _showCreatePlaylistDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailScreen(
                playlist: playlist,
                isDarkTheme: widget.isDarkTheme,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.queue_music,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (playlist.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        playlist.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${playlist.songIds.length} songs',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showPlaylistOptionsMenu(playlist);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaylistOptionsMenu(Playlist playlist) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Playlist', 
                  style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _confirmDeletePlaylist(playlist);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletePlaylist(Playlist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
      final success = await playlistProvider.deletePlaylist(playlist.id);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}