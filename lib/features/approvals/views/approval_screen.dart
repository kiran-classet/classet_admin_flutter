import 'package:classet_admin/features/approvals/views/student_status_change_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'label': 'Student Status Change',
        'icon': Icons.person,
        'route': '/studentStatusChangeApproval',
        'color': const Color(0xFF009688),
      },
      {
        'label': 'Student Transfers',
        'icon': Icons.transfer_within_a_station,
        'route': '/studentTransfersApproval',
        'color': const Color(0xFF9C27B0),
      },
      {
        'label': 'Student Admission Category Change',
        'icon': Icons.category,
        'route': '/admissionCategoryChangeApproval',
        'color': const Color(0xFFFF9800),
      },
      {
        'label': 'Fee Concession',
        'icon': Icons.discount,
        'route': '/feeConcessionApproval',
        'color': const Color(0xFF4CAF50),
      },
      {
        'label': 'Fee Refund',
        'icon': Icons.attach_money,
        'route': '/feeRefundApproval',
        'color': const Color(0xFF2196F3),
      },
      {
        'label': 'Fee Unassign',
        'icon': Icons.remove_circle_outline,
        'route': '/feeUnassignApproval',
        'color': const Color(0xFFF44336),
      },
      {
        'label': 'Assign Transport',
        'icon': Icons.directions_bus,
        'route': '/assignTransportApproval',
        'color': const Color(0xFF795548),
      },
      {
        'label': 'Transport Routes',
        'icon': Icons.map,
        'route': '/transportRoutesApproval',
        'color': const Color(0xFF607D8B),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Approvals',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              context,
              action['label'] as String,
              action['icon'] as IconData,
              action['route'] as String,
              action['color'] as Color,
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          if (route == '/studentStatusChangeApproval') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentStatusChangeApprovalScreen(),
              ),
            );
          } else {
            context.go(route);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
