import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentStatusChangeApprovalScreen extends ConsumerWidget {
  const StudentStatusChangeApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Status Change'),
      ),
      body: const Center(
        child: Text('Student Status Change Approval Screen'),
      ),
    );
  }
}
