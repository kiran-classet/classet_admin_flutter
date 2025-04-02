import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String selectedClass = 'Class 10-A';
  String selectedDay = 'Monday';

  final List<String> classes = ['Class 10-A', 'Class 9-A', 'Class 8-A'];
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timetable Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              Expanded(
                child: _buildTimetableView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Handle add new timetable entry
        },
        tooltip: 'Add New Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedClass,
            decoration: InputDecoration(
              labelText: 'Select Class',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: classes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedClass = newValue;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedDay,
            decoration: InputDecoration(
              labelText: 'Select Day',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: days.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedDay = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(
          context,
          'Copy Schedule',
          Icons.copy,
          () {
            // TODO: Implement copy schedule
          },
        ),
        _buildQuickActionButton(
          context,
          'Print',
          Icons.print,
          () {
            // TODO: Implement print
          },
        ),
        _buildQuickActionButton(
          context,
          'Share',
          Icons.share,
          () {
            // TODO: Implement share
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableView() {
    return Card(
      elevation: 2,
      child: ListView(
        children: [
          _buildTimeSlot(
              '08:00 - 09:00', 'Mathematics', 'John Smith', 'Room 101'),
          _buildTimeSlot(
              '09:00 - 10:00', 'Science', 'Sarah Johnson', 'Lab 201'),
          _buildTimeSlot('10:00 - 10:15', 'Break', '-', '-'),
          _buildTimeSlot('10:15 - 11:15', 'English', 'Mike Wilson', 'Room 102'),
          _buildTimeSlot('11:15 - 12:15', 'History', 'Emma Brown', 'Room 103'),
          _buildTimeSlot('12:15 - 13:15', 'Lunch Break', '-', '-'),
          _buildTimeSlot('13:15 - 14:15', 'Physics', 'David Clark', 'Lab 202'),
          _buildTimeSlot(
              '14:15 - 15:15', 'Computer Science', 'Lisa Anderson', 'Lab 301'),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
      String time, String subject, String teacher, String room) {
    bool isBreak = teacher == '-' && room == '-';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        color: isBreak ? Colors.grey[100] : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (!isBreak) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Teacher: $teacher',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Room: $room',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        trailing: !isBreak
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Handle edit time slot
                },
              )
            : null,
      ),
    );
  }
}
