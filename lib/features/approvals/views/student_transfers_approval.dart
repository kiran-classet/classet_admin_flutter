import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:url_launcher/url_launcher_string.dart'; // Add this import for string-based methods
import 'package:shimmer/shimmer.dart'; // Add this import for shimmer effect

class StudentTransfersApprovalScreen extends ConsumerStatefulWidget {
  const StudentTransfersApprovalScreen({super.key});

  @override
  ConsumerState<StudentTransfersApprovalScreen> createState() =>
      _StudentTransfersApprovalScreenState();
}

class _StudentTransfersApprovalScreenState
    extends ConsumerState<StudentTransfersApprovalScreen> {
  Map<String, dynamic>? _userAssignedDetails; // State to store API response
  List<dynamic> _approvals = []; // State to store approvals list
  bool _isLoading = false; // State to manage loader visibility
  final Map<int, bool> _expandedCards =
      {}; // Track expanded state for each card
  String _searchQuery = ""; // State to store search query
  List<dynamic> _filteredApprovals = []; // State to store filtered approvals

  @override
  void initState() {
    super.initState();
    _fetchUserAssignedDetails();
  }

  void _filterApprovals(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApprovals = _approvals;
      } else {
        _filteredApprovals = _approvals.where((approval) {
          final username = approval['name']?.toLowerCase() ?? '';
          final id = approval['name']?.substring(3).toLowerCase() ?? '';
          final givenName = approval['name']?.toLowerCase() ?? '';
          return username.contains(query.toLowerCase()) ||
              id.contains(query.toLowerCase()) ||
              givenName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _fetchUserAssignedDetails() async {
    setState(() {
      _isLoading = true; // Show loader
    });
    try {
      final apiService = ApiService();
      final response = await apiService.get(
          'settings-approvals/userAssignedBoards?approvalType=studentTransfer');
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

  Future<void> _fetchPendingApprovals() async {
    if (_userAssignedDetails == null) return;

    setState(() {
      _isLoading = true; // Hide loader
      _approvals = []; // Save approvals in state
      _filteredApprovals = []; // Initialize filtered list
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
      },
      "branchIds": branchIds,
    };
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;
    final academicYear =
        userDetails?['data']['user_info']['selectedAcademicYear'];
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'transfers/get/all?academicYear=$academicYear',
        payload,
      );
      if (response['status'] == true) {
        setState(() {
          _isLoading = false; // Hide loader
          _approvals = response['data']['data']; // Save approvals in state
          _filteredApprovals = _approvals; // Initialize filtered list
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
    final filterData = _userAssignedDetails!['adminUserAssignedLevelDetails']
        .where((element) => element['_id'] == approvalData['fmbranchId'])
        .toList();

    final payload = {
      ...approvalData,
      "toTransferStatus": approveStatus,
      "handledBy": approvalData['handledBy'] ?? [],
      "levelAndBranchDetails": filterData,
    };
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        'transfers/update',
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

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (result == true) {
      onConfirm();
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
            const Color.fromARGB(255, 51, 83, 107),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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
                  approval['name']?.substring(3) ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${approval['transferType'] ?? 'N/A'} Transfer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From: ${approval['fmbranchName'] ?? 'N/A'} - ${approval['fmsectionName'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  'To: ${approval['tobranchName'] ?? 'N/A'} - ${approval['tosectionName'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
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
                      approval['status'] ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedCards[index] = !(_expandedCards[index] ?? false);
                  });
                },
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expandedCards[index] = !(_expandedCards[index] ?? false);
                    });
                  },
                  splashColor: Colors.blue.shade100,
                  child: _buildHeaderSection(approval, index),
                ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Icons.business, 'Branch', approval['fmbranchName'] ?? 'N/A'),
          _buildDetailRow(
              Icons.school, 'Board', approval['fmboradName'] ?? 'N/A'),
          _buildDetailRow(
              Icons.grade, 'Grade', approval['fmclassName'] ?? 'N/A'),
          _buildDetailRow(
              Icons.class_, 'Section', approval['fmsectionName'] ?? 'N/A'),
          _buildDetailRow(
              Icons.phone, 'Parent Contact', approval['phoneNumber'] ?? 'N/A'),
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
            child: GestureDetector(
              onTap: () async {
                if (label == 'Parent Contact' && value != 'N/A') {
                  final String phoneUri = 'tel:$value';
                  if (await canLaunchUrlString(phoneUri)) {
                    // Use canLaunchUrlString
                    await launchUrlString(phoneUri); // Use launchUrlString
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to make a call')),
                    );
                  }
                }
              },
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
                      color: Colors.blue, // Highlight clickable text
                    ),
                  ),
                ],
              ),
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
      onPressed: () {
        final action = label.toLowerCase();
        _showConfirmationDialog(
          title: 'Confirm $label',
          content: 'Are you sure you want to $action this approval?',
          onConfirm: onPressed,
        );
      },
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2, // Add elevation for better feedback
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.blue.shade200,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'No pending approvals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh when new approvals arrive',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView.builder(
      itemCount: 5, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulate header with a rectangle and a circle
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Simulate lines for details
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    // Simulate action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 80,
                          height: 32,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          'Student Transfers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUserAssignedDetails,
            color: Colors.white,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterApprovals,
                    decoration: InputDecoration(
                      hintText: 'Search by ID',
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
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserAssignedDetails,
        color: Colors.blue.shade700,
        child: _isLoading
            ? _buildLoadingIndicator()
            : _userAssignedDetails == null
                ? _buildLoadingIndicator()
                : _filteredApprovals.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _filteredApprovals.length,
                        itemBuilder: (context, index) => _buildApprovalCard(
                            _filteredApprovals[index], index),
                      ),
      ),
      floatingActionButton: FilterButtonWidget(
        openBottomSheet: true,
        showSections: true,
        onFilterApplied: _fetchPendingApprovals,
        isSingleSectionsSelection: true,
      ),
    );
  }
}
