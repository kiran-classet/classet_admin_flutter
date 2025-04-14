import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:classet_admin/features/dashboard/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/services/api_service.dart';

class StudentStatusChangeApprovalScreen extends ConsumerStatefulWidget {
  const StudentStatusChangeApprovalScreen({super.key});

  @override
  ConsumerState<StudentStatusChangeApprovalScreen> createState() =>
      _StudentStatusChangeApprovalScreenState();
}

class _StudentStatusChangeApprovalScreenState
    extends ConsumerState<StudentStatusChangeApprovalScreen> {
  Map<String, dynamic>? _userAssignedDetails; // State to store API response

  @override
  void initState() {
    super.initState();
    _fetchUserAssignedDetails();
  }

  Future<void> _fetchUserAssignedDetails() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get(
          'settings-approvals/userAssignedBoards?approvalType=studentStatusChange');
      if (response['status'] == true) {
        setState(() {
          _userAssignedDetails = response['data']; // Save response in state
        });
        print('User Assigned Details: $_userAssignedDetails');
      } else {
        print('Failed to fetch user assigned details: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching user assigned details: $e');
    }
  }

  Future<void> _fetchPendingApprovals() async {
    if (_userAssignedDetails == null) return;
    // setState(() {
    //   _isLoading = true; // Show loader
    // });
    final filterState = ref.read(filterStateProvider); // Access saved filters
    final sectionId =
        filterState.section.isNotEmpty ? filterState.section[0] : null;

    if (sectionId == null) {
      // setState(() {
      //   _students.clear();
      //   _isLoading = false;
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No section selected in filters')),
      );
      return;
    }
    final assignedHeirarchy =
        _userAssignedDetails!['adminUserAssignedLevelDetails'];
    final branchIds =
        _userAssignedDetails!['data'].map((e) => e['branchId']).toList();
    final adminLevels = assignedHeirarchy;

    final payload = {
      "sectionId": sectionId,
      "isUserNameSearch": false,
      "username": "",
      "assignedHeirarchy": {
        "branchIds": branchIds,
        "adminLevels": adminLevels,
      }
    };
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'statusChange/get/all?academicYear=$academicYear',
        payload,
      );
      if (response['status'] == true) {
        print('Pending Approvals: ${response['data']}');
      } else {
        print('Failed to fetch pending approvals: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching pending approvals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Status Change'),
      ),
      body: Center(
        child: _userAssignedDetails == null
            ? const CircularProgressIndicator() // Show loader until data is fetched
            : const Text('Student Status Change Approval Screen'),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FilterButtonWidget(
          openBottomSheet: true,
          showSections: true,
          onFilterApplied: _fetchPendingApprovals,
          isSingleSectionsSelection: true,
        ),
      ),
    );
  }
}
