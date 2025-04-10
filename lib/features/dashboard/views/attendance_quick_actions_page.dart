import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceQuickActionsPage extends ConsumerStatefulWidget {
  const AttendanceQuickActionsPage({super.key});

  @override
  ConsumerState<AttendanceQuickActionsPage> createState() =>
      _AttendanceQuickActionsPageState();
}

class _AttendanceQuickActionsPageState
    extends ConsumerState<AttendanceQuickActionsPage> {
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _originalData; // Store the original data
  bool _isLoading = false;
  bool _isInitialized = false;
  String _selectedTimeframe = 'weekly'; // Default to weekly

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _fetchDashboardData();
      _isInitialized = true;
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];
    final payload = {"academicYear": academicYear};

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'sisDashboard/get-dashboard',
        payload,
      );

      setState(() {
        _originalData = response['data']['data']; // Store the original data
        _dashboardData =
            _applyFilters(_originalData!, ref.watch(filterStateProvider));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _applyFilters(
      Map<String, dynamic> data, dynamic filterState) {
    final branchId = filterState.branch;
    final boardId = filterState.board;
    final gradeId = filterState.grade;

    if (branchId != null) {
      final branch = data['branches']?.firstWhere(
        (branch) => branch['branchId'] == branchId,
        orElse: () => null,
      );
      if (branch == null) return null;

      if (boardId != null) {
        final board = branch['boards']?.firstWhere(
          (board) => board['boardId'] == boardId,
          orElse: () => null,
        );
        if (board == null) return null;

        if (gradeId != null) {
          final grade = board['classes']?.firstWhere(
            (grade) => grade['classId'] == gradeId,
            orElse: () => null,
          );
          return grade?['dashboardData'];
        }

        return board['boardData'];
      }

      return branch['branchData'];
    }

    return data['dashboardData'];
  }

  void _onFilterApplied() {
    setState(() {
      _dashboardData =
          _applyFilters(_originalData!, ref.watch(filterStateProvider));
    });
  }

  List<BarChartGroupData> _getAttendanceBarChartData() {
    if (_dashboardData == null) return [];

    final chartData = _dashboardData?['charts']?['attendanceOverview'];
    final labels = chartData?[_selectedTimeframe]?['labels'] ?? [];
    final data = chartData?[_selectedTimeframe]?['data']?[0] ?? [];

    return List.generate(labels.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index]?.toDouble() ?? 0,
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    });
  }

  Widget _buildAttendanceBarChart() {
    final barChartData = _getAttendanceBarChartData();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (barChartData.isEmpty)
              const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 350, // Increased height for rotated labels
                child: BarChart(
                  BarChartData(
                    barGroups: barChartData,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final labels = _dashboardData?['charts']
                                        ?['attendanceOverview']
                                    ?[_selectedTimeframe]?['labels'] ??
                                [];
                            if (value.toInt() < labels.length) {
                              return Transform.rotate(
                                angle: -45 * 3.14159 / 180, // Rotate labels
                                child: Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Weekly'),
                  selected: _selectedTimeframe == 'weekly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeframe = 'weekly';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Monthly'),
                  selected: _selectedTimeframe == 'monthly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeframe = 'monthly';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Yearly'),
                  selected: _selectedTimeframe == 'yearly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeframe = 'yearly';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_dashboardData != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                            'Total Students',
                            _dashboardData?['summaryCards']?['totalStudents']
                                    ?.toString() ??
                                'N/A',
                            Colors.blue,
                          ),
                          _buildSummaryCard(
                            'Present Today',
                            (_dashboardData?['summaryCards']?['attendance']
                                        is List &&
                                    (_dashboardData?['summaryCards']
                                            ?['attendance'] as List)
                                        .isNotEmpty)
                                ? (_dashboardData?['summaryCards']
                                            ?['attendance']?[0]?['totalPresent']
                                        ?.toString() ??
                                    'N/A')
                                : 'N/A',
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAttendanceBarChart(),
                    ] else
                      const Center(
                        child: Text('No data available'),
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FilterButtonWidget(
        showSections: false,
        isSingleSectionsSelection: false,
        onFilterApplied: _onFilterApplied, // Use the local filter method
      ),
    );
  }
}
