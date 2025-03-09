// lib/screens/profile_edit_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../providers/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  String _errorMessage = '';
  String? _profilePicUrl;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    final firebaseUser = authProvider.firebaseUser;
    
    setState(() {
      _nameController.text = user?.name ?? firebaseUser?.displayName ?? '';
      _profilePicUrl = user?.profilePicUrl;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.firebaseUser?.uid;
      
      if (userId == null) {
        throw 'User ID not found. Please try again.';
      }
      
      // 1. Handle profile picture upload if needed
      if (_selectedImageBytes != null) {
        final imageUrl = await _storageService.uploadProfileImage(userId, _selectedImageBytes!);
        if (imageUrl != null) {
          await authProvider.updateProfilePicture(imageUrl);
        }
      }

      // 2. Update user name
      await authProvider.updateUserName(_nameController.text.trim());
      
      // 3. Refresh data
      await authProvider.refreshUserData();
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Profile picture selection
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : (_profilePicUrl != null
                                ? NetworkImage(_profilePicUrl!)
                                : null) as ImageProvider<Object>?,
                        child: _selectedImageBytes == null && _profilePicUrl == null
                            ? const Icon(Icons.person, size: 64, color: Colors.grey)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Email field (disabled)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.userModel;
                    final firebaseUser = authProvider.firebaseUser;
                    final email = user?.email ?? firebaseUser?.email ?? '';
                    
                    return TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(
                        labelText: 'Email (Cannot be changed)',
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                      ),
                      enabled: false,
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Profile', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}