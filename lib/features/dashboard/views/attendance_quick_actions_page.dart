import 'package:classet_admin/features/attendance/views/mark_attendance_screen.dart';
import 'package:flutter/material.dart';

class AttendanceQuickActionsPage extends StatelessWidget {
  const AttendanceQuickActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionItem(
                context, 'Mark Attendance', Icons.edit, Colors.green),
            _buildActionItem(context, 'View Individual Student', Icons.person,
                const Color.fromARGB(255, 97, 102, 107)),
            _buildActionItem(context, 'Send Notifications', Icons.notifications,
                const Color.fromARGB(255, 97, 102, 107)),
          ],
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
}
