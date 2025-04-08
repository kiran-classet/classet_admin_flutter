import 'package:flutter/material.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _students = ['kiran', 'madhu', 'venu'];
  String _searchQuery = '';
  // Add filter state
  final Map<String, dynamic> _filters = {
    'branch': null,
    'board': null,
    'grade': null,
    'section': <String>[],
  };

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students
        .where((student) =>
            student.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                  title: Text(student),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: 'Present',
                        groupValue:
                            null, // Replace with actual state management
                        onChanged: (value) {
                          // Handle Present selection
                        },
                      ),
                      const Text('Present'),
                      Radio(
                        value: 'Absent',
                        groupValue:
                            null, // Replace with actual state management
                        onChanged: (value) {
                          // Handle Absent selection
                        },
                      ),
                      const Text('Absent'),
                      Radio(
                        value: 'Half Day',
                        groupValue:
                            null, // Replace with actual state management
                        onChanged: (value) {
                          // Handle Half Day selection
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
        showSections: true, // Show sections in Mark Attendance screen
        onFilterApplied: () {
          print('Applied filters: $_filters');
        },
      ),
    );
  }
}
