import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicUrl;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicUrl,
    this.createdAt,
    this.lastLogin,
  });

  // Create from Firebase Auth and additional Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicUrl: data['profilePicUrl'],
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : null,
      lastLogin: data['lastLogin'] != null 
        ? (data['lastLogin'] as Timestamp).toDate() 
        : null,
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create new user document data
  Map<String, dynamic> toNewFirestore() {
    return {
      'name': name,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  // Create copy with modifications
  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }
}