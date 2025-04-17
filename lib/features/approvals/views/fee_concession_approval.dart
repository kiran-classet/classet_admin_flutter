import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeeConcessionApprovalScreen extends ConsumerStatefulWidget {
  const FeeConcessionApprovalScreen({super.key});

  @override
  ConsumerState<FeeConcessionApprovalScreen> createState() =>
      _FeeConcessionApprovalScreenState();
}

class _FeeConcessionApprovalScreenState
    extends ConsumerState<FeeConcessionApprovalScreen> {
  final GlobalKey _swipeShowcaseKey = GlobalKey(); // Showcase key
  bool _isShowcaseDisplayed = false; // Track if showcase has been displayed
  bool _isLoading = false;
  List<dynamic> _usersWithApprovals = [];
  List<dynamic> _filteredUsers = [];
  String? _selectedUserId;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _approvalStatuses = {}; // Track approval statuses
  Map<String, dynamic>? _userAssignedDetails; // State to store API response

  @override
  void initState() {
    super.initState();
    _fetchUserAssignedDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndDisplayShowcase();
    });
  }

  Future<void> _checkAndDisplayShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final isShowcaseDisplayed =
        prefs.getBool('isSwipeShowcaseDisplayed') ?? false;

    if (!isShowcaseDisplayed && mounted) {
      _isShowcaseDisplayed = true;
      ShowCaseWidget.of(context).startShowCase([_swipeShowcaseKey]);
      await prefs.setBool(
          'isSwipeShowcaseDisplayed', true); // Mark as displayed
    }
  }

  Future<void> _fetchUserAssignedDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final apiService = ApiService();
      final response = await apiService.get(
          'settings-approvals/userAssignedBoards?approvalType=feeConcession');
      if (response['status'] == true) {
        setState(() {
          _isLoading = false; // Hide loader
          _userAssignedDetails = response['data']; // Save response in state
        });
        _fetchUsersAndApprovals(); // Fetch pending approvals after user assigned details
      } else {
        setState(() {
          _isLoading = false; // Hide loader
          _userAssignedDetails = {};
        });
        print('Failed to fetch user assigned details: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching user assigned details: $e');
      setState(() {
        _isLoading = false; // Hide loader
        _userAssignedDetails = {};
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  Future<void> _fetchUsersAndApprovals() async {
    if (_userAssignedDetails == null) return;
    setState(() {
      _isLoading = true;
      _usersWithApprovals = [];
      _filteredUsers = [];
    });
    final filterState = ref.read(filterStateProvider);
    final sectionId =
        filterState.section.isNotEmpty ? filterState.section[0] : null;
    final branchIds =
        _userAssignedDetails!['data'].map((e) => e['branchId']).toList();
    final selectedBranch = filterState.branch;
    final selectedBoard = filterState.board;
    final selectedGrade = filterState.grade;
    if (selectedBranch == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No branch selected in filters')),
      );
      return;
    }

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
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];

    if (academicYear == null) {
      setState(() {
        _isLoading = false; // Hide loader
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No academic year selected in filters')),
      );
      return;
    }
    final payload = {
      "branchId": [selectedBranch],
      "boardId": [selectedBoard],
      "gradeId": [selectedGrade],
      "sectionId": sectionId,
      "academicYear": academicYear,
      "username": "",
      "enrollmentNo": "",
      "assignedHeirarchy": {
        "branchIds": branchIds,
        "adminLevels": adminLevels,
      }
    };
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'concession-approval/get-concession-approvals?limit=10&page=1',
        payload,
      );
      if (response['status'] == true) {
        setState(() {
          _usersWithApprovals = response['data'];
          _filteredUsers = _usersWithApprovals; // Initialize filtered list
        });
      } else {
        print('Failed to fetch data: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _usersWithApprovals;
      } else {
        _filteredUsers = _usersWithApprovals
            .where((user) =>
                (user['firstName'] + ' ' + user['lastName'])
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                user['branchName'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _saveApprovalStatuses() async {
    if (_approvalStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final payload = _approvalStatuses.entries
          .map((entry) => {
                "approvalId": entry.key,
                "status": entry.value,
              })
          .toList();

      final response = await apiService.post(
        'concession-approval/update-approval-status',
        {"approvals": payload},
      );

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Approval statuses saved successfully.')),
        );
        setState(() {
          _approvalStatuses.clear();
        });
      } else {
        print('Failed to save statuses: ${response['message']}');
      }
    } catch (e) {
      print('Error saving statuses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this helper method to check if all approvals are acted upon
  bool _allApprovalsActedUpon(List<dynamic> approvals) {
    return approvals
        .every((approval) => _approvalStatuses.containsKey(approval['_id']));
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, List<dynamic> approvals) async {
    final approvedCount = approvals
        .where((approval) => _approvalStatuses[approval['_id']] == 'approved')
        .length;
    final rejectedCount = approvals
        .where((approval) => _approvalStatuses[approval['_id']] == 'rejected')
        .length;
    final totalApprovedConcession = approvals
        .where((approval) => _approvalStatuses[approval['_id']] == 'approved')
        .fold(0,
            (sum, approval) => sum + ((approval['currentConAmt'] ?? 0) as int));
    final totalRejectedConcession = approvals
        .where((approval) => _approvalStatuses[approval['_id']] == 'rejected')
        .fold(0,
            (sum, approval) => sum + ((approval['currentConAmt'] ?? 0) as int));

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.save_outlined,
                        color: Colors.blue.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Confirm Save',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Approved Section
                _buildStatusSection(
                  icon: Icons.check_circle_outline,
                  title: 'Approved',
                  count: approvedCount,
                  amount: totalApprovedConcession,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                // Rejected Section
                _buildStatusSection(
                  icon: Icons.cancel_outlined,
                  title: 'Rejected',
                  count: rejectedCount,
                  amount: totalRejectedConcession,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),

                // Divider
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _saveApprovalStatuses();
                      },
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection({
    required IconData icon,
    required String title,
    required int count,
    required int amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count approvals',
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Total: ₹$amount',
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: 10, // Placeholder count for shimmer effect
        itemBuilder: (context, index) {
          return Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  colors: [
                    const Color.fromARGB(255, 212, 215, 249),
                    const Color.fromARGB(255, 251, 244, 244)
                  ],
                ),
              ),
              child: ListTile(
                title: Text(
                  '${user['firstName']} ${user['lastName']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Branch: ${user['branchName']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: Text(
                  'Approvals: ${user['concessionsRaised'].length}',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                onTap: () {
                  setState(() {
                    _selectedUserId = user['_id'];
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovalList(String userId) {
    final user = _usersWithApprovals.firstWhere((u) => u['_id'] == userId);
    final approvals = user['concessionsRaised'];

    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: 10, // Placeholder count for shimmer effect
        itemBuilder: (context, index) {
          return Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final approval = approvals[index];
              final approvalId = approval['_id'];

              return Dismissible(
                key: Key(approvalId),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  setState(() {
                    if (direction == DismissDirection.startToEnd) {
                      _approvalStatuses[approvalId] = 'approved';
                    } else if (direction == DismissDirection.endToStart) {
                      _approvalStatuses[approvalId] = 'rejected';
                    }
                  });
                  return false;
                },
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.check_circle, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.cancel, color: Colors.white),
                ),
                child: Card(
                  elevation: 8,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          colors: [
                            const Color.fromARGB(255, 212, 215, 249),
                            const Color.fromARGB(255, 251, 244, 244)
                          ],
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'Fee Type: ${approval['feeType']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Due Amount: ${approval['dueAmount']}'),
                            Text(
                                'Concession Type: ${approval['concessionType']}'),
                            Text(
                                'Current Concession: ${approval['currentConAmt']}'),
                          ],
                        ),
                        trailing: _approvalStatuses[approvalId] == null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        _approvalStatuses[approvalId] =
                                            'approved';
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _approvalStatuses[approvalId] =
                                            'rejected';
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Text(
                                _approvalStatuses[approvalId] == 'approved'
                                    ? 'Approved'
                                    : 'Rejected',
                                style: TextStyle(
                                  color: _approvalStatuses[approvalId] ==
                                          'approved'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_allApprovalsActedUpon(approvals))
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showConfirmationDialog(context, approvals),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 243, 244, 245),
                const Color.fromARGB(255, 104, 155, 232),
              ],
            ),
          ),
        ),
        elevation: 0,
        title: Text(
          _selectedUserId == null
              ? 'Fee Concession Approvals'
              : 'Approval for #${_usersWithApprovals.firstWhere((u) => u['_id'] == _selectedUserId)['firstName']}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Column(
            children: [
              if (_selectedUserId ==
                  null) // Show search bar only when no user is selected
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: 'Search by Name or Branch',
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        leading: _selectedUserId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedUserId = null;
                  });
                },
              )
            : null,
      ),
      body: _selectedUserId == null
          ? RefreshIndicator(
              onRefresh: () async {
                await _fetchUsersAndApprovals(); // Refresh user list
              },
              child: _buildUserList(), // Show shimmer or user list
            )
          : _buildApprovalList(
              _selectedUserId!), // Show approval list without pull-to-refresh
      floatingActionButton: _selectedUserId == null
          ? FilterButtonWidget(
              openBottomSheet: true,
              showSections: true,
              onFilterApplied: _fetchUsersAndApprovals,
              isSingleSectionsSelection: true,
            )
          : null, // Remove floating action button when showing approvals
    );
  }
}
