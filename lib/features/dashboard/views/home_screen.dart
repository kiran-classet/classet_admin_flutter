import 'package:classet_admin/core/constants/constants.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'dart:convert';

// Filter provider
final filterProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'branch': null,
      'board': null,
      'grade': null,
      'section': <String>[], // Explicitly typed as List<String>
    });

// Mock JSON data (in a real app, this would come from an API)

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
                _buildSectionTitle(context, 'Recent Activities'),
                const SizedBox(height: 10),
                adminUserState.isLoading
                    ? _buildShimmerEffect()
                    : _buildRecentActivities(context),
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
        onFilterApplied: () {
          _showFilterBottomSheet(context, ref);
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
        CircleAvatar(
          radius: 24,
          backgroundImage:
              NetworkImage('https://misedu-manage.classet.in/profilew.jpg'),
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
        _buildActionItem(context, 'Admissions', Icons.school, Colors.blue),
        _buildActionItem(context, 'Attendance', Icons.fact_check, Colors.green),
        _buildActionItem(
            context, 'Finance', Icons.account_balance_wallet, Colors.purple),
        _buildActionItem(
            context, 'Transport', Icons.directions_bus, Colors.orange),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
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
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildActivityItem(context, _getActivityData(index));
        },
      ),
    );
  }

  Map<String, dynamic> _getActivityData(int index) {
    final activities = [
      {
        'title': 'New Admission',
        'description': 'John Doe admitted to Class 10-A',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'title': 'Fee Collection',
        'description': 'Received ₹25,000 from Class 9 students',
        'time': '3 hours ago',
        'icon': Icons.payment,
        'color': Colors.blue,
      },
      {
        'title': 'Attendance Update',
        'description': 'Class 8 attendance marked for today',
        'time': '4 hours ago',
        'icon': Icons.fact_check,
        'color': Colors.orange,
      },
      {
        'title': 'Transport Alert',
        'description': 'Bus 02 route updated for evening schedule',
        'time': '5 hours ago',
        'icon': Icons.directions_bus,
        'color': Colors.purple,
      },
      {
        'title': 'Teacher Diary',
        'description': 'Mathematics class notes updated for Class 10',
        'time': '6 hours ago',
        'icon': Icons.book,
        'color': Colors.red,
      },
    ];
    return activities[index];
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activity['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          activity['icon'],
          color: activity['color'],
        ),
      ),
      title: Text(
        activity['title'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(activity['description']),
      trailing: Text(
        activity['time'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
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

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final branches = jsonDecode(branchesJson) as List<dynamic>;
    final boards = jsonDecode(boardsJson) as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) {
          final filters = dialogRef.watch(filterProvider);

          List<dynamic> availableBoards = filters['branch'] != null
              ? boards
                  .where((board) => (board['assignedBranches'] as List)
                      .contains(filters['branch']))
                  .toList()
              : [];

          List<dynamic> availableClasses = filters['board'] != null
              ? (boards.firstWhere(
                      (board) => board['boardId'] == filters['board'],
                      orElse: () => {'classes': []})['classes'] as List)
                  .toList()
              : [];

          List<dynamic> availableSections = filters['grade'] != null &&
                  filters['branch'] != null
              ? (availableClasses.firstWhere(
                      (cls) => cls['classId'] == filters['grade'],
                      orElse: () => {'sections': []})['sections'] as List)
                  .where((section) => section['branchId'] == filters['branch'])
                  .toList()
              : [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Header remains the same)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch filter (single select)
                        _buildFilterSection(
                          title: 'Branch',
                          items:
                              branches.map((b) => b['key'] as String).toList(),
                          displayItems:
                              branches.map((b) => b['name'] as String).toList(),
                          selectedItem: filters['branch'] as String?,
                          selectedItems: const [],
                          onSelected: (value) {
                            dialogRef.read(filterProvider.notifier).state = {
                              'branch':
                                  value == filters['branch'] ? null : value,
                              'board': null,
                              'grade': null,
                              'section': <String>[],
                            };
                          },
                          isMultiSelect: false,
                        ),
                        if (filters['branch'] != null) ...[
                          const SizedBox(height: 24),
                          // Board filter (single select)
                          _buildFilterSection(
                            title: 'Board',
                            items: availableBoards
                                .map((b) => b['boardId'] as String)
                                .toList(),
                            displayItems: availableBoards
                                .map((b) => b['boardName'] as String)
                                .toList(),
                            selectedItem: filters['board'] as String?,
                            selectedItems: const [],
                            onSelected: (value) {
                              dialogRef.read(filterProvider.notifier).state = {
                                ...filters,
                                'board':
                                    value == filters['board'] ? null : value,
                                'grade': null,
                                'section': <String>[],
                              };
                            },
                            isMultiSelect: false,
                          ),
                        ],
                        if (filters['board'] != null) ...[
                          const SizedBox(height: 24),
                          // Grade filter (single select)
                          _buildFilterSection(
                            title: 'Grade',
                            items: availableClasses
                                .map((c) => c['classId'] as String)
                                .toList(),
                            displayItems: availableClasses
                                .map((c) => c['className'] as String)
                                .toList(),
                            selectedItem: filters['grade'] as String?,
                            selectedItems: const [],
                            onSelected: (value) {
                              dialogRef.read(filterProvider.notifier).state = {
                                ...filters,
                                'grade':
                                    value == filters['grade'] ? null : value,
                                'section': <String>[],
                              };
                            },
                            isMultiSelect: false,
                          ),
                        ],
                        if (filters['grade'] != null) ...[
                          const SizedBox(height: 24),
                          // Section filter (multi select)
                          _buildFilterSection(
                            title: 'Section',
                            items: availableSections
                                .map((s) => s['sectionId'] as String)
                                .toList(),
                            displayItems: availableSections
                                .map((s) => s['sectionName'] as String)
                                .toList(),
                            selectedItem: null,
                            selectedItems: filters['section'] as List<String>,
                            onSelected: (value) {
                              final currentSections =
                                  List<String>.from(filters['section']);
                              if (currentSections.contains(value)) {
                                currentSections.remove(value);
                              } else {
                                currentSections.add(value);
                              }
                              print(
                                  'New sections: $currentSections'); // Add this
                              dialogRef.read(filterProvider.notifier).state = {
                                ...filters,
                                'section': currentSections,
                              };
                            },
                            isMultiSelect: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // ... (Buttons remain the same)
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          dialogRef.read(filterProvider.notifier).state = {
                            'branch': null,
                            'board': null,
                            'grade': null,
                            'section': <String>[],
                          };
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final currentFilters = ref.read(filterProvider);
                          print('Applied filters: $currentFilters');
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> displayItems,
    String? selectedItem,
    required List<String> selectedItems,
    required Function(String) onSelected,
    required bool isMultiSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text('No options available')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final displayName = displayItems[index];
              final isSelected = isMultiSelect
                  ? selectedItems.contains(item)
                  : selectedItem == item;

              return FilterChip(
                label: Text(displayName),
                selected: isSelected,
                onSelected: (_) => onSelected(item),
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
