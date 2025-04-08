import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/features/dashboard/views/attendance_quick_actions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';

// Filter provider
final filterProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'branch': null,
      'board': null,
      'grade': null,
      'section': <String>[], // Explicitly typed as List<String>
    });

// Mock JSON data (in a real app, this would come from an API)

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUserState = ref.watch(adminUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10.0,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildQuickStats(context),
                const SizedBox(height: 20),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildSectionTitle(context, 'Quick Actions'),
                const SizedBox(height: 10),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildQuickActions(context),
                const SizedBox(height: 20),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildSectionTitle(context, 'Key Metrics'),
                const SizedBox(height: 10),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildKeyMetrics(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FilterButtonWidget(
        showSections: true, // Do not show sections in Home screen
        isSingleSectionsSelection: false,
        onFilterApplied: () {
          final currentFilters = ref.read(filterProvider);
          print('Applied filters: $currentFilters');
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'School Dashboard Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '1,234', 'Total\nStudents'),
          _buildDivider(),
          _buildStatItem(context, '85%', 'Attendance\nRate'),
          _buildDivider(),
          _buildStatItem(context, '95%', 'Fee\nCollection'),
          _buildDivider(),
          _buildStatItem(context, '45', 'Active\nTeachers'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionItem(context, 'Attendance', Icons.fact_check, Colors.green),
        _buildActionItem(context, 'Admissions', Icons.school,
            const Color.fromARGB(255, 97, 102, 107)),
        _buildActionItem(context, 'Finance', Icons.account_balance_wallet,
            const Color.fromARGB(255, 97, 102, 107)),
        _buildActionItem(context, 'Transport', Icons.directions_bus,
            const Color.fromARGB(255, 97, 102, 107)),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (label == 'Attendance') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceQuickActionsPage(),
            ),
          );
        } else if (label == 'Admissions' ||
            label == 'Finance' ||
            label == 'Transport') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label: Coming Soon'),
              duration: Duration(seconds: 1), // Show snackbar for 3 seconds
            ),
          );
        }
      },
      child: Material(
        elevation: 4, // Adjust the elevation value as needed
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                context,
                'Students',
                '1,234',
                Icons.trending_up,
                Colors.green,
                '+5% this month',
              ),
              _buildMetricItem(
                context,
                'Revenue',
                '₹5.2L',
                Icons.trending_up,
                Colors.green,
                '+12% this month',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                context,
                'Attendance',
                '85%',
                Icons.trending_down,
                Colors.red,
                '-2% this week',
              ),
              _buildMetricItem(
                context,
                'Transport',
                '15 Routes',
                Icons.trending_flat,
                Colors.orange,
                'No change',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value,
      IconData trendIcon, Color trendColor, String trendLabel) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                trendIcon,
                color: trendColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                trendLabel,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
