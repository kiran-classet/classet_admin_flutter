import 'package:flutter/material.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
// import 'package:intl/intl.dart'; // Add for date formatting
import 'package:classet_admin/core/services/api_service.dart'; // Add for API service

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _students =
      []; // Update to store student details
  String _searchQuery = '';
  final Map<String, dynamic> _filters = {
    'branch': null,
    'board': null,
    'grade': null,
    'section': <String>[],
  };

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData(); // Fetch data on screen load
  }

  Future<void> _fetchAttendanceData() async {
    // if (_filters['section'] != null && _filters['section'].isNotEmpty) {
    // final sectionId = _filters['section'].first;
    final sectionId = "c8e11add-1285-4b7a-b1e0-fc41604b5de7";

    final currentDate = "2025-04-08T08:03:14.330Z";

    // DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now());
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
          // Ensure response['data'] is cast to List<Map<String, dynamic>>
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
    // }
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
        title: const Text('Mark Attendance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Students',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return ListTile(
                  title: Text(student['given_name']),
                  subtitle: Text('Enrollment ID: ${student['enrollmentId']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: 'Present',
                        groupValue: student['attendanceState'],
                        onChanged: (value) {
                          setState(() {
                            student['attendanceState'] = value;
                          });
                        },
                      ),
                      const Text('Present'),
                      Radio(
                        value: 'Absent',
                        groupValue: student['attendanceState'],
                        onChanged: (value) {
                          setState(() {
                            student['attendanceState'] = value;
                          });
                        },
                      ),
                      const Text('Absent'),
                      Radio(
                        value: 'Half Day',
                        groupValue: student['attendanceState'],
                        onChanged: (value) {
                          setState(() {
                            student['attendanceState'] = value;
                          });
                        },
                      ),
                      const Text('Half Day'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FilterButtonWidget(
        openBottomSheet: true,
        showSections: true, // Show sections in Mark Attendance screen
        onFilterApplied: () {
          _fetchAttendanceData(); // Fetch data when filters are applied
        },
        isSingleSectionsSelection: true, // Pass the flag as true
      ),
    );
  }
}
