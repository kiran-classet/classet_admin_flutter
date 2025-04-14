import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
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
  List<dynamic> _approvals = []; // State to store approvals list
  bool _isLoading = false; // State to manage loader visibility

  @override
  void initState() {
    super.initState();
    _fetchUserAssignedDetails();
  }

  Future<void> _fetchUserAssignedDetails() async {
    setState(() {
      _isLoading = true; // Show loader
    });
    try {
      final apiService = ApiService();
      final response = await apiService.get(
          'settings-approvals/userAssignedBoards?approvalType=studentStatusChange');
      if (response['status'] == true) {
        setState(() {
          _isLoading = false; // Hide loader
          _userAssignedDetails = response['data']; // Save response in state
        });
        print('User Assigned Details: $_userAssignedDetails');
        _fetchPendingApprovals(); // Fetch pending approvals after user assigned details
      } else {
        setState(() {
          _isLoading = false; // Hide loader
        });
        print('Failed to fetch user assigned details: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching user assigned details: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  Future<void> _fetchPendingApprovals() async {
    if (_userAssignedDetails == null) return;

    setState(() {
      _isLoading = true; // Show loader
    });

    final filterState = ref.read(filterStateProvider);
    final sectionId =
        filterState.section.isNotEmpty ? filterState.section[0] : null;
    final branchIds =
        _userAssignedDetails!['data'].map((e) => e['branchId']).toList();
    final selectedBranch = filterState.branch;

    if (selectedBranch == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No branch selected in filters')),
      );
      return;
    }
    final isValidBranch = branchIds.contains(selectedBranch);
    if (!isValidBranch) {
      setState(() {
        _isLoading = false; // Hide loader
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You Dont have access to selcted branch in filters')),
      );
      return;
    }

    if (sectionId == null) {
      setState(() {
        _isLoading = false; // Hide loader
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No section selected in filters')),
      );
      return;
    }

    final assignedHeirarchy =
        _userAssignedDetails!['adminUserAssignedLevelDetails'];

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
        setState(() {
          _isLoading = false; // Hide loader
          _approvals = response['data']; // Save approvals in state
        });
      } else {
        print('Failed to fetch pending approvals: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching pending approvals: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  Future<void> _updateApprovalStatus(
      Map<String, dynamic> approvalData, String approveStatus) async {
    if (_userAssignedDetails == null) return;

    setState(() {
      _isLoading = true; // Show loader
    });
    print(
        'User Assigned Details: ${_userAssignedDetails!['adminUserAssignedLevelDetails']}');
    print('Approval Data Branch ID: ${approvalData['branchId']}');

    final filterData = _userAssignedDetails!['adminUserAssignedLevelDetails']
        .where((element) => element['_id'] == approvalData['branchId'])
        .toList();

    final payload = {
      ...approvalData,
      "approveStatus": approveStatus,
      "statusChangeRemarks": approvalData['statusChangeRemarks'] ?? "",
      "handledBy": approvalData['handledBy'] ?? [],
      "levelAndBranchDetails": filterData,
    };
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'statusChange/update',
        payload,
      );
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated successfully')),
        );
        _fetchPendingApprovals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to ${approveStatus.toLowerCase()}: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Status Change'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : _userAssignedDetails == null
              ? const Center(child: CircularProgressIndicator())
              : _approvals.isEmpty
                  ? const Center(child: Text('No pending approvals'))
                  : ListView.builder(
                      itemCount: _approvals.length,
                      itemBuilder: (context, index) {
                        final approval = _approvals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  approval['given_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'username: ${approval['username']?.substring(3) ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Branch: ${approval['branchName'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Section: ${approval['sectionName'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Parent Contact: ${approval['parentContactNo'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Remarks: ${approval['statusChangeRemarks'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Requested By: ${approval['requestRaisedByName']?.substring(3) ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Request Date: ${DateTime.parse(approval['createdAt']).toLocal()}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () {
                                        _updateApprovalStatus(
                                            approval, "APROVE");
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () {
                                        _updateApprovalStatus(
                                            approval, "REJECT");
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
