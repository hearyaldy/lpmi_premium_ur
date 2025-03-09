// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _userModel;
  User? _firebaseUser;
  bool _isLoading = true;
  String _errorMessage = '';

  // Getters
  UserModel? get userModel => _userModel;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  String get errorMessage => _errorMessage;

  // Constructor
  AuthProvider() {
    _init();
  }

  // Initialize the provider
  Future<void> _init() async {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      
      if (user != null) {
        await _loadUserModel();
      } else {
        _userModel = null;
      }
      
      _isLoading = false;
      notifyListeners();
    });
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Load user model from Firestore
  Future<void> _loadUserModel() async {
    try {
      _userModel = await _authService.getUserDetails();
    } catch (e) {
      debugPrint("Error loading user model: $e");
      _userModel = null;
    }
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      await _loadUserModel();
    }
  }

  // Add this method to check authentication status
  Future<void> checkAuthStatus() async {
    try {
      // Check if user is already authenticated from FirebaseAuth
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // User is authenticated, set the _firebaseUser
        _firebaseUser = currentUser;
        
        // Load user details from Firestore if needed
        await _loadUserModel();
      } else {
        // User is not authenticated
        _firebaseUser = null;
        _userModel = null;
      }
      
      // Update loading state
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error checking auth status: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new account
  Future<void> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      await _authService.createAccount(
        email: email,
        password: password,
        name: name,
      );
      
      // User will be automatically set via the authStateChanges listener
    } catch (e) {
      debugPrint("Error in createAccount: $e");
      String errorMessage = 'Registration failed';
      
      // Provide more specific error messages
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          default:
            errorMessage = e.message ?? 'Unknown authentication error';
        }
      }
      
      _setErrorMessage(errorMessage);
      _setLoading(false);
      throw errorMessage;
    }
  }

  // Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      await _authService.login(
        email: email,
        password: password,
      );
      
      // User will be automatically set via the authStateChanges listener
    } catch (e) {
      debugPrint("Error in login: $e");
      String errorMessage = 'Login failed';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
            errorMessage = 'Invalid email or password';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts, please try again later';
            break;
          default:
            errorMessage = e.message ?? 'Unknown authentication error';
        }
      }
      
      _setErrorMessage(errorMessage);
      _setLoading(false);
      throw errorMessage;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      await _authService.logout();
      
      // User will be automatically cleared via the authStateChanges listener
    } catch (e) {
      debugPrint("Error in logout: $e");
      _setErrorMessage('Logout failed');
      _setLoading(false);
      throw 'Logout failed';
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      final result = await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return result;
    } catch (e) {
      debugPrint("Error sending password reset email: $e");
      _setErrorMessage('Failed to send password reset email');
      _setLoading(false);
      return false;
    }
  }

  // Update user name
  Future<bool> updateUserName(String name) async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      final result = await _authService.updateUserName(name);
      
      if (result) {
        // Refresh the user model
        await _loadUserModel();
      }
      
      _setLoading(false);
      return result;
    } catch (e) {
      debugPrint("Error updating user name: $e");
      _setErrorMessage('Failed to update name');
      _setLoading(false);
      return false;
    }
  }

  // Update profile picture
  Future<bool> updateProfilePicture(String url) async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      final result = await _authService.updateProfilePicture(url);
      
      if (result) {
        // Refresh the user model
        await _loadUserModel();
      }
      
      _setLoading(false);
      return result;
    } catch (e) {
      debugPrint("Error updating profile picture: $e");
      _setErrorMessage('Failed to update profile picture');
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _setLoading(true);
      _setErrorMessage('');
      
      final result = await _authService.changePassword(currentPassword, newPassword);
      _setLoading(false);
      return result;
    } catch (e) {
      debugPrint("Error changing password: $e");
      
      String errorMessage = 'Failed to change password';
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          errorMessage = 'Current password is incorrect';
        } else {
          errorMessage = e.message ?? 'Authentication error';
        }
      }
      
      _setErrorMessage(errorMessage);
      _setLoading(false);
      return false;
    }
  }
}