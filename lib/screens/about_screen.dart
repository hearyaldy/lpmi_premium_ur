// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appName = "";
  String _packageName = "";
  String _version = "";
  String _buildNumber = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
      _isLoading = false;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // App Logo and Info
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.security,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _appName.isEmpty ? 'Firebase Auth App' : _appName,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version $_version (Build $_buildNumber)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _packageName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                // Description
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'This app is a demonstration of Flutter with Firebase backend integration. '
                    'It includes user authentication, profile management, and various other features '
                    'to showcase mobile app development best practices.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),
                
                // Links
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  onTap: () => _launchUrl('https://example.com/terms'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: () => _launchUrl('https://example.com/privacy'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Source Code'),
                  onTap: () => _launchUrl('https://github.com/example/app'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Contact Support'),
                  onTap: () => _launchUrl('mailto:support@example.com'),
                ),
                
                // Credits
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Credits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.flutter_dash),
                  title: Text('Built with Flutter'),
                  subtitle: Text('UI toolkit for building beautiful, natively compiled applications'),
                ),
                const ListTile(
                  leading: Icon(Icons.cloud),
                  title: Text('Powered by Firebase'),
                  subtitle: Text('Google\'s mobile and web application development platform'),
                ),
                
                // Copyright
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '© 2025 Your Company Name. All rights reserved.',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}