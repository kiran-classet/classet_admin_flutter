import 'package:classet_admin/features/admissions/views/admissions_screen.dart';
import 'package:classet_admin/features/attendance/views/attendance_management_screen.dart';
import 'package:classet_admin/features/communication/views/communication_screen.dart';
import 'package:classet_admin/features/finance/views/finance_screen.dart';
import 'package:classet_admin/features/profile/views/profile_screen.dart';
import 'package:classet_admin/features/student_info/views/student_info_screen.dart';
import 'package:classet_admin/features/teacher_diaries/views/teacher_diarie_screen.dart';
import 'package:classet_admin/features/timetable/views/timetable_screen.dart';
import 'package:classet_admin/features/transport/views/transport_screen.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/features/dashboard/views/home_screen.dart';
import 'package:classet_admin/features/settings/views/settings_screen.dart';

// Main screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _selectedDrawerIndex = 0;
  final PageController _pageController = PageController();

  // Separate list for bottom navigation screens
  final List<Widget> _bottomNavScreens = [
    const HomeScreen(), // Index 0 - Home
    const SettingsScreen(), // Index 1 - Settings
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
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedDrawerIndex,
        onItemTapped: _onDrawerItemTapped,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _bottomNavScreens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavTapped,
      ),
    );
  }
}

// Update CustomDrawer
class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        'https://misedu-manage.classet.in/profilew.jpg'),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Kiran Monangi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Designation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DrawerItem(
              icon: Icons.school,
              title: 'Admissions',
              index: 0,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.person,
              title: 'Student Info',
              index: 1,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.account_balance_wallet,
              title: 'Finance',
              index: 2,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.directions_bus,
              title: 'Transport',
              index: 3,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.message,
              title: 'Communication',
              index: 4,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.calendar_today,
              title: 'Timetable',
              index: 5,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.fact_check,
              title: 'Attendance Management',
              index: 6,
              selectedIndex: selectedIndex,
              onTap: onItemTapped,
            ),
            DrawerItem(
              icon: Icons.book,
              title: 'Teacher Diaries',
              index: 7,
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
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.04,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              onPressed: () => onItemTapped(0),
              iconSize: 30,
              color: selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(
                selectedIndex == 1 ? Icons.settings : Icons.settings_outlined,
              ),
              onPressed: () => onItemTapped(1),
              iconSize: 30,
              color: selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(
                selectedIndex == 2 ? Icons.person : Icons.person_outline,
              ),
              onPressed: () => onItemTapped(2),
              iconSize: 30,
              color: selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
          ],
        ),
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
    Key? key,
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight:
              selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selectedIndex == index,
      onTap: () => onTap(index),
    );
  }
}
