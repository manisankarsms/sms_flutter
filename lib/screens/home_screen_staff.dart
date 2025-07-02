import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/classes_screen.dart';
import 'package:sms/screens/feed_screen.dart';

// import 'package:sms/screens/attendance_mark_screen.dart';
import 'package:sms/screens/profile_screen.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/configuration/configuration_bloc.dart';
import '../bloc/configuration/configuration_event.dart';
import '../bloc/configuration/configuration_state.dart';
import '../models/configuration.dart';
import '../models/user.dart';
import 'classes_screen_staff.dart';
import 'home_screen_admin.dart';
import 'login_screen.dart';
import 'messages_screen.dart';
// import 'staff_tasks_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  final User user;

  const StaffHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _StaffHomeScreenState createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _screens;

  // Configuration data
  Configuration? _configuration;
  String? _schoolLogo;
  String _schoolName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _screens = _buildScreens(widget.user);
    _loadConfiguration(); // Load configuration from server
  }

  // Load configuration using ConfigurationBloc
  void _loadConfiguration() {
    context.read<ConfigurationBloc>().add(LoadConfiguration());
  }

  List<Widget> _buildScreens(User user) {
    return [
      ClassesScreenStaff(user: user),
      // StaffTasksScreen(),
      MessagesScreen(),
      ProfileScreen(),
    ];
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(
        name: 'My Class',
        imagePath: 'assets/images/attendance.png',
        icon: Icons.check_circle_outline,
        permissionKey: ''),
    /*NavigationItem(
      name: 'Tasks',
      imagePath: 'assets/images/tasks.png',
      icon: Icons.assignment_rounded,
    ),*/
    NavigationItem(
        name: 'Messages',
        imagePath: 'assets/images/messages.png',
        icon: Icons.forum_rounded,
        permissionKey: ''),
    NavigationItem(
        name: 'Profile',
        imagePath: 'assets/images/profile.png',
        icon: Icons.person_rounded,
        permissionKey: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    return BlocListener<ConfigurationBloc, ConfigurationState>(
      listener: (context, state) {
        if (state is ConfigurationLoaded) {
          setState(() {
            _configuration = state.config;
            _schoolLogo = state.config.logoUrl;
            _schoolName = state.config.schoolName.isNotEmpty
                ? state.config.schoolName
                : 'Your School';
          });
        } else if (state is ConfigurationEmpty) {
          setState(() {
            _schoolName = 'Your School';
            _schoolLogo = null;
          });
        } else if (state is ConfigurationError) {
          // Handle error - could show a snackbar or keep default values
          setState(() {
            _schoolName = 'Your School';
            _schoolLogo = null;
          });
          // Optionally show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load school configuration'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.colorScheme.background,
        appBar: isSmallScreen ? _buildAppBar(theme) : null,
        drawer: isSmallScreen ? _buildDrawer(theme) : null,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSmallScreen)
                _buildSideNavigation(theme, size.width >= 1200),
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      title: Text('Staff Dashboard',
          style: TextStyle(
              color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu, color: theme.colorScheme.primary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // Branding Section - Updated with Configuration
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildSchoolLogo(theme, 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _schoolName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Student Portal',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.8),
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor:
                        theme.colorScheme.primary.withOpacity(0.1),
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

  Widget _buildSchoolLogo(ThemeData theme, double size) {
    if (_schoolLogo != null && _schoolLogo!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _schoolLogo!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.school,
              size: size * 0.6,
              color: theme.colorScheme.primary,
            );
          },
        ),
      );
    } else {
      return Icon(
        Icons.school,
        size: size * 0.6,
        color: theme.colorScheme.primary,
      );
    }
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
                _buildSchoolLogo(theme, isExpanded ? 50 : 40),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _schoolName,
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
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: _logout,
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pop(context);
    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }

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

  Widget _buildTopBar(ThemeData theme, bool isLargeScreen) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Text(
            _navItems[_selectedIndex].name,
            style: theme.textTheme.titleLarge,
          ),
          const Spacer(),
          Text(
            "Welcome, ${widget.user.displayName} (${widget.user.role})",
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
