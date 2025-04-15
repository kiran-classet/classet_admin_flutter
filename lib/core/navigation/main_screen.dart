import 'package:classet_admin/features/admissions/views/admissions_screen.dart';
import 'package:classet_admin/features/approvals/views/approval_screen.dart';
import 'package:classet_admin/features/attendance/views/attendance_management_screen.dart';
import 'package:classet_admin/features/communication/views/communication_screen.dart';
import 'package:classet_admin/features/finance/views/finance_screen.dart';
import 'package:classet_admin/features/notifications/views/notifications_screen.dart';
import 'package:classet_admin/features/profile/views/profile_screen.dart';
import 'package:classet_admin/features/settings/views/settings_screen.dart';
import 'package:classet_admin/features/student_info/views/student_info_screen.dart';
import 'package:classet_admin/features/teacher_diaries/views/teacher_diarie_screen.dart';
import 'package:classet_admin/features/help_center/views/help_center_screen.dart';
import 'package:classet_admin/features/timetable/views/timetable_screen.dart';
import 'package:classet_admin/features/transport/views/transport_screen.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/features/dashboard/views/home_screen.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Main screen

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  int _selectedDrawerIndex = 0;
  final int _notificationCount = 0; // Add this variable

  final PageController _pageController = PageController();

  // Separate list for bottom navigation screens
  final List<Widget> _bottomNavScreens = [
    const HomeScreen(), // Index 0 - Home
    const ApprovalScreen(),
    const ProfileScreen(), // Index 2 - Profile
  ];

  // Separate list for drawer screens
  final List<Widget> _drawerScreens = [
    const AdmissionsScreen(),
    const StudentInfoScreen(),
    const FinanceScreen(),
    const TransportScreen(),
    const CommunicationScreen(),
    const TimetableScreen(),
    const AttendanceManagementScreen(),
    const TeacherDiariesScreen(),
    const SettingsScreen(),
    const HelpCenterScreen(),
  ];
  void _handleNotificationTap() {
    // Navigate to notifications screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(), // Create this screen
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _drawerScreens[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;

    String userName = 'User';
    String userPhoto = '';

    if (userDetails != null) {
      final userInfo = userDetails['data']?['user_info'];
      userName = userInfo?['name'] ?? 'User';
      userPhoto = userInfo?['studentPhoto']?['storageLocation'] ?? '';
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevents dismissing by tapping outside
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Exit App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF076EFF), // Using your app's blue color
              ),
            ),
            content: const Text(
              'Are you sure you want to exit the app?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            elevation: 8,
            backgroundColor: Colors.white,
            actions: [
              Container(
                margin: const EdgeInsets.only(bottom: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF076EFF)),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF076EFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF076EFF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (userPhoto.isNotEmpty)
                // CircleAvatar(
                //   radius: 16,
                //   backgroundImage: NetworkImage(userPhoto),
                // ),
                // if (userPhoto.isNotEmpty) const SizedBox(width: 8),
                Text(
                  'Classet',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          actions: [
            // Notification Icon with Badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 30, // Increased icon size
                  ),
                  onPressed: _handleNotificationTap,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '1', // Replace with your actual notification count
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8), // Add some spacing between icons
          ],
        ),
        drawer: CustomDrawer(
          selectedIndex: _selectedDrawerIndex,
          onItemTapped: _onDrawerItemTapped,
          userName: userName,
          userPhoto: userPhoto,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: _bottomNavScreens,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onBottomNavTapped,
        ),
      ),
    );
  }
}

// CustomDrawer with Settings and Help Center
class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String userName;
  final String userPhoto;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.userName,
    required this.userPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromRGBO(7, 110, 255, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(7, 110, 255, 1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
                    child: userPhoto.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // DrawerItem(
            //   icon: Icons.school,
            //   title: 'Admissions',
            //   index: 0,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.person,
            //   title: 'Student Info',
            //   index: 1,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.account_balance_wallet,
            //   title: 'Finance',
            //   index: 2,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.directions_bus,
            //   title: 'Transport',
            //   index: 3,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.message,
            //   title: 'Communication',
            //   index: 4,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.calendar_today,
            //   title: 'Timetable',
            //   index: 5,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.fact_check,
            //   title: 'Attendance',
            //   index: 6,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // DrawerItem(
            //   icon: Icons.book,
            //   title: 'Teacher Diaries',
            //   index: 7,
            //   selectedIndex: selectedIndex,
            //   onTap: onItemTapped,
            // ),
            // const Divider(
            //   color: Colors.white70,
            //   thickness: 1,
            //   height: 1,
            // ),
            DrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              index: 8,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.help_center,
              title: 'Help Center',
              index: 9,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      margin: const EdgeInsets.only(bottom: 25), // Minimal bottom margin
      child: Container(
        height: 56, // Reduced navigation bar height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
                Icons.document_scanner, Icons.document_scanner_outlined, 1),
            _buildNavItem(Icons.home, Icons.home_outlined, 0),
            _buildNavItem(Icons.person, Icons.person_outline, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData selectedIcon, IconData unselectedIcon, int index) {
    return SizedBox(
      height: 50, // Constrain icon button height
      width: 50, // Constrain icon button width
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          selectedIndex == index ? selectedIcon : unselectedIcon,
          size: 24, // Reduced icon size
        ),
        onPressed: () => onItemTapped(index),
        color: selectedIndex == index ? Colors.blue : Colors.grey,
      ),
    );
  }
}

// DrawerItem remains the same
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true, // Makes the ListTile more compact
      visualDensity: VisualDensity(vertical: -4), // Reduces vertical spacing
      leading: Icon(
        icon,
        color: Colors.white,
        size: 22, // Slightly smaller icon
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 19, // Slightly smaller text
          fontWeight:
              selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selectedIndex == index,
      onTap: () => onTap(index),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Adjust padding
    );
  }
}
