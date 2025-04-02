import 'package:flutter/material.dart';

class StudentInfoScreen extends StatelessWidget {
  const StudentInfoScreen({super.key});

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
                'Student Information',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildStudentInfoCard(
                      context,
                      'Student Directory',
                      'View and manage student profiles',
                      Icons.people,
                      () {
                        // TODO: Navigate to student directory
                      },
                    ),
                    _buildStudentInfoCard(
                      context,
                      'Class Management',
                      'Manage class sections and assignments',
                      Icons.class_,
                      () {
                        // TODO: Navigate to class management
                      },
                    ),
                    _buildStudentInfoCard(
                      context,
                      'Academic Records',
                      'View and update academic performance',
                      Icons.school,
                      () {
                        // TODO: Navigate to academic records
                      },
                    ),
                    _buildStudentInfoCard(
                      context,
                      'Student Documents',
                      'Access and manage student documents',
                      Icons.folder,
                      () {
                        // TODO: Navigate to documents section
                      },
                    ),
                    _buildStudentInfoCard(
                      context,
                      'Health Records',
                      'View and update health information',
                      Icons.health_and_safety,
                      () {
                        // TODO: Navigate to health records
                      },
                    ),
                    _buildStudentInfoCard(
                      context,
                      'Reports & Analytics',
                      'Generate and view student reports',
                      Icons.analytics,
                      () {
                        // TODO: Navigate to reports section
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
          // TODO: Handle add new student
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search students...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (value) {
        // TODO: Implement search functionality
      },
    );
  }

  Widget _buildStudentInfoCard(BuildContext context, String title,
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
