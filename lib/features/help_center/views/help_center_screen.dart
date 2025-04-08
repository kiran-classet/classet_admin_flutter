import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Frequently Asked Questions',
              [
                _buildFAQItem(
                  'How do I reset my password?',
                  'Go to Settings > Security > Change Password and follow the instructions.',
                ),
                _buildFAQItem(
                  'How do I update my profile?',
                  'Navigate to Settings > Account > Profile Settings to update your information.',
                ),
                _buildFAQItem(
                  'How do I manage notifications?',
                  'Go to Settings > Notifications to customize your notification preferences.',
                ),
                _buildFAQItem(
                  'How do I contact customer support?',
                  'You can contact customer support via the Help Center > Contact Support section.',
                ),
                _buildFAQItem(
                  'How do I report a bug?',
                  'Navigate to Help Center > Report a Bug and provide the necessary details.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            // _buildSection(
            //   'Contact Support',
            //   [
            //     _buildContactItem(
            //       'Email Support',
            //       'support@classet.com',
            //       Icons.email,
            //     ),
            //     _buildContactItem(
            //       'Phone Support',
            //       '+1 234 567 8900',
            //       Icons.phone,
            //     ),
            //     _buildContactItem(
            //       'Live Chat',
            //       'Available 24/7',
            //       Icons.chat,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // _buildSection(
            //   'Help Resources',
            //   [
            //     _buildResourceItem(
            //       'User Guide',
            //       'Comprehensive guide to using the app',
            //       Icons.book,
            //     ),
            //     _buildResourceItem(
            //       'Video Tutorials',
            //       'Step-by-step video guides',
            //       Icons.play_circle,
            //     ),
            //     _buildResourceItem(
            //       'Knowledge Base',
            //       'Detailed articles and how-to guides',
            //       Icons.library_books,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String title, String detail, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(detail),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Implement contact action
        },
      ),
    );
  }

  Widget _buildResourceItem(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Implement resource action
        },
      ),
    );
  }
}
