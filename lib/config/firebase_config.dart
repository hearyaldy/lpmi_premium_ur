import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  // Firebase collection names
  static const String usersCollection = 'users';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  
  // Firestore security rules documentation
  // Example rules in the Firebase console:
  // 
  // rules_version = '2';
  // service cloud.firestore {
  //   match /databases/{database}/documents {
  //     match /users/{userId} {
  //       allow read, update: if request.auth != null && request.auth.uid == userId;
  //       allow create: if request.auth != null;
  //       
  //       match /favorites/{document=**} {
  //         allow read, write: if request.auth != null && request.auth.uid == userId;
  //       }
  //       
  //       match /playlists/{document=**} {
  //         allow read, write: if request.auth != null && request.auth.uid == userId;
  //       }
  //       
  //       match /settings/{document=**} {
  //         allow read, write: if request.auth != null && request.auth.uid == userId;
  //       }
  //     }
  //   }
  // }
}