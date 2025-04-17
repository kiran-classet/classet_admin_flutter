import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:showcaseview/showcaseview.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchUsersAndApprovals();
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

  Future<void> _fetchUsersAndApprovals() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'concession-approval/get-concession-approvals?limit=10&page=1',
        {
          "branchId": ["03788c5e-41a6-44be-a7e9-76f58bf61690"],
          "boardId": ["8ae27b15-a7c9-4c38-8220-a892cd7ae748"],
          "gradeId": ["a513e79f-f5b5-485f-9ff3-072a69bbe795"],
          "sectionId": "c8e11add-1285-4b7a-b1e0-fc41604b5de7",
          "academicYear": "675d109451233718e9b76dee",
          "username": "",
          "enrollmentNo": "",
          "assignedHeirarchy": {
            "branchIds": ["03788c5e-41a6-44be-a7e9-76f58bf61690"],
            "adminLevels": [
              {
                "_id": "03788c5e-41a6-44be-a7e9-76f58bf61690",
                "levels": [
                  {
                    "level": 1,
                    "users": [
                      {
                        "userName": "aaudeliveryuser",
                        "userId": "c1431d4a-f0a1-70da-283a-c431ac4dac82",
                        "status": true,
                        "level": 1
                      }
                    ]
                  }
                ]
              }
            ]
          }
        },
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

  // Show confirmation dialog
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Save'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Approved: $approvedCount approvals (Total Concession: $totalApprovedConcession)'),
              Text(
                  'Rejected: $rejectedCount approvals (Total Concession: $totalRejectedConcession)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveApprovalStatuses();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserList() {
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

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final approval = approvals[index];
              final approvalId = approval['_id'];

              return index == 0
                  ? Showcase(
                      key: _swipeShowcaseKey,
                      description: 'Swipe right to approve or left to reject',
                      child: Dismissible(
                        key: Key(approvalId),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          // Update the approval status based on the swipe direction
                          setState(() {
                            if (direction == DismissDirection.startToEnd) {
                              _approvalStatuses[approvalId] = 'approved';
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              _approvalStatuses[approvalId] = 'rejected';
                            }
                          });

                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(
                          //       direction == DismissDirection.startToEnd
                          //           ? 'Approved'
                          //           : 'Rejected',
                          //     ),
                          //     duration: const Duration(seconds: 2),
                          //   ),
                          // );

                          return false;
                        },
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.check_circle,
                              color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.cancel, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                                    Text(
                                        'Due Amount: ${approval['dueAmount']}'),
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
                                        _approvalStatuses[approvalId] ==
                                                'approved'
                                            ? 'Approved'
                                            : 'Rejected',
                                        style: TextStyle(
                                          color:
                                              _approvalStatuses[approvalId] ==
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
                      ),
                    )
                  : Dismissible(
                      key: Key(approvalId),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        // Update the approval status based on the swipe direction
                        setState(() {
                          if (direction == DismissDirection.startToEnd) {
                            _approvalStatuses[approvalId] = 'approved';
                          } else if (direction == DismissDirection.endToStart) {
                            _approvalStatuses[approvalId] = 'rejected';
                          }
                        });

                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //       direction == DismissDirection.startToEnd
                        //           ? 'Approved'
                        //           : 'Rejected',
                        //     ),
                        //     duration: const Duration(seconds: 2),
                        //   ),
                        // );

                        return false;
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:
                            const Icon(Icons.check_circle, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.cancel, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                      _approvalStatuses[approvalId] ==
                                              'approved'
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
        if (_allApprovalsActedUpon(
            approvals)) // Show Save button only if all approvals are acted upon
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
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      body: Column(
        children: [
          if (_selectedUserId ==
              null) // Show search bar only when no user is selected
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  hintText: 'Search by Name or Branch',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedUserId == null
                    ? _buildUserList()
                    : _buildApprovalList(_selectedUserId!),
          ),
        ],
      ),
    );
  }
}
