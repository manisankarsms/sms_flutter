import 'package:flutter/material.dart';
import 'package:sms/screens/calendar_screen.dart';
import 'package:sms/screens/dashboard_screen.dart';
import 'package:sms/screens/new_student_screen.dart';

import '../models/item.dart';
import 'classes_screen.dart';

class HomeScreenAdmin extends StatefulWidget {
  @override
  _HomeScreenAdminState createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    NewStudentScreen(),
    Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => ClassesScreen(),
      ),
    ),
    Center(child: Text('Staffs - Development In Progress')),
    Center(child: Text('Students - Development In Progress')),
  ];

  final List<Item> items = [
    Item(name: 'Dashboard', imagePath: 'assets/images/students.png'),
    Item(name: 'New Student', imagePath: 'assets/images/students.png'),
    Item(name: 'Classes', imagePath: 'assets/images/calendar.png'),
    Item(name: 'Staffs', imagePath: 'assets/images/messages.png'),
    Item(name: 'Students', imagePath: 'assets/images/attendance.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      drawer: !isLargeScreen
          ? Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ...items.asMap().entries.map((entry) {
              int index = entry.key;
              Item item = entry.value;
              return ListTile(
                leading: Image.asset(item.imagePath, width: 24, height: 24),
                title: Text(item.name),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context); // Close drawer on selection
                },
              );
            }).toList(),
          ],
        ),
      )
          : null,
      body: isLargeScreen
          ? Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: items
                .map((item) => NavigationRailDestination(
              icon: Image.asset(
                item.imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
              label: Text(item.name),
            ))
                .toList(),
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      )
          : _screens[_selectedIndex],
      bottomNavigationBar: !isLargeScreen
          ? BottomNavigationBar(
        currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
        onTap: (int index) {
          if (index == 3) {
            Scaffold.of(context).openDrawer(); // Open Drawer for more options
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: [
          ...items.sublist(0, 3).map((item) => BottomNavigationBarItem(
            icon: Image.asset(
              item.imagePath,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
            label: item.name,
          )),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      )
          : null,
    );
  }
}
