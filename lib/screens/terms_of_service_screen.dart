// lib/screens/terms_of_service_screen.dart
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildParagraph(
              'By accessing or using our mobile application, you agree to be bound by these Terms of Service and our Privacy Policy. If you disagree with any part of these terms, you may not access the application.'
            ),
            
            _buildSectionTitle('2. User Accounts'),
            _buildParagraph(
              'When you create an account with us, you must provide accurate, complete, and current information. You are responsible for safeguarding the password that you use to access our application and for any activities or actions under your password.'
            ),
            _buildParagraph(
              'You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.'
            ),
            
            _buildSectionTitle('3. Intellectual Property'),
            _buildParagraph(
              'The application and its original content, features, and functionality are and will remain the exclusive property of our company and its licensors. The application is protected by copyright, trademark, and other laws of both the United States and foreign countries.'
            ),
            _buildParagraph(
              'Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of our company.'
            ),
            
            _buildSectionTitle('4. User Content'),
            _buildParagraph(
              'Our application may allow you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material. You are responsible for the content that you post to the application, including its legality, reliability, and appropriateness.'
            ),
            _buildParagraph(
              'By posting content to the application, you grant us the right to use, modify, publicly perform, publicly display, reproduce, and distribute such content on and through the application. You retain any and all of your rights to any content you submit, post or display on or through the application and you are responsible for protecting those rights.'
            ),
            
            _buildSectionTitle('5. Prohibited Uses'),
            _buildParagraph(
              'You may use our application only for lawful purposes and in accordance with these Terms. You agree not to use the application:'
            ),
            _buildBulletPoint('In any way that violates any applicable national or international law or regulation.'),
            _buildBulletPoint('For the purpose of exploiting, harming, or attempting to exploit or harm minors in any way.'),
            _buildBulletPoint('To transmit, or procure the sending of, any advertising or promotional material, including any "junk mail", "chain letter," or "spam."'),
            _buildBulletPoint('To impersonate or attempt to impersonate our company, a company employee, another user, or any other person or entity.'),
            
            _buildSectionTitle('6. Termination'),
            _buildParagraph(
              'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the application will immediately cease.'
            ),
            
            _buildSectionTitle('7. Limitation of Liability'),
            _buildParagraph(
              'In no event shall our company, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the application.'
            ),
            
            _buildSectionTitle('8. Changes'),
            _buildParagraph(
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. What constitutes a material change will be determined at our sole discretion. By continuing to access or use our application after those revisions become effective, you agree to be bound by the revised terms.'
            ),
            
            _buildSectionTitle('9. Governing Law'),
            _buildParagraph(
              'These Terms shall be governed and construed in accordance with the laws of the United States, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.'
            ),
            
            _buildSectionTitle('10. Contact Us'),
            _buildParagraph(
              'If you have any questions about these Terms, please contact us:'
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