import 'package:classet_admin/features/attendance/views/mark_attendance_screen.dart';
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

  List<PieChartSectionData> _getStudentTypesPieChartData() {
    if (_dashboardData == null) return [];

    final studentTypes =
        _dashboardData?['charts']?['studentTypes']?['types'] ?? [];
    final total = _dashboardData?['charts']?['studentTypes']?['total'] ?? 1;

    return studentTypes.map<PieChartSectionData>((type) {
      final count = type['count'] ?? 0;
      final percentage = (count / total) * 100;

      return PieChartSectionData(
        value: count.toDouble(),
        title:
            '$count (${percentage.toStringAsFixed(0)}%)', // Show count and percentage
        color: type['name'] == 'Day Scholar' ? Colors.blue : Colors.orange,
        radius: 140, // Increased radius
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }).toList();
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

  Widget _buildStudentTypesPieChart() {
    final pieChartData = _getStudentTypesPieChartData();

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
              'Student Types Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (pieChartData.isEmpty)
              const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: pieChartData,
                        centerSpaceRadius: 0,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPieChartLegends(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartLegends() {
    if (_dashboardData == null) return const SizedBox.shrink();

    final studentTypes =
        _dashboardData?['charts']?['studentTypes']?['types'] ?? [];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: studentTypes.map<Widget>((type) {
        final color =
            type['name'] == 'Day Scholar' ? Colors.blue : Colors.orange;
        final name = type['name'] ?? 'Unknown';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDailyAbsenteeTable() {
    final dailyAbsentee =
        _dashboardData?['summaryCards']?['dailyAbsentee']?['sections'] ?? [];

    if (dailyAbsentee.isEmpty) {
      return const Center(
        child: Text(
          'No absentee data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Card(
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
              'Daily Absentee Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Section')),
                  DataColumn(label: Text('Total Strength')),
                  DataColumn(label: Text('Present Count')),
                  DataColumn(label: Text('Absent Count')),
                ],
                rows: dailyAbsentee.map<DataRow>((section) {
                  return DataRow(
                    cells: [
                      DataCell(Text(section['className'] ?? 'N/A')),
                      DataCell(Text(section['sectionName'] ?? 'N/A')),
                      DataCell(
                          Text(section['totalStrength']?.toString() ?? 'N/A')),
                      DataCell(
                          Text(section['presentCount']?.toString() ?? 'N/A')),
                      DataCell(
                          Text(section['absentCount']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, dynamic value, Color color) {
    String displayValue = value.toString();

    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (label == 'Mark Attendance') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MarkAttendanceScreen()),
          );
        } else if (label == 'View Individual Student' ||
            label == 'Send Notifications') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label: Coming Soon'),
              duration: Duration(seconds: 1), // Show snackbar for 3 seconds
            ),
          );
        } else {
          print('$label clicked');
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
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh:
                  _fetchDashboardData, // Trigger API call on pull-to-refresh
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Ensure scrollable even if content is small
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_dashboardData != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                  ?['attendance']?[0]
                                              ?['totalPresent']
                                          ?.toString() ??
                                      'N/A')
                                  : 'N/A',
                              Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildAttendanceBarChart(),
                        const SizedBox(height: 16),
                        _buildStudentTypesPieChart(),
                        const SizedBox(height: 16),
                        _buildDailyAbsenteeTable(),
                      ] else
                        const Center(
                          child: Text('No data available'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FilterButtonWidget(
              showSections: false,
              isSingleSectionsSelection: false,
              onFilterApplied: _onFilterApplied, // Use the local filter method
            ),
          ),
          Positioned(
            bottom: 70, // Adjust to position above the filter button
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MarkAttendanceScreen()),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }
}
