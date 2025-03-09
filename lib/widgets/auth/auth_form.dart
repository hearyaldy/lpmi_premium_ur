// lib/widgets/auth/auth_form.dart
import 'package:flutter/material.dart';
import '../../utils/validators.dart';

typedef AuthCallback = Future<void> Function({
  required String email,
  required String password,
  String? name,
});

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final AuthCallback onSubmit;
  final VoidCallback? onToggleAuthMode;
  final VoidCallback? onForgotPassword;
  final String? errorMessage;
  final bool isLoading;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
    this.onToggleAuthMode,
    this.onForgotPassword,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.isLogin) {
        await widget.onSubmit(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await widget.onSubmit(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Error message
          if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
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
                      widget.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Name field (only for registration)
          if (!widget.isLogin)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.validateName(value),
              enabled: !widget.isLoading,
            ),
          if (!widget.isLogin) const SizedBox(height: 20),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.validateEmail(value),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 20),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              helperText: widget.isLogin ? null : 'At least 8 characters with letters and numbers',
            ),
            obscureText: _obscurePassword,
            textInputAction: widget.isLogin ? TextInputAction.done : TextInputAction.next,
            validator: (value) => Validators.validatePassword(value),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 20),

          // Confirm password field (only for registration)
          if (!widget.isLogin)
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              enabled: !widget.isLoading,
              onFieldSubmitted: (_) => _submitForm(),
            ),

          if (!widget.isLogin) const SizedBox(height: 20),

          // Forgot password (only for login)
          if (widget.isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading ? null : widget.onForgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Toggle auth mode
          if (widget.onToggleAuthMode != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.isLogin ? "Don't have an account?" : "Already have an account?"),
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onToggleAuthMode,
                  child: Text(widget.isLogin ? 'Register' : 'Login'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}