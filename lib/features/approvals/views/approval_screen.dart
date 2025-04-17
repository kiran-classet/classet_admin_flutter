import 'package:classet_admin/features/approvals/views/fee_concession_approval.dart';
import 'package:classet_admin/features/approvals/views/student_admission_cat_change.dart';
import 'package:classet_admin/features/approvals/views/student_status_change_approval_screen.dart';
import 'package:classet_admin/features/approvals/views/student_transfers_approval.dart';
import 'package:classet_admin/features/dashboard/views/attendance_quick_actions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'label': 'Student Status Change',
        'icon': Icons.person,
        'route': '/studentStatusChangeApproval',
        'color': const Color(0xFF00BCD4), // Vibrant Cyan
      },
      {
        'label': 'Student Transfers',
        'icon': Icons.transfer_within_a_station,
        'route': '/studentTransfersApproval',
        'color': const Color(0xFFFF5722), // Vibrant Orange
      },
      {
        'label': 'Admission Category Change',
        'icon': Icons.category,
        'route': '/admissionCategoryChangeApproval',
        'color': const Color(0xFFFFC107), // Vibrant Amber
      },
      {
        'label': 'Fee Concession',
        'icon': Icons.discount,
        'route': '/feeConcessionApproval',
        'color': const Color(0xFFFF4081), // Vibrant Pink
      },
      {
        'label': 'Fee Refund',
        'icon': Icons.attach_money,
        'route': '/feeRefundApproval',
        'color': const Color(0xFF3F51B5), // Vibrant Indigo
      },
      {
        'label': 'Fee Unassign',
        'icon': Icons.remove_circle_outline,
        'route': '/feeUnassignApproval',
        'color': const Color(0xFFFF5252), // Vibrant Red
      },
      {
        'label': 'Assign Transport',
        'icon': Icons.directions_bus,
        'route': '/assignTransportApproval',
        'color': const Color(0xFF8BC34A), // Vibrant Green
      },
      {
        'label': 'Transport Routes',
        'icon': Icons.map,
        'route': '/transportRoutesApproval',
        'color': const Color(0xFF673AB7), // Vibrant Deep Purple
      },
    ];

    final filteredActions = actions
        .where((action) => (action['label'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Approvals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 15,
                  childAspectRatio: 5,
                ),
                itemCount: filteredActions.length,
                itemBuilder: (context, index) {
                  final action = filteredActions[index];
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
          ),
        ],
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
          }
          if (route == '/admissionCategoryChangeApproval') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const StudentAdmissionChangeApprovalScreen(),
              ),
            );
          }
          if (route == '/studentTransfersApproval') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentTransfersApprovalScreen(),
              ),
            );
          }
          if (route == '/feeConcessionApproval') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FeeConcessionApprovalScreen(),
              ),
            );
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
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
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
