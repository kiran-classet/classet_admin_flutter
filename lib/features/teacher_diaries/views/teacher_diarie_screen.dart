import 'package:flutter/material.dart';

class TeacherDiariesScreen extends StatefulWidget {
  const TeacherDiariesScreen({super.key});

  @override
  State<TeacherDiariesScreen> createState() => _TeacherDiariesScreenState();
}

class _TeacherDiariesScreenState extends State<TeacherDiariesScreen> {
  String selectedSubject = 'Mathematics';
  DateTime selectedDate = DateTime.now();
  final List<String> subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Physics'
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
                'Teacher Diary',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildDiaryStats(context),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              Expanded(
                child: _buildDiaryEntries(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Handle new diary entry
        },
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildDiaryStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '15', 'Classes\nToday'),
          _buildStatItem(context, '5', 'Pending\nTasks'),
          _buildStatItem(context, '8', 'Homework\nAssigned'),
          _buildStatItem(context, '3', 'Tests\nScheduled'),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedSubject,
            decoration: InputDecoration(
              labelText: 'Select Subject',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: subjects.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedSubject = newValue;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  const Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
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
          'Homework',
          Icons.assignment,
          () {
            // TODO: Navigate to homework section
          },
        ),
        _buildQuickActionButton(
          context,
          'Tests',
          Icons.quiz,
          () {
            // TODO: Navigate to tests section
          },
        ),
        _buildQuickActionButton(
          context,
          'Notes',
          Icons.note_add,
          () {
            // TODO: Navigate to notes section
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

  Widget _buildDiaryEntries() {
    return Card(
      elevation: 2,
      child: ListView.builder(
        itemCount: 10, // Example count
        itemBuilder: (context, index) {
          return _buildDiaryEntry(
            'Class ${10 - index}A',
            'Topic: ${_getExampleTopic(index)}',
            _getExampleTime(index),
            _getExampleStatus(index),
          );
        },
      ),
    );
  }

  String _getExampleTopic(int index) {
    final topics = [
      'Quadratic Equations',
      'Linear Algebra',
      'Trigonometry',
      'Calculus',
      'Statistics'
    ];
    return topics[index % topics.length];
  }

  String _getExampleTime(int index) {
    final startHour = 8 + index;
    return '$startHour:00 - ${startHour + 1}:00';
  }

  String _getExampleStatus(int index) {
    final statuses = ['Completed', 'Pending', 'In Progress'];
    return statuses[index % statuses.length];
  }

  Widget _buildDiaryEntry(
      String className, String topic, String time, String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        statusIcon = Icons.timelapse;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(
              className,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(topic),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            // TODO: Handle menu item selection
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit Entry'),
            ),
            const PopupMenuItem<String>(
              value: 'notes',
              child: Text('Add Notes'),
            ),
            const PopupMenuItem<String>(
              value: 'homework',
              child: Text('Assign Homework'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete Entry'),
            ),
          ],
        ),
        onTap: () {
          // TODO: Handle diary entry tap
        },
      ),
    );
  }
}
