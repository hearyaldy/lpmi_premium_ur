import 'package:cloud_firestore/cloud_firestore.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Playlist.fromFirestore(Map<String, dynamic> data, String id) {
    return Playlist(
      id: id,
      name: data['name'] ?? 'Unnamed Playlist',
      description: data['description'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as Timestamp).toDate() 
        : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'songIds': songIds,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Create a new empty playlist
  factory Playlist.create(String name, {String description = ''}) {
    return Playlist(
      id: '', // Will be replaced with Firestore document ID
      name: name,
      description: description,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}