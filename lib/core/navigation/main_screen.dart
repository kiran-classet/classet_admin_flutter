import 'package:classet_admin/features/profile/views/profile_screen.dart';
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
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Custom Drawer
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
        color: Color.fromRGBO(7, 110, 255, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(7, 110, 255, 1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        'https://misedu-manage.classet.in/profilew.jpg'),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

// Drawer Item Widget
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
      tileColor: Colors.white,
      onTap: () {
        onTap(index);
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}

// Bottom Navigation Bar
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
      padding: EdgeInsets.symmetric(horizontal: 50.0),
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.04,
        ),
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                selectedIndex == 0 ? Icons.settings : Icons.settings_outlined,
              ),
              onPressed: () => onItemTapped(0),
              iconSize: 30,
              color: selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(
                selectedIndex == 1 ? Icons.home : Icons.home_outlined,
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
