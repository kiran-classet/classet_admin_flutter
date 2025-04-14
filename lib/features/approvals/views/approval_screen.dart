import 'package:flutter/material.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'label': 'Fee Concession',
        'icon': Icons.discount, // Changed icon
        'route': '/feeConcession'
      },
      {
        'label': 'Fee Refund',
        'icon': Icons.attach_money,
        'route': '/feeRefund'
      },
      {
        'label': 'Fee Unassign',
        'icon': Icons.remove_circle_outline, // Changed icon
        'route': '/feeUnassign'
      },
      {
        'label': 'Student Transfers',
        'icon': Icons.transfer_within_a_station,
        'route': '/studentTransfers'
      },
      {
        'label': 'Student Status Change',
        'icon': Icons.person,
        'route': '/studentStatusChange'
      },
      {
        'label': 'Student Admission Category Change',
        'icon': Icons.category,
        'route': '/admissionCategoryChange'
      },
      {
        'label': 'Assign Transport',
        'icon': Icons.directions_bus,
        'route': '/assignTransport'
      },
      {
        'label': 'Transport Routes',
        'icon': Icons.map,
        'route': '/transportRoutes'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              context,
              action['label'] as String,
              action['icon'] as IconData,
              action['route'] as String,
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, String label, IconData icon, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
