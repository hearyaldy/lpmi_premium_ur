import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config/firebase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create a new account
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint("Creating user account...");
      
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Create user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(
          userCredential.user!.uid,
          name,
          email,
        );
      }
      
      debugPrint("User created successfully: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      debugPrint("Registration error: $e");
      rethrow;
    }
  }
  
  // Create user document in Firestore
  Future<void> _createUserDocument(String uid, String name, String email) async {
    try {
      debugPrint("Creating user document in Firestore...");
      
      final userDoc = _firestore.collection(FirebaseConfig.usersCollection).doc(uid);
      final userModel = UserModel(
        id: uid,
        name: name,
        email: email,
        profilePicUrl: null,
      );
      
      await userDoc.set(userModel.toNewFirestore());
      debugPrint("User document created successfully");
    } catch (e) {
      debugPrint("Error creating user document: $e");
      // We don't rethrow here to avoid failing the whole registration
      // but in a production app, consider how to handle this properly
    }
  }

  // Login with email and password
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("Attempting to login with email: $email");
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login timestamp
      if (userCredential.user != null) {
        await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userCredential.user!.uid)
          .update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
      }
      
      debugPrint("Login successful, user ID: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    }
  }

  // Logout current user
  Future<void> logout() async {
    try {
      debugPrint("Attempting to logout");
      await _auth.signOut();
      debugPrint("Logout successful");
    } catch (e) {
      debugPrint("Logout error: $e");
      rethrow;
    }
  }

  // Get user details from Firestore
  Future<UserModel?> getUserDetails() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      debugPrint("Fetching user details for ID: ${user.uid}");
      
      final doc = await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(user.uid)
        .get();
      
      if (doc.exists && doc.data() != null) {
        debugPrint("User details fetched successfully");
        return UserModel.fromFirestore(doc.data()!, user.uid);
      } else {
        debugPrint("User document not found, attempting to create it");
        
        // Create document if it doesn't exist (fallback)
        await _createUserDocument(
          user.uid,
          user.displayName ?? 'User',
          user.email ?? '',
        );
        
        // Try to fetch again
        final newDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();
          
        if (newDoc.exists && newDoc.data() != null) {
          return UserModel.fromFirestore(newDoc.data()!, user.uid);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  // Update user name in both Auth and Firestore
  Future<bool> updateUserName(String newName) async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      debugPrint("Updating user name to: $newName");
      
      // Update in Auth
      await user.updateDisplayName(newName);
      
      // Update in Firestore
      await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(user.uid)
        .update({
          'name': newName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      
      debugPrint("User name updated successfully");
      return true;
    } catch (e) {
      debugPrint("Error updating user name: $e");
      return false;
    }
  }

  // Update profile picture URL
  Future<bool> updateProfilePicture(String profilePicUrl) async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      debugPrint("Updating profile picture URL");
      
      // Update in Auth
      await user.updatePhotoURL(profilePicUrl);
      
      // Update in Firestore
      await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(user.uid)
        .update({
          'profilePicUrl': profilePicUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      
      debugPrint("Profile picture updated successfully");
      return true;
    } catch (e) {
      debugPrint("Error updating profile picture: $e");
      return false;
    }
  }
  
  // Change user password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) return false;
      
      debugPrint("Changing user password");
      
      // Re-authenticate user to verify current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      debugPrint("Password changed successfully");
      return true;
    } catch (e) {
      debugPrint("Error changing password: $e");
      return false;
    }
  }
  
  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      debugPrint("Sending password reset email to: $email");
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent successfully");
      return true;
    } catch (e) {
      debugPrint("Error sending password reset email: $e");
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) return false;
      
      debugPrint("Deleting user account");
      
      // Re-authenticate user first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete Firestore document
      await _firestore.collection(FirebaseConfig.usersCollection).doc(user.uid).delete();
      
      // Delete Auth user
      await user.delete();
      
      debugPrint("Account deleted successfully");
      return true;
    } catch (e) {
      debugPrint("Error deleting account: $e");
      return false;
    }
  }
}