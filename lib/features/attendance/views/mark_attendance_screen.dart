import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/providers/filter_provider.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _students = [];
  String _searchQuery = '';
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true; // Show loader
    });
    final filterState = ref.read(filterStateProvider); // Access saved filters
    final sectionId =
        filterState.section.isNotEmpty ? filterState.section[0] : null;

    if (sectionId == null) {
      setState(() {
        _students.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No section selected in filters')),
      );
      setState(() {
        _isLoading = false; // Hide loader
      });
      return;
    }

    final currentDate = DateTime.now().toIso8601String(); // Use current date

    final payload = {
      "sectionId": sectionId,
      "date": currentDate,
    };

    try {
      final apiService = ApiService();
      final response =
          await apiService.post('attendance/get?limit=100000&page=1', payload);
      if (response['status'] == true) {
        setState(() {
          _students.clear();
          _students.addAll((response['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to fetch data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  Future<void> _saveAttendance() async {
    setState(() {
      _isLoading = true; // Show loader
    });
    final filterState = ref.read(filterStateProvider);
    final sectionId =
        filterState.section.isNotEmpty ? filterState.section[0] : null;

    final branchId = filterState.branch;
    final boardId = filterState.board;
    final classId = filterState.grade;

    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];
    if (sectionId == null || academicYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section or Academic Year not selected')),
      );
      setState(() {
        _isLoading = false; // Hide loader
      });
      return;
    }

    final currentDate = DateTime.now().toUtc().toIso8601String();
    final studentsInfo = _students
        .where((student) =>
            student['attendanceState'] != 'P' &&
            student['attendanceState'] != null)
        .map((student) => {
              "user_id": student['user_id'],
              "attendanceState": student['attendanceState'] == 'A' ? 'A' : 'HD',
            })
        .toList();
    final presentStudentsInfo = _students
        .where((student) => student['attendanceState'] == 'P')
        .map((student) => student['user_id'])
        .toList(); // Convert to List

    final payload = {
      "branchId": branchId,
      "boardId": boardId,
      "classId": classId,
      "sectionId": sectionId,
      "academicYear": academicYear,
      "date": currentDate,
      "presentStudentsInfo": presentStudentsInfo,
      "studentsInfo": studentsInfo,
    };

    try {
      final apiService = ApiService();
      final response = await apiService.post('attendance/save', payload);
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to save attendance')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  Future<void> _showAttendancePreview() async {
    final presentCount =
        _students.where((student) => student['attendanceState'] == 'P').length;
    final absentCount =
        _students.where((student) => student['attendanceState'] == 'A').length;
    final halfDayCount =
        _students.where((student) => student['attendanceState'] == 'HD').length;
    final totalStudents = _students.length;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.preview_outlined,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        count: halfDayCount,
                        total: totalStudents,
                        label: 'Half Day',
                        color: Colors.orange,
                        icon: Icons.timelapse_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        count: absentCount,
                        total: totalStudents,
                        label: 'Absent',
                        color: Colors.red,
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  count: presentCount,
                  total: totalStudents,
                  label: 'Present',
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  isWide: true,
                ),

                const SizedBox(height: 24),

                // Summary Text
                Text(
                  'Total Students: $totalStudents',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      await _saveAttendance();
    }
  }

  Widget _buildStatCard({
    required int count,
    required int total,
    required String label,
    required Color color,
    required IconData icon,
    bool isWide = false,
  }) {
    final percentage = (count / total * 100).toStringAsFixed(1);

    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Here',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildAttendanceOption(
    Map<String, dynamic> student,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Checkbox(
          value: student['attendanceState'] == value,
          onChanged: (bool? selected) {
            setState(() {
              student['attendanceState'] = selected == true ? value : null;
            });
          },
          activeColor: color,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> filteredStudents) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          student['given_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID ${student['enrollmentId']}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAttendanceOption(
                        student,
                        'P',
                        'Present',
                        Colors.green,
                      ),
                      _buildAttendanceOption(
                        student,
                        'A',
                        'Absent',
                        Colors.red,
                      ),
                      _buildAttendanceOption(
                        student,
                        'HD',
                        'Half day',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students
        .where((student) => student['given_name']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text(
              'Mark Attendance',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save_rounded),
                onPressed: _showAttendancePreview,
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 242, 243, 243),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                _buildSearchField(),
                Expanded(
                  child: _buildStudentList(filteredStudents),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FilterButtonWidget(
              openBottomSheet: true,
              showSections: true,
              onFilterApplied: _fetchAttendanceData,
              isSingleSectionsSelection: true,
            ),
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
}
