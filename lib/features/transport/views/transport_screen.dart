import 'package:flutter/material.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

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
                'Transport Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildTransportSummary(context),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildTransportCard(
                      context,
                      'Vehicle Management',
                      'Manage school vehicles and maintenance',
                      Icons.directions_bus,
                      () {
                        // TODO: Navigate to vehicle management
                      },
                    ),
                    _buildTransportCard(
                      context,
                      'Route Management',
                      'Configure and manage transport routes',
                      Icons.route,
                      () {
                        // TODO: Navigate to route management
                      },
                    ),
                    _buildTransportCard(
                      context,
                      'Driver Management',
                      'Manage drivers and staff',
                      Icons.person,
                      () {
                        // TODO: Navigate to driver management
                      },
                    ),
                    _buildTransportCard(
                      context,
                      'Student Transport',
                      'Assign students to routes',
                      Icons.people,
                      () {
                        // TODO: Navigate to student transport
                      },
                    ),
                    _buildTransportCard(
                      context,
                      'Transport Fee',
                      'Manage transport fees',
                      Icons.payments,
                      () {
                        // TODO: Navigate to transport fee
                      },
                    ),
                    _buildTransportCard(
                      context,
                      'Reports',
                      'View transport reports and analytics',
                      Icons.analytics,
                      () {
                        // TODO: Navigate to reports
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
          // TODO: Handle add new transport related item
        },
        tooltip: 'Add New',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransportSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, '15', 'Total\nVehicles'),
          _buildSummaryItem(context, '12', 'Active\nRoutes'),
          _buildSummaryItem(context, '18', 'Total\nDrivers'),
          _buildSummaryItem(context, '450', 'Total\nStudents'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String value, String label) {
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

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(
          context,
          'Track Vehicles',
          Icons.location_on,
          () {
            // TODO: Implement vehicle tracking
          },
        ),
        _buildQuickActionButton(
          context,
          'Emergency',
          Icons.emergency,
          () {
            // TODO: Implement emergency handling
          },
        ),
        _buildQuickActionButton(
          context,
          'Notifications',
          Icons.notifications,
          () {
            // TODO: Implement notifications
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

  Widget _buildTransportCard(BuildContext context, String title,
      String subtitle, IconData icon, VoidCallback onTap) {
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
