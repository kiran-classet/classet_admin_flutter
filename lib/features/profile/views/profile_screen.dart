import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildQuickStats(),
                const SizedBox(height: 20),
                _buildProfileDetails(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                    'https://misedu-manage.classet.in/profilew.jpg'),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kiran Monangi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'School Administrator',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ADM001',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Experience', '5+ Years'),
          _buildStatItem('Department', 'Administration'),
          _buildStatItem('Status', 'Active'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            _buildDetailItem(Icons.email, 'Email', 'kiran.monangi@classet.com',
                'Update Email'),
            const Divider(),
            _buildDetailItem(
                Icons.phone, 'Phone', '+91 9876543210', 'Update Phone'),
            const Divider(),
            _buildDetailItem(Icons.location_on, 'Address',
                'Hyderabad, Telangana', 'Update Address'),
            const Divider(),
            _buildDetailItem(
                Icons.school, 'Education', 'M.Tech', 'Update Education'),
            const Divider(),
            _buildDetailItem(Icons.work, 'Specialization',
                'School Administration', 'Update Specialization'),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      context.go('/'); // Ensure this matches your login route

      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      // Invalidate the providers correctly
      // await MyAppProviders.invalidateAllProviders(ref);

      // Clear all preferences
      await prefs.clear();

      // Save the email and password if they exist
      if (savedEmail != null) {
        await prefs.setString('email', savedEmail);
      }
      if (savedPassword != null) {
        await prefs.setString('password', savedPassword);
      }

      // Navigate to the login screen (ensure your GoRouter setup is correct)
      context.go('/login'); // Ensure this matches your login route
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, String actionLabel) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(value),
      trailing: TextButton(
        onPressed: () {
          // TODO: Implement update action
        },
        child: Text(
          actionLabel,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionButton(
            'Change Password',
            Icons.lock,
            Colors.blue,
            () {
              // TODO: Implement change password
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Notification Settings',
            Icons.notifications,
            Colors.orange,
            () {
              // TODO: Implement notification settings
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Privacy Settings',
            Icons.security,
            Colors.green,
            () {
              // TODO: Implement privacy settings
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Help & Support',
            Icons.help,
            Colors.purple,
            () {
              // TODO: Implement help & support
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Logout',
            Icons.logout,
            Colors.red,
            () {
              _logout(context);
              // TODO: Implement logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
