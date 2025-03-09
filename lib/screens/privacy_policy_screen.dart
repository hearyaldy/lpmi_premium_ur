// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: $formattedDate',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Introduction'),
            _buildParagraph(
              'Welcome to our application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this Privacy Policy carefully. By using the application, you agree to the collection and use of information in accordance with this policy.'
            ),
            
            _buildSectionTitle('Information We Collect'),
            _buildParagraph(
              'We may collect several different types of information for various purposes to provide and improve our service to you:'
            ),
            _buildSubsectionTitle('Personal Data'),
            _buildParagraph(
              'While using our Application, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you. This may include, but is not limited to:'
            ),
            _buildBulletPoint('Email address'),
            _buildBulletPoint('First name and last name'),
            _buildBulletPoint('Profile pictures'),
            
            _buildSubsectionTitle('Usage Data'),
            _buildParagraph(
              'We may also collect information that your device sends whenever you use our Application. This may include information such as your device\'s Internet Protocol address, browser type, browser version, and other diagnostic data.'
            ),
            
            _buildSectionTitle('Use of Data'),
            _buildParagraph(
              'We use the collected data for various purposes:'
            ),
            _buildBulletPoint('To provide and maintain our service'),
            _buildBulletPoint('To notify you about changes to our service'),
            _buildBulletPoint('To provide customer support'),
            _buildBulletPoint('To monitor usage of our service'),
            _buildBulletPoint('To detect, prevent, and address technical issues'),
            
            _buildSectionTitle('Data Security'),
            _buildParagraph(
              'The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal data, we cannot guarantee its absolute security.'
            ),
            
            _buildSectionTitle('Children\'s Privacy'),
            _buildParagraph(
              'Our Application does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal data, please contact us.'
            ),
            
            _buildSectionTitle('Changes to This Privacy Policy'),
            _buildParagraph(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.'
            ),
            
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
              'If you have any questions about this Privacy Policy, please contact us:'
            ),
            _buildBulletPoint('By email: support@example.com'),
            _buildBulletPoint('By visiting our website: https://example.com/contact'),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}