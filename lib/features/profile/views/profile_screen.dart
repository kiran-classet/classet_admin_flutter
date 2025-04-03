import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classet_admin/features/academic/providers/academic_year_provider.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showInitialAnimation = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().then((_) {
        setState(() {
          _showInitialAnimation = false;
        });
      });

    final academicYears = ref.read(academicYearProvider).academicYears;
    if (academicYears.isNotEmpty) {
      final selectedAcademicYear =
          ref.read(academicYearProvider).selectedAcademicYear;
      if (selectedAcademicYear == null) {
        ref
            .read(academicYearProvider.notifier)
            .setSelectedAcademicYear(academicYears.first['_id']);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshAcademicYears() async {
    setState(() {
      _showInitialAnimation = true;
    });
    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _showInitialAnimation = false;
      });
    });
    await ref.read(academicYearProvider.notifier).fetchAcademicYears();
  }

  @override
  Widget build(BuildContext context) {
    final academicYearState = ref.watch(academicYearProvider);

    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is OverscrollNotification) {
              // Adjust the animation controller based on the overscroll amount
              _animationController.value =
                  (_animationController.value - notification.overscroll / 100)
                      .clamp(0.0, 1.0);
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: _refreshAcademicYears,
            displacement: 100,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 10.0,
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (_showInitialAnimation)
                      Lottie.asset(
                        'assets/animations/refresh_animation.json',
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                        controller: _animationController,
                      ),
                    if (!_showInitialAnimation)
                      SizedBox(height: 0), // Remove the padding after animation
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildAcademicYearDropdown(academicYearState),
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
            _buildDetailItem(
                Icons.email, 'Email', 'kiran.monangi@classet.com', ''),
            const Divider(),
            _buildDetailItem(Icons.phone, 'Phone', '+91 9876543210', ''),
            const Divider(),
            _buildDetailItem(
                Icons.location_on, 'Address', 'Hyderabad, Telangana', ''),
            const Divider(),
            _buildDetailItem(Icons.school, 'Education', 'M.Tech', ''),
            const Divider(),
            _buildDetailItem(
                Icons.work, 'Specialization', 'School Administration', ''),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear filter state
      ref.read(filterStateProvider.notifier).clearAllFilters();

      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      // Clear all preferences
      await prefs.clear();

      // Save back only email and password if remember me was enabled
      if (savedEmail != null) {
        await prefs.setString('email', savedEmail);
      }
      if (savedPassword != null) {
        await prefs.setString('password', savedPassword);
      }

      // Navigate to login
      context.go('/login');
    } catch (e) {
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

  Widget _buildAcademicYearDropdown(AcademicYearState academicYearState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
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
                value: academicYearState.selectedAcademicYear,
                items: academicYearState.academicYears.map((year) {
                  return DropdownMenuItem<String>(
                    value: year['_id'],
                    child: Text(year['academicCode']),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(academicYearProvider.notifier)
                        .setSelectedAcademicYear(value);
                  }
                },
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
