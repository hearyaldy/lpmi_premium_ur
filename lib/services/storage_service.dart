import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/firebase_config.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image and return the download URL
  Future<String?> uploadProfileImage(String userId, Uint8List fileBytes) async {
    try {
      debugPrint("Uploading profile image for user: $userId");
      
      // Create a reference to the file location
      final storageRef = _storage.ref()
        .child(FirebaseConfig.profileImagesPath)
        .child('$userId.jpg');
      
      // Delete the old image if it exists to avoid clutter
      try {
        await storageRef.delete();
        debugPrint("Deleted old profile image");
      } catch (e) {
        // Ignore errors if the file doesn't exist
      }
      
      // Upload the new image
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );
      
      final uploadTask = await storageRef.putData(fileBytes, metadata);
      
      if (uploadTask.state == TaskState.success) {
        // Get the download URL
        final downloadUrl = await storageRef.getDownloadURL();
        debugPrint("Profile image uploaded successfully: $downloadUrl");
        return downloadUrl;
      }
      
      return null;
    } catch (e) {
      debugPrint("Error uploading profile image: $e");
      return null;
    }
  }

  // Delete a profile image
  Future<bool> deleteProfileImage(String userId) async {
    try {
      debugPrint("Deleting profile image for user: $userId");
      
      final storageRef = _storage.ref()
        .child(FirebaseConfig.profileImagesPath)
        .child('$userId.jpg');
      
      await storageRef.delete();
      
      debugPrint("Profile image deleted successfully");
      return true;
    } catch (e) {
      debugPrint("Error deleting profile image: $e");
      return false;
    }
  }
  
  // Get storage URL from filename (useful for displaying images)
  String getProfileImageUrl(String userId) {
    return _storage.ref()
      .child(FirebaseConfig.profileImagesPath)
      .child('$userId.jpg')
      .getDownloadURL()
      .toString();
  }
}