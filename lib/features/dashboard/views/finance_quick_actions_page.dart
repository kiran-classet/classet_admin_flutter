import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart'; // Import for bar chart

class FinanceQuickActionsPage extends ConsumerStatefulWidget {
  const FinanceQuickActionsPage({super.key});

  @override
  ConsumerState<FinanceQuickActionsPage> createState() =>
      _FinanceQuickActionsPageState();
}

class _FinanceQuickActionsPageState
    extends ConsumerState<FinanceQuickActionsPage> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  bool _isInitialized = false; // Track initialization
  String _selectedTimeframe = 'monthly'; // Default to monthly

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _fetchDashboardData();
      _isInitialized = true; // Ensure this is only called once
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final filterState = ref.watch(filterStateProvider);
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];
    final payload = {"academicYear": academicYear};

    try {
      final apiService = ApiService();
      final response =
          await apiService.post('financeDashboard/get-dashboard', payload);

      // Apply filters to the response
      final filteredData = _applyFilters(response['data']['data'], filterState);

      setState(() {
        _dashboardData = filteredData;
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
    // Extract filters
    final branchId = filterState.branch;
    final boardId = filterState.board;
    final gradeId = filterState.grade;

    // Filter by branch
    if (branchId != null) {
      final branch = data['branches']?.firstWhere(
        (branch) => branch['branchId'] == branchId,
        orElse: () => null,
      );
      if (branch == null) return null;

      // Filter by board
      if (boardId != null) {
        final board = branch['boards']?.firstWhere(
          (board) => board['boardId'] == boardId,
          orElse: () => null,
        );
        if (board == null) return null;

        // Filter by grade
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

    // Return top-level data if no filters are applied
    return data['dashboardData'];
  }

  List<BarChartGroupData> _getBarChartData() {
    if (_dashboardData == null) return [];

    final charts = _dashboardData?['charts']?['feeCollection'];
    final labels = charts?[_selectedTimeframe]?['labels'] ?? [];
    final data = charts?[_selectedTimeframe]?['data']?[0] ?? [];

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

  Widget _buildBarChartCard() {
    return Card(
      elevation: 8, // Add elevation for shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fee Collection Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Add spacing between title and chart
            SizedBox(
              height: 300, // Set a fixed height for the chart
              child: BarChart(
                BarChartData(
                  barGroups: _getBarChartData(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, // Show the left side (Y-axis)
                        interval:
                            1000000, // Adjust the interval for Y-axis labels
                        getTitlesWidget: (value, meta) {
                          // Format the value for better readability
                          String formattedValue;
                          if (value >= 1000000) {
                            formattedValue =
                                '${(value / 1000000).toStringAsFixed(1)}M'; // e.g., 1.5M
                          } else if (value >= 1000) {
                            formattedValue =
                                '${(value / 1000).toStringAsFixed(1)}K'; // e.g., 1.2K
                          } else {
                            formattedValue =
                                value.toInt().toString(); // e.g., 500
                          }

                          return Text(
                            formattedValue,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final charts =
                              _dashboardData?['charts']?['feeCollection'];
                          final labels =
                              charts?[_selectedTimeframe]?['labels'] ?? [];
                          if (value.toInt() < labels.length) {
                            return Text(labels[value.toInt()]);
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
            const SizedBox(height: 16), // Add spacing between chart and filters
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  label: const Text('Daily'),
                  selected: _selectedTimeframe == 'daily',
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeframe = 'daily';
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Finance Management'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_dashboardData != null) ...[
                  _buildBarChartCard(), // Add the bar chart card here
                  const SizedBox(
                      height:
                          16), // Add spacing between chart and summary cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard(
                        'Fee Collected',
                        _dashboardData?['summaryCards']?['feeCollection']
                                ?.toString() ??
                            'N/A',
                        Colors.green,
                      ),
                      _buildSummaryCard(
                        'Total Concession',
                        _dashboardData?['summaryCards']?['feeConcession']
                                ?.toString() ??
                            'N/A',
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        label: const Text('Daily'),
                        selected: _selectedTimeframe == 'daily',
                        onSelected: (selected) {
                          setState(() {
                            _selectedTimeframe = 'daily';
                          });
                        },
                      ),
                    ],
                  ),
                ],
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_dashboardData == null)
                  const Text('No data available for the selected filters.'),
              ],
            ),
          ),
          floatingActionButton: FilterButtonWidget(
            showSections: false,
            isSingleSectionsSelection: false,
            onFilterApplied: () {
              _fetchDashboardData(); // Re-fetch data when filters are applied
            },
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label: Coming Soon'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Material(
        elevation: 4,
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
