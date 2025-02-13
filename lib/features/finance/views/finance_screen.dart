import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({Key? key}) : super(key: key);

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
                'Finance Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildFinanceSummaryCards(context),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildFinanceCard(
                      context,
                      'Fee Collection',
                      'Manage and track student fees',
                      Icons.payments,
                      () {
                        // TODO: Navigate to fee collection
                      },
                    ),
                    _buildFinanceCard(
                      context,
                      'Expenses',
                      'Track and manage expenses',
                      Icons.money_off,
                      () {
                        // TODO: Navigate to expenses
                      },
                    ),
                    _buildFinanceCard(
                      context,
                      'Salary Management',
                      'Staff salary and payroll',
                      Icons.account_balance_wallet,
                      () {
                        // TODO: Navigate to salary management
                      },
                    ),
                    _buildFinanceCard(
                      context,
                      'Fee Structure',
                      'Configure fee structure',
                      Icons.list_alt,
                      () {
                        // TODO: Navigate to fee structure
                      },
                    ),
                    _buildFinanceCard(
                      context,
                      'Financial Reports',
                      'Generate and view reports',
                      Icons.bar_chart,
                      () {
                        // TODO: Navigate to financial reports
                      },
                    ),
                    _buildFinanceCard(
                      context,
                      'Pending Payments',
                      'View pending fee payments',
                      Icons.pending_actions,
                      () {
                        // TODO: Navigate to pending payments
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Handle new transaction
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Transaction',
      ),
    );
  }

  Widget _buildFinanceSummaryCards(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSummaryCard(
            context,
            'Total Collection',
            '₹1,25,000',
            Icons.arrow_upward,
            Colors.green,
          ),
          _buildSummaryCard(
            context,
            'Total Expenses',
            '₹75,000',
            Icons.arrow_downward,
            Colors.red,
          ),
          _buildSummaryCard(
            context,
            'Pending Dues',
            '₹50,000',
            Icons.warning,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount,
      IconData icon, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).primaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
