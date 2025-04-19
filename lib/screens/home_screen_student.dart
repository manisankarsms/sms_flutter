import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/complaint_screen.dart';
import 'package:sms/screens/fees_screen_user.dart';
import 'package:sms/screens/holiday_screen.dart';
import 'package:sms/screens/profile_screen.dart';
import 'package:sms/screens/rules_screen.dart';
import 'package:sms/screens/theme_screen.dart';
import 'package:sms/utils/constants.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../models/user.dart';
import 'attendance_screen.dart';
import 'feed_screen.dart';
import 'games_screen.dart';
import 'home_screen_admin.dart';
import 'login_screen.dart';
import 'messages_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final List<User> users; // List of users for switching
  final User selectedUser; // Currently active user

  const StudentHomeScreen({
    Key? key,
    required this.users,
    required this.selectedUser,
  }) : super(key: key);

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  late User _activeUser; // Track active user
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _activeUser = widget.selectedUser; // Initialize with selected user
  }

  List<Widget> get _screens {
    return [
      const StudentFeedScreen(),
      HolidayScreen(),
      MessagesScreen(),
      AttendanceScreen(),
      ProfileScreen(),
      UserFeesScreen(studentClass: _activeUser.studentData!.studentStandard), // Pass active user type
      ThemeScreen(),
      RulesScreen(),
      GamesScreen(),
      ComplaintScreen(),
    ];
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(
      name: 'Home',
      imagePath: 'assets/images/home.png',
      icon: Icons.home_rounded,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Calendar',
      imagePath: 'assets/images/calendar.png',
      icon: Icons.calendar_today_rounded,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Messages',
      imagePath: 'assets/images/messages.png',
      icon: Icons.forum_rounded,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Attendance',
      imagePath: 'assets/images/attendance.png',
      icon: Icons.assignment_turned_in_rounded,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Profile',
      imagePath: 'assets/images/profile.png',
      icon: Icons.person_rounded,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Fees',
      imagePath: 'assets/images/profile.png',
      icon: Icons.person_rounded,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Themes',
      imagePath: 'assets/images/profile.png',
      icon: Icons.color_lens_sharp,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Rules',
      imagePath: 'assets/images/profile.png',
      icon: Icons.rule,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Games',
      imagePath: 'assets/images/profile.png',
      icon: Icons.videogame_asset,
        permissionKey: ''
    ),
    NavigationItem(
      name: 'Complaint',
      imagePath: 'assets/images/profile.png',
      icon: Icons.comment,
        permissionKey: ''
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery
        .of(context)
        .size;
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
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: _screens[_selectedIndex],
                    ),
                  ),                ],
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
        "Welcome, ${_activeUser.displayName}",
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
        // If multiple student users exist, show Switch User option
        if (widget.users.where((user) => user.userType == Constants.student).length > 1)
          PopupMenuButton<User>(
            icon: const Icon(Icons.swap_horiz, color: Colors.blue),
            tooltip: "Switch User",
            onSelected: (User newUser) {
              setState(() {
                _activeUser = newUser;
                _screens[5] = UserFeesScreen(studentClass: _activeUser.userType);
                _screens[4] = ProfileScreen(); // Refresh profile screen
              });
            },
            itemBuilder: (BuildContext context) {
              // Filter only Student users
              List<User> studentUsers = widget.users.where((user) => user.userType == Constants.student).toList();

              return studentUsers.map((User user) {
                return PopupMenuItem<User>(
                  value: user,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(user.displayName),
                    ],
                  ),
                );
              }).toList();
            },
          ),
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
                children: _navItems
                    .asMap()
                    .entries
                    .map((entry) {
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight
                            .normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primary.withOpacity(
                        0.1),
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
                  'assets/images/school_logo.png',
                  // Replace with actual logo path
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  )
                      : null,
                  selected: isSelected,
                  selectedTileColor: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : null,
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
        .map((item) =>
        BottomNavigationBarItem(icon: Icon(item.icon), label: item.name))
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
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 0,
        items: [
          ...visibleItems,
          BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz), label: 'More'),
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
      builder: (context) =>
          AlertDialog(
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
                child: const Text(
                    'Logout', style: TextStyle(color: Colors.red)),
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
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Page title
          Text(
            _navItems[_selectedIndex].name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // Action buttons
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),

          // User Profile & Switch User Menu
          PopupMenuButton<dynamic>(
            offset: const Offset(0, 45),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    _activeUser.displayName.isNotEmpty
                        ? _activeUser.displayName[0] // First letter of name
                        : "?",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLargeScreen) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _activeUser.displayName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _activeUser.userType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ],
            ),
            onSelected: (value) {
              if (value is User) {
                print("Switching to user: ${value.displayName}"); // Debugging
                setState(() {
                  _activeUser = value;
                  _screens[5] = UserFeesScreen(studentClass: _activeUser.userType);
                  _screens[4] = ProfileScreen(); // Refresh profile screen
                });
              } else if (value == 'logout') {
                _confirmLogout();
              }
            },
              itemBuilder: (context) {
                List<User> studentUsers = widget.users.where((user) => user.userType == Constants.student).toList();

                List<PopupMenuEntry<dynamic>> items = [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                ];

                // Add Switch User option only if multiple students exist
                if (studentUsers.length > 1) {
                  print("Multiple student users detected, showing switch option.");
                  items.addAll(studentUsers.map((User user) {
                    return PopupMenuItem<User>(
                      value: user,
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(user.displayName),
                        ],
                      ),
                    );
                  }).toList());
                  items.add(const PopupMenuDivider());
                } else {
                  print("Only one student found, switch user option will not appear.");
                }

                // Add logout option
                items.add(
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        const Text('Logout'),
                      ],
                    ),
                  ),
                );

                return items;
              }
          ),
        ],
      ),
    );
  }
}
