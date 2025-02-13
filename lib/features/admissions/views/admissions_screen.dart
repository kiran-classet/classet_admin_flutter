import 'package:flutter/material.dart';

class AdmissionsScreen extends StatelessWidget {
  const AdmissionsScreen({Key? key}) : super(key: key);

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
                'Admissions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildAdmissionCard(
                      context,
                      'New Admission',
                      'Register new student',
                      Icons.person_add,
                      () {
                        // TODO: Handle new admission
                      },
                    ),
                    _buildAdmissionCard(
                      context,
                      'Admission Enquiries',
                      'View and manage enquiries',
                      Icons.question_answer,
                      () {
                        // TODO: Handle enquiries
                      },
                    ),
                    _buildAdmissionCard(
                      context,
                      'Applications',
                      'Review pending applications',
                      Icons.description,
                      () {
                        // TODO: Handle applications
                      },
                    ),
                    _buildAdmissionCard(
                      context,
                      'Reports',
                      'View admission reports',
                      Icons.bar_chart,
                      () {
                        // TODO: Handle reports
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmissionCard(BuildContext context, String title,
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
