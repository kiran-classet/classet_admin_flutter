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
  final Map<int, bool> _expandedCards =
      {}; // Track expanded state for each card

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

  Widget _buildHeaderSection(Map<String, dynamic> approval, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            const Color.fromARGB(255, 51, 83, 107)
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approval['given_name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${approval['username']?.substring(3) ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _expandedCards[index] ?? false
                    ? Icons.expand_less
                    : Icons.expand_more,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> approval, int index) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedCards[index] = !(_expandedCards[index] ?? false);
                  });
                },
                child: _buildHeaderSection(approval, index),
              ),
              if (!(_expandedCards[index] ?? false))
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildActionSection(
                      approval), // Show buttons in collapsed state
                ),
              if (_expandedCards[index] ?? false)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailsSection(approval),
                      const Divider(height: 24),
                      _buildActionSection(approval),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(Map<String, dynamic> approval) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          onPressed: () => _updateApprovalStatus(approval, "APROVE"),
          icon: Icons.check_circle,
          label: 'Approve',
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          onPressed: () => _updateApprovalStatus(approval, "REJECT"),
          icon: Icons.cancel,
          label: 'Reject',
          color: Colors.red.shade600,
        ),
      ],
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> approval) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
              Icons.business, 'Branch', approval['branchName'] ?? 'N/A'),
          _buildDetailRow(
              Icons.school, 'Board', approval['custom:board'] ?? 'N/A'),
          _buildDetailRow(
              Icons.grade, 'Grade', approval['custom:grade'] ?? 'N/A'),
          _buildDetailRow(
              Icons.class_, 'Section', approval['sectionName'] ?? 'N/A'),
          _buildDetailRow(Icons.phone, 'Parent Contact',
              approval['parentContactNo'] ?? 'N/A'),
          _buildDetailRow(Icons.comment, 'Remarks',
              approval['statusChangeRemarks'] ?? 'N/A'),
          _buildDetailRow(Icons.person, 'Requested By',
              approval['requestRaisedByName']?.substring(3) ?? 'N/A'),
          _buildDetailRow(
            Icons.calendar_today,
            'Request Date',
            DateTime.parse(approval['createdAt'])
                .toLocal()
                .toString()
                .split('.')[0],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Status Change'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserAssignedDetails, // Pull-to-refresh functionality
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userAssignedDetails == null
                ? const Center(child: CircularProgressIndicator())
                : _approvals.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height -
                                kToolbarHeight,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No pending approvals',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _approvals.length,
                        itemBuilder: (context, index) =>
                            _buildApprovalCard(_approvals[index], index),
                      ),
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
