import 'package:classet_admin/features/attendance/views/mark_attendance_screen.dart';
import 'package:flutter/material.dart';

class AttendanceQuickActionsPage extends StatelessWidget {
  const AttendanceQuickActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Quick Actions'),
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
            _buildActionItem(
                context, 'View Individual Student', Icons.person, Colors.blue),
            _buildActionItem(context, 'Send Notifications', Icons.notifications,
                Colors.orange),
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
        } else {
          print('$label clicked');
        }
      },
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
    );
  }
}
