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

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
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
    }
  }

  Future<void> _saveAttendance() async {
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
    }
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Mark Attendance',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveAttendance,
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
    );
  }
}
