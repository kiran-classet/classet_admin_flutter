import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classet_admin/features/academic/providers/academic_year_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false; // Add this state variable

  @override
  Widget build(BuildContext context) {
    final academicYearState = ref.watch(academicYearProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10.0,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildAcademicYearDropdown(academicYearState),
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
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;

    if (userDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userInfo = userDetails['data']['user_info'];
    final profileImage = userInfo['studentPhoto']['storageLocation'] ?? '';
    final name = userInfo['name'] ?? 'N/A';

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
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(profileImage),
          ),
          const SizedBox(height: 16),
          Text(
            name.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;

    if (userDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userInfo = userDetails['data']['user_info'];
    final email = userInfo['email'] ?? 'N/A';
    final phone = userInfo['phone_number'] ?? 'N/A';
    final address = 'Hyderabad, Telangana'; // Placeholder
    final education = 'M.Tech'; // Placeholder
    final specialization = userInfo['roles']?.isNotEmpty ?? false
        ? 'School Administration'
        : 'N/A'; // Placeholder

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildDetailItem(Icons.email, 'Email', email, ''),
            const Divider(),
            _buildDetailItem(Icons.phone, 'Phone', phone, ''),
            const Divider(),
            _buildDetailItem(Icons.location_on, 'Address', address, ''),
            const Divider(),
            _buildDetailItem(Icons.school, 'Education', education, ''),
            const Divider(),
            _buildDetailItem(Icons.work, 'Specialization', specialization, ''),
          ],
        ),
      ),
    );
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

  Widget _buildAcademicYearDropdown(AcademicYearState academicYearState) {
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;

    if (userDetails == null ||
        userDetails['data']['user_info']['academicYears'] == null) {
      return const SizedBox.shrink();
    }

    final academicYears =
        userDetails['data']['user_info']['academicYears'] as List;
    final selectedYear =
        userDetails['data']['user_info']['selectedAcademicYear'];
    final username = userDetails['data']['username'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Academic Year',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedYear,
                items: academicYears.map((year) {
                  return DropdownMenuItem<String>(
                    value: year['_id'],
                    child: Text(year['academicYear']),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      _isLoading = true; // Show loader
                    });

                    await ref
                        .read(adminUserProvider.notifier)
                        .fetchUserDetailsBasedOnAcademicYear(username, value);

                    setState(() {
                      _isLoading = false; // Hide loader
                    });
                  }
                },
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
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
          const SizedBox(height: 12),
          _buildActionButton(
            'Logout',
            Icons.logout,
            Colors.red,
            () {
              _logout(context);
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

  Future<void> _logout(BuildContext context) async {
    try {
      ref.read(filterStateProvider.notifier).clearAllFilters();

      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      await prefs.clear();

      if (savedEmail != null) {
        await prefs.setString('email', savedEmail);
      }
      if (savedPassword != null) {
        await prefs.setString('password', savedPassword);
      }

      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }
}
