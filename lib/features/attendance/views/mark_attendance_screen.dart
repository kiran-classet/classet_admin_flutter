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

  Widget _buildSearchField() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Students',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildAttendanceOption(
    Map<String, dynamic> student,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: student['attendanceState'] == value,
        label: Text(
          label,
          style: TextStyle(
            color: student['attendanceState'] == value
                ? Colors.white
                : Colors.black87,
            fontSize: 12,
          ),
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: color,
        onSelected: (bool selected) {
          setState(() {
            student['attendanceState'] = selected ? value : null;
          });
        },
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> filteredStudents) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            // by default, the ExpansionTile is to be expanded
            initiallyExpanded: true,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                student['given_name'][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              student['given_name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'ID: ${student['enrollmentId']}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttendanceOption(
                      student,
                      'Present',
                      'Present',
                      Colors.green,
                    ),
                    _buildAttendanceOption(
                      student,
                      'Absent',
                      'Absent',
                      Colors.red,
                    ),
                    _buildAttendanceOption(
                      student,
                      'Half Day',
                      'Half Day',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
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
