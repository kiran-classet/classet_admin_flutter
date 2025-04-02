import 'package:flutter/material.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Approvals',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildApprovalList(ApprovalStatus.pending),
                  _buildApprovalList(ApprovalStatus.approved),
                  _buildApprovalList(ApprovalStatus.rejected),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Handle creating new approval request
        },
        tooltip: 'Create New Request',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildApprovalList(ApprovalStatus status) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Replace with actual data length
      itemBuilder: (context, index) {
        return _ApprovalCard(
          title: 'Leave Request',
          requesterName: 'John Doe',
          requestDate: '2024-01-${index + 1}',
          type: 'Sick Leave',
          status: status,
          onApprove: () => _handleApprove(index),
          onReject: () => _handleReject(index),
        );
      },
    );
  }

  void _handleApprove(int index) {
    // TODO: Implement approval logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Approved')),
    );
  }

  void _handleReject(int index) {
    // TODO: Implement rejection logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Rejected')),
    );
  }
}

enum ApprovalStatus { pending, approved, rejected }

class _ApprovalCard extends StatelessWidget {
  final String title;
  final String requesterName;
  final String requestDate;
  final String type;
  final ApprovalStatus status;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.title,
    required this.requesterName,
    required this.requestDate,
    required this.type,
    required this.status,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, requesterName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, requestDate),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category, type),
            if (status == ApprovalStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onReject,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ApprovalStatus status) {
    Color color;
    String text;

    switch (status) {
      case ApprovalStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case ApprovalStatus.approved:
        color = Colors.green;
        text = 'Approved';
        break;
      case ApprovalStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
