import 'package:flutter/material.dart';

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Communication',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildCommunicationStats(context),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildCommunicationCard(
                      context,
                      'Send Notifications',
                      'Send messages to students and parents',
                      Icons.notifications_active,
                      () {
                        // TODO: Navigate to notifications
                      },
                    ),
                    _buildCommunicationCard(
                      context,
                      'Email Communication',
                      'Send emails to staff and parents',
                      Icons.email,
                      () {
                        // TODO: Navigate to email section
                      },
                    ),
                    _buildCommunicationCard(
                      context,
                      'SMS Management',
                      'Send SMS alerts and notifications',
                      Icons.sms,
                      () {
                        // TODO: Navigate to SMS management
                      },
                    ),
                    _buildCommunicationCard(
                      context,
                      'Announcements',
                      'Post school-wide announcements',
                      Icons.campaign,
                      () {
                        // TODO: Navigate to announcements
                      },
                    ),
                    _buildCommunicationCard(
                      context,
                      'Message Templates',
                      'Manage communication templates',
                      Icons.description,
                      () {
                        // TODO: Navigate to templates
                      },
                    ),
                    _buildCommunicationCard(
                      context,
                      'Communication History',
                      'View past communications',
                      Icons.history,
                      () {
                        // TODO: Navigate to history
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Handle new communication
        },
        tooltip: 'New Message',
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildCommunicationStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '156', 'Messages\nToday'),
          _buildStatItem(context, '45', 'Pending\nNotifications'),
          _buildStatItem(context, '89%', 'Delivery\nRate'),
          _buildStatItem(context, '1.2K', 'Total\nRecipients'),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(
          context,
          'Quick SMS',
          Icons.sms,
          () {
            // TODO: Implement quick SMS
          },
        ),
        _buildQuickActionButton(
          context,
          'Broadcast',
          Icons.campaign,
          () {
            // TODO: Implement broadcast
          },
        ),
        _buildQuickActionButton(
          context,
          'Emergency',
          Icons.warning,
          () {
            // TODO: Implement emergency message
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCard(BuildContext context, String title,
      String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).primaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
