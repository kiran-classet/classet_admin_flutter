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
  Map<String, dynamic>?
      _originalDashboardData; // Store original data for filtering
  bool _isLoading = false;
  bool _isInitialized = false; // Track initialization
  String _selectedTimeframe = 'monthly'; // Default to monthly
  String _selectedPaymentModeMetric = 'amount'; // Default to amounts
  String _selectedConcessionMetric = 'amount'; // Default to counts

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

    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];
    final payload = {"academicYear": academicYear};

    try {
      final apiService = ApiService();
      final response =
          await apiService.post('financeDashboard/get-dashboard', payload);

      // Store the original data for local filtering
      setState(() {
        _originalDashboardData = response['data']['data'];
        _dashboardData = _applyFilters(
            _originalDashboardData!, ref.watch(filterStateProvider));
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

    // Return organization-level data if no filters are applied
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
            color: const Color.fromARGB(255, 4, 136, 243),
            width: 16,
          ),
        ],
      );
    });
  }

  List<PieChartSectionData> _getPieChartData() {
    if (_dashboardData == null) return [];

    final paymentModes = _dashboardData?['charts']?['paymentModes'];
    final labels = paymentModes?['labels'] ?? [];
    final details = paymentModes?['details'] ?? {};

    return List.generate(labels.length, (index) {
      final label = labels[index]; // Use the label as-is
      final key = label
          .toLowerCase()
          .replaceAll(' ', '_'); // Convert to match the details key format
      final value = _selectedPaymentModeMetric == 'amount'
          ? (details[key]?['amount'] ?? 0) // Default to 0 if missing
          : (details[key]?['count'] ?? 0); // Default to 0 if missing

      // Ensure a small placeholder value for sections with 0 value
      final displayValue = value > 0 ? value.toDouble() : 0.01;

      return PieChartSectionData(
        value: displayValue,
        title:
            value > 0 ? value.toString() : '', // Show title only if value > 0
        color: _getColorForIndex(index),
        radius: 140,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<PieChartSectionData> _getConcessionsPieChartData() {
    if (_dashboardData == null) return [];

    final concessions = _dashboardData?['charts']?['concessions'];
    final labels = concessions?['labels'] ?? [];
    final details = concessions?['details'] ?? {};

    return List.generate(labels.length, (index) {
      final label = labels[index].toLowerCase(); // Convert label to lowercase
      final value = _selectedConcessionMetric == 'amount'
          ? (details[label]?['amount'] ?? 0) // Default to 0 if missing
          : (details[label]?['count'] ?? 0); // Default to 0 if missing

      // Ensure a small placeholder value for sections with 0 value
      final displayValue = value > 0 ? value.toDouble() : 0.01;

      return PieChartSectionData(
        value: displayValue,
        title: value > 0
            ? value.toInt().toString()
            : '', // Show title only if value > 0
        color: _getColorForIndex(index),
        radius: 140,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  // Helper method to assign colors to pie chart sections
  Color _getColorForIndex(int index) {
    const colors = [
      Color.fromARGB(255, 26, 7, 240), // Blue
      Color.fromARGB(255, 195, 149, 248), // Green
      Color.fromARGB(255, 87, 91, 104), // Orange
      Color.fromARGB(255, 209, 3, 245), // Purple
      Color.fromARGB(255, 125, 6, 244), // Red
      Color.fromARGB(255, 3, 243, 219),
    ];
    return colors[index % colors.length];
  }

  Widget _buildBarChartCard() {
    final barChartData = _getBarChartData();

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
              'Fee Collection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Add spacing between title and chart
            if (barChartData.isEmpty)
              const Center(
                child: Text(
                  'Reports not found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              SizedBox(
                height: 300, // Set a fixed height for the chart
                child: BarChart(
                  BarChartData(
                    barGroups: barChartData,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1000000,
                          getTitlesWidget: (value, meta) {
                            String formattedValue;
                            if (value >= 1000000) {
                              formattedValue =
                                  '${(value / 1000000).toStringAsFixed(1)}M';
                            } else if (value >= 1000) {
                              formattedValue =
                                  '${(value / 1000).toStringAsFixed(1)}K';
                            } else {
                              formattedValue = value.toInt().toString();
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
            if (barChartData.isNotEmpty)
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

  Widget _buildLegend() {
    final paymentModes = _dashboardData?['charts']?['paymentModes'];
    final labels = paymentModes?['labels'] ?? [];
    final details = paymentModes?['details'] ?? {};

    return Wrap(
      spacing: 8.0, // Spacing between items
      runSpacing: 8.0, // Spacing between rows
      children: List.generate(labels.length, (index) {
        final label = labels[index];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color:
                    _getColorForIndex(index), // Use the color for the section
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4), // Spacing between color and label
            Text(
              '$label',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildConcessionsLegend() {
    final concessions = _dashboardData?['charts']?['concessions'];
    final labels = concessions?['labels'] ?? [];
    final details = concessions?['details'] ?? {};

    return Wrap(
      spacing: 8.0, // Spacing between items
      runSpacing: 8.0, // Spacing between rows
      children: List.generate(labels.length, (index) {
        final label = labels[index];
        final value = _selectedConcessionMetric == 'amount'
            ? (details[label.toLowerCase()]?['amount'] ?? 0)
            : (details[label.toLowerCase()]?['count'] ?? 0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color:
                    _getColorForIndex(index), // Use the color for the section
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4), // Spacing between color and label
            Text(
              // '$label: ${_selectedConcessionMetric == 'amount' ? formatIndianRupees(value) : value}',
              '$label',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPieChartCard() {
    final pieChartData = _getPieChartData();

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
              'Payment Modes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Add spacing between title and chart
            if (pieChartData.isEmpty)
              const Center(
                child: Text(
                  'Reports not found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              SizedBox(
                height: 300, // Set a fixed height for the chart
                child: PieChart(
                  PieChartData(
                    sections: pieChartData,
                    centerSpaceRadius: 0,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            const SizedBox(height: 16), // Add spacing between chart and legend
            if (pieChartData.isNotEmpty)
              _buildLegend(), // Add the legend below the chart
            const SizedBox(
                height: 16), // Add spacing between legend and filters
            if (pieChartData.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Amount'),
                    selected: _selectedPaymentModeMetric == 'amount',
                    onSelected: (selected) {
                      setState(() {
                        _selectedPaymentModeMetric = 'amount';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Count'),
                    selected: _selectedPaymentModeMetric == 'count',
                    onSelected: (selected) {
                      setState(() {
                        _selectedPaymentModeMetric = 'count';
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

  Widget _buildConcessionsPieChartCard() {
    final concessionsPieChartData = _getConcessionsPieChartData();

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
              'Concessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Add spacing between title and chart
            if (concessionsPieChartData.isEmpty)
              const Center(
                child: Text(
                  'Reports not found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              SizedBox(
                height: 300, // Set a fixed height for the chart
                child: PieChart(
                  PieChartData(
                    sections: concessionsPieChartData,
                    centerSpaceRadius: 0,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            const SizedBox(height: 16), // Add spacing between chart and legend
            if (concessionsPieChartData.isNotEmpty)
              _buildConcessionsLegend(), // Add the legend below the chart
            const SizedBox(
                height: 16), // Add spacing between legend and filters
            if (concessionsPieChartData.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Amount'),
                    selected: _selectedConcessionMetric == 'amount',
                    onSelected: (selected) {
                      setState(() {
                        _selectedConcessionMetric = 'amount';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Count'),
                    selected: _selectedConcessionMetric == 'count',
                    onSelected: (selected) {
                      setState(() {
                        _selectedConcessionMetric = 'count';
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
            title: const Text('Fee Reports'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _fetchDashboardData(); // Call the API to refresh data
            },
            child: SingleChildScrollView(
              // Wrap the content in a scrollable view
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensure pull-to-refresh works even when content is less
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
                            'Fee Collected',
                            _dashboardData?['summaryCards']?['feeCollection']
                                    ?.toString() ??
                                'N/A',
                            Colors.green,
                          ),
                          _buildSummaryCard(
                            'Concession',
                            _dashboardData?['summaryCards']?['feeConcession']
                                    ?.toString() ??
                                'N/A',
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBarChartCard(), // Add the bar chart card here
                      const SizedBox(
                          height: 16), // Add spacing between sections
                      _buildPieChartCard(), // Add the payment modes pie chart card
                      const SizedBox(height: 16), // Add spacing between charts
                      _buildConcessionsPieChartCard(), // Add the concessions pie chart card
                      const SizedBox(height: 16),
                    ],
                    if (!_isLoading && _dashboardData == null)
                      const Text('No data available for the selected filters.'),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FilterButtonWidget(
            showSections: false,
            isSingleSectionsSelection: false,
            onFilterApplied: () {
              setState(() {
                _dashboardData = _applyFilters(
                    _originalDashboardData!, ref.watch(filterStateProvider));
              });
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

  String formatIndianRupees(dynamic amount) {
    if (amount == null) return '₹0';

    double numericAmount =
        amount is String ? double.tryParse(amount) ?? 0 : amount.toDouble();

    RegExp regex = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
    String formattedAmount = numericAmount
        .toStringAsFixed(0)
        .replaceAllMapped(regex, (Match match) => '${match[1]},');

    return '₹$formattedAmount';
  }

  Widget _buildSummaryCard(String title, dynamic value, Color color) {
    String displayValue = value is num || value is String
        ? formatIndianRupees(value)
        : value.toString();

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
}
