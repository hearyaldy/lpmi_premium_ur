import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Playlist> _playlists = [];
  bool _isLoading = false;
  
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  
  // Load user playlists from Firestore
  Future<void> loadPlaylists() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _playlists = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .orderBy('updatedAt', descending: true)
          .get();
          
      _playlists = querySnapshot.docs
          .map((doc) => Playlist.fromFirestore(doc.data(), doc.id))
          .toList();
          
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new playlist in Firestore
  Future<bool> createPlaylist(String name, {String description = ''}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    
    try {
      final newPlaylist = Playlist.create(name, description: description);
      
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .add({
            'name': newPlaylist.name,
            'description': newPlaylist.description,
            'songIds': [],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
      // Add the new playlist to the local list
      final createdPlaylist = Playlist(
        id: docRef.id,
        name: newPlaylist.name,
        description: newPlaylist.description,
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _playlists.insert(0, createdPlaylist);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      return false;
    }
  }
  
  // Add a song to a playlist in Firestore
  Future<bool> addSongToPlaylist(String playlistId, UnifiedSong song, String collectionName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    
    final songId = "${song.songNumber}_$collectionName";
    
    try {
      // Find the playlist
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) return false;
      
      // Check if song is already in playlist
      final playlist = _playlists[playlistIndex];
      if (playlist.songIds.contains(songId)) return true; // Already added
      
      // Add song to playlist
      final updatedSongIds = List<String>.from(playlist.songIds)..add(songId);
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .update({
            'songIds': updatedSongIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
      // Update local playlist
      _playlists[playlistIndex] = Playlist(
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        songIds: updatedSongIds,
        createdAt: playlist.createdAt,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
      return false;
    }
  }
  
  // Remove a song from a playlist in Firestore
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    
    try {
      // Find the playlist
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) return false;
      
      // Remove song from playlist
      final playlist = _playlists[playlistIndex];
      final updatedSongIds = List<String>.from(playlist.songIds)
        ..removeWhere((id) => id == songId);
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .update({
            'songIds': updatedSongIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
      // Update local playlist
      _playlists[playlistIndex] = Playlist(
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        songIds: updatedSongIds,
        createdAt: playlist.createdAt,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing song from playlist: $e');
      return false;
    }
  }
  
  // Delete a playlist from Firestore
  Future<bool> deletePlaylist(String playlistId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .delete();
          
      _playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      return false;
    }
  }
}