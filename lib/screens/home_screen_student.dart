import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/holiday_screen.dart';
import 'package:sms/screens/profile_screen.dart';
import 'package:sms/screens/theme_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../models/user.dart';
import 'attendance_screen.dart';
import 'feed_screen.dart';
import 'home_screen_admin.dart';
import 'login_screen.dart';
import 'messages_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final User user;

  const StudentHomeScreen({Key? key, required this.user}) : super(key: key);
  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const StudentFeedScreen(),
    HolidayScreen(),
    MessagesScreen(),
    AttendanceScreen(),
    ProfileScreen(),
    ThemeScreen()
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(
      name: 'Home',
      imagePath: 'assets/images/home.png',
      icon: Icons.home_rounded,
    ),
    NavigationItem(
      name: 'Calendar',
      imagePath: 'assets/images/calendar.png',
      icon: Icons.calendar_today_rounded,
    ),
    NavigationItem(
      name: 'Messages',
      imagePath: 'assets/images/messages.png',
      icon: Icons.forum_rounded,
    ),
    NavigationItem(
      name: 'Attendance',
      imagePath: 'assets/images/attendance.png',
      icon: Icons.assignment_turned_in_rounded,
    ),
    NavigationItem(
      name: 'Profile',
      imagePath: 'assets/images/profile.png',
      icon: Icons.person_rounded,
    ),
    NavigationItem(
      name: 'Themes',
      imagePath: 'assets/images/profile.png',
      icon: Icons.color_lens_sharp,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      appBar: isSmallScreen ? _buildAppBar(theme) : null,
      drawer: isSmallScreen ? _buildDrawer(theme) : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSmallScreen) _buildSideNavigation(theme, size.width >= 1200),
            Expanded(
              child: Column(
                children: [
                  if (!isSmallScreen) _buildTopBar(theme, size.width >= 1200),
                  Expanded(child: _screens[_selectedIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isSmallScreen ? _buildBottomNav(theme) : null,
    );
  }

  // Similar app bar, drawer, and navigation methods from admin screen
  // (Adjust icons, colors, and titles as needed for student perspective)
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      title: Text(
        'School Management',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: theme.colorScheme.primary,
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            // Handle notifications
          },
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: Icon(
            Icons.person_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // Branding Section
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/school_logo.png', // Replace with actual logo
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'XYZ School', // Replace with actual school name
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == index;

                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            // Logout Option
            ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: _confirmLogout,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildSideNavigation(ThemeData theme, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 250 : 80,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Branding Space
          Container(
            height: 100, // Adjust height as needed
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/school_logo.png', // Replace with actual logo path
                  width: isExpanded ? 50 : 40,
                  height: isExpanded ? 50 : 40,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'XYZ School', // Replace with actual school name
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isExpanded ? 16 : 0,
                    vertical: 4,
                  ),
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  title: isExpanded
                      ? Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  )
                      : null,
                  selected: isSelected,
                  selectedTileColor: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Logout Option
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 0,
              vertical: 4,
            ),
            leading: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: isExpanded
                ? Text(
              'Logout',
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            )
                : null,
            onTap: () {
              _confirmLogout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Widget _buildBottomNav(ThemeData theme) {
    List<BottomNavigationBarItem> visibleItems = _navItems
        .take(4) // Show only the first 4 items
        .map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.name))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        onTap: (int index) {
          if (index == 4) {
            _showMoreOptions();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 0,
        items: [
          ...visibleItems,
          BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

// Function to show overflow menu
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: _navItems.skip(4).map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              onTap: () {
                setState(() {
                  _selectedIndex = _navItems.indexOf(item);
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pop(context); // Close dialog
    context.read<AuthBloc>().add(LogoutRequested());
    // Add navigation cleanup
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }
  Widget _buildTopBar(ThemeData theme, bool isLargeScreen) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [/*...*/],
      ),
      child: Row(
        children: [
          Text(
            _navItems[_selectedIndex].name,
            style: theme.textTheme.titleLarge,
          ),
          const Spacer(),
          // Notification and profile icons
        ],
      ),
    );
  }
}
