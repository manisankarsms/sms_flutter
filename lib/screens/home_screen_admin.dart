import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sms/screens/admin_permission_screen.dart';
import 'package:sms/screens/classes_screen.dart';
import 'package:sms/screens/complaint_list_screen.dart';
import 'package:sms/screens/configuration_screen.dart';
import 'package:sms/screens/dashboard_screen.dart';
import 'package:sms/screens/exam/exam_list_screen.dart';
import 'package:sms/screens/fees_screen.dart';
import 'package:sms/screens/holiday_screen.dart';
import 'package:sms/screens/library/library_home_screen.dart';
import 'package:sms/screens/library/library_screen.dart';
import 'package:sms/screens/new_staff_screen.dart';
import 'package:sms/screens/new_student_screen.dart';
import 'package:sms/screens/posts_screen.dart';
import 'package:sms/screens/rules_screen.dart';
import 'package:sms/screens/staffs_screen.dart';
import 'package:sms/screens/student_admin_screen.dart';
import 'package:sms/screens/subjects_screen.dart';
import 'package:sms/screens/theme_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/configuration/configuration_bloc.dart';
import '../bloc/configuration/configuration_event.dart';
import '../bloc/configuration/configuration_state.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../models/configuration.dart';
import 'login_screen.dart';

class HomeScreenAdmin extends StatefulWidget {
  final User user;

  const HomeScreenAdmin({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenAdminState createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _screens;
  late List<NavigationItem> items;

  // Configuration data
  Configuration? _configuration;

  @override
  void initState() {
    super.initState();
    // Initialize with filtered navigation items based on permissions
    items = _getFilteredNavigationItems();
    _screens = _buildScreens(widget.user);

    // Load configuration data
    context.read<ConfigurationBloc>().add(LoadConfiguration());
  }

  // Method to filter navigation items based on permissions
  List<NavigationItem> _getFilteredNavigationItems() {
    // Define all available navigation items with their permission keys
    final List<NavigationItem> allItems = [
      NavigationItem(
        name: 'Dashboard',
        imagePath: 'assets/images/students.png',
        icon: Icons.pie_chart,
        permissionKey: 'dashboard',
      ),
      NavigationItem(
        name: 'New Admission',
        imagePath: 'assets/images/students.png',
        icon: Icons.person_add_rounded,
        permissionKey: 'new_student',
      ),
      NavigationItem(
        name: 'New Staff',
        imagePath: 'assets/images/students.png',
        icon: Icons.person_pin_outlined,
        permissionKey: 'new_staff',
      ),
      NavigationItem(
        name: 'Classes',
        imagePath: 'assets/images/calendar.png',
        icon: Icons.class_rounded,
        permissionKey: 'classes',
      ),
      NavigationItem(
        name: 'Subject',
        imagePath: 'assets/images/calendar.png',
        icon: Icons.subject,
        permissionKey: 'subjects',
      ),
      NavigationItem(
        name: 'Staff',
        imagePath: 'assets/images/messages.png',
        icon: Icons.badge_rounded,
        permissionKey: 'staff',
      ),
      NavigationItem(
        name: 'Students',
        imagePath: 'assets/images/attendance.png',
        icon: Icons.school_rounded,
        permissionKey: 'students',
      ),
      NavigationItem(
        name: 'Exams',
        imagePath: 'assets/images/attendance.png',
        icon: Icons.assessment_outlined,
        permissionKey: 'exams',
      ),
      NavigationItem(
        name: 'Holiday Calendar',
        imagePath: 'assets/images/calendar.png',
        icon: Icons.event_rounded,
        permissionKey: 'holiday',
      ),
      NavigationItem(
        name: 'Posts',
        imagePath: 'assets/images/posts.png',
        icon: Icons.article_rounded,
        permissionKey: 'posts',
      ),
      NavigationItem(
        name: 'Fees',
        imagePath: 'assets/images/fees.png',
        icon: Icons.payments_rounded,
        permissionKey: 'fees',
      ),
      NavigationItem(
        name: 'Rules',
        imagePath: 'assets/images/fees.png',
        icon: Icons.rule,
        permissionKey: 'rules',
      ),
      NavigationItem(
        name: 'Themes',
        imagePath: 'assets/images/themes.png',
        icon: Icons.color_lens_rounded,
        permissionKey: 'themes',
      ),
      NavigationItem(
        name: 'Complaints',
        imagePath: 'assets/images/complaints.png',
        icon: Icons.report_problem_rounded,
        permissionKey: 'complaints',
      ),
      NavigationItem(
        name: 'Library',
        imagePath: 'assets/images/library.png',
        icon: Icons.menu_book_rounded,
        permissionKey: 'library',
      ),
      NavigationItem(
        name: 'Configuration',
        imagePath: 'assets/images/library.png',
        icon: Icons.settings,
        permissionKey: 'configuration',
      ),
      NavigationItem(
        name: 'Permissions',
        imagePath: 'assets/images/library.png',
        icon: Icons.perm_identity_rounded,
        permissionKey: 'permissions',
      )
    ];

    // If user is admin with no specific permissions or contains '*', show all items
    if (widget.user.role.toLowerCase() == "admin" &&
        (widget.user.permissions == null ||
            widget.user.permissions!.isEmpty ||
            widget.user.permissions!.contains('*'))) {
      return allItems;
    }

    // Filter items based on user permissions
    return allItems.where((item) =>
    widget.user.permissions != null &&
        widget.user.permissions!.contains(item.permissionKey)
    ).toList();
  }

  List<Widget> _buildScreens(User user) {
    // Create a full list of screens
    final allScreens = [
      const DashboardScreen(),
      const NewStudentScreen(),
      const StaffRegistrationScreen(),
      Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => ClassesScreen(user: user),
        ),
      ),
      SubjectsScreen(),
      StaffsScreen(),
      UserAdminScreen(),
      ExamsListScreen(),
      HolidayScreen(user: user),
      PostsScreen(),
      AdminFeesScreen(),
      RulesScreen(user: user),
      ThemeScreen(),
      ComplaintListScreen(),
      LibraryHomeScreen(),
      const ConfigurationScreen(),
      AdminPermissionScreen(),
    ];

    // If showing all screens (admin with no filter)
    if (items.length == allScreens.length) {
      return allScreens;
    }

    // Filter screens based on permissions
    final List<Widget> filteredScreens = [];
    for (var i = 0; i < items.length; i++) {
      // Find the original index of this item in the all items list
      final originalIndex = allItems.indexWhere(
              (item) => item.permissionKey == items[i].permissionKey
      );

      // Add the corresponding screen if found
      if (originalIndex >= 0 && originalIndex < allScreens.length) {
        filteredScreens.add(allScreens[originalIndex]);
      }
    }
    return filteredScreens;
  }

  // Define the complete list to reference original indexes
  final List<NavigationItem> allItems = [
    NavigationItem(
      name: 'Dashboard',
      imagePath: 'assets/images/students.png',
      icon: Icons.pie_chart,
      permissionKey: 'dashboard',
    ),
    NavigationItem(
      name: 'New Admission',
      imagePath: 'assets/images/students.png',
      icon: Icons.person_add_rounded,
      permissionKey: 'new_student',
    ),
    NavigationItem(
      name: 'New Staff',
      imagePath: 'assets/images/students.png',
      icon: Icons.person_pin_outlined,
      permissionKey: 'new_staff',
    ),
    NavigationItem(
      name: 'Classes',
      imagePath: 'assets/images/calendar.png',
      icon: Icons.class_rounded,
      permissionKey: 'classes',
    ),
    NavigationItem(
      name: 'Subject',
      imagePath: 'assets/images/calendar.png',
      icon: Icons.subject,
      permissionKey: 'subjects',
    ),
    NavigationItem(
      name: 'Staff',
      imagePath: 'assets/images/messages.png',
      icon: Icons.badge_rounded,
      permissionKey: 'staff',
    ),
    NavigationItem(
      name: 'Students',
      imagePath: 'assets/images/attendance.png',
      icon: Icons.school_rounded,
      permissionKey: 'students',
    ),
    NavigationItem(
      name: 'Exams',
      imagePath: 'assets/images/attendance.png',
      icon: Icons.assessment_outlined,
      permissionKey: 'exams',
    ),
    NavigationItem(
      name: 'Holiday Calendar',
      imagePath: 'assets/images/calendar.png',
      icon: Icons.event_rounded,
      permissionKey: 'holiday',
    ),
    NavigationItem(
      name: 'Posts',
      imagePath: 'assets/images/posts.png',
      icon: Icons.article_rounded,
      permissionKey: 'posts',
    ),
    NavigationItem(
      name: 'Fees',
      imagePath: 'assets/images/fees.png',
      icon: Icons.payments_rounded,
      permissionKey: 'fees',
    ),
    NavigationItem(
      name: 'Themes',
      imagePath: 'assets/images/themes.png',
      icon: Icons.color_lens_rounded,
      permissionKey: 'themes',
    ),
    NavigationItem(
      name: 'Complaints',
      imagePath: 'assets/images/complaints.png',
      icon: Icons.report_problem_rounded,
      permissionKey: 'complaints',
    ),
    NavigationItem(
      name: 'Library',
      imagePath: 'assets/images/library.png',
      icon: Icons.menu_book_rounded,
      permissionKey: 'library',
    ),
    NavigationItem(
      name: 'Configuration',
      imagePath: 'assets/images/library.png',
      icon: Icons.settings,
      permissionKey: 'configuration',
    ),
    NavigationItem(
      name: 'Permissions',
      imagePath: 'assets/images/library.png',
      icon: Icons.perm_identity_rounded,
      permissionKey: 'permissions',
    )
  ];

  // Helper method to build logo widget
  Widget _buildLogo({required double size, bool showDefault = true}) {
    if (_configuration?.logoUrl != null && _configuration!.logoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _configuration!.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: CircularProgressIndicator(
              strokeWidth: size > 40 ? 3 : 2,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => showDefault
              ? CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.grey,
            child: Icon(Icons.school, size: size * 0.6, color: Colors.white),
          )
              : const SizedBox.shrink(),
        ),
      );
    }

    // Fallback to asset image if no logo URL
    return showDefault
        ? ClipOval(
      child: Image.asset(
        'assets/images/school_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey,
          child: Icon(Icons.school, size: size * 0.6, color: Colors.white),
        ),
      ),
    )
        : CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey,
      child: Icon(Icons.school, size: size * 0.6, color: Colors.white),
    );
  }

  // Helper method to get school name
  String get _schoolName {
    return _configuration?.schoolName ?? 'School Management';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1200;
    final isLargeScreen = size.width >= 1200;

    return BlocListener<ConfigurationBloc, ConfigurationState>(
      listener: (context, state) {
        if (state is ConfigurationLoaded) {
          setState(() {
            _configuration = state.config;
          });
        } else if (state is ConfigurationError) {
          // Optionally show a snackbar or handle error
          debugPrint('Configuration load error: ${state.message}');
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
              // Side Navigation for medium and large screens
              if (!isSmallScreen) _buildSideNavigation(theme, isLargeScreen),

              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Top app bar for medium and large screens
                    if (!isSmallScreen) _buildTopBar(theme, isLargeScreen),

                    // Main content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: _screens[_selectedIndex],
                      ),
                    ),
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
      title: Text(
        _schoolName,
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
            items[_selectedIndex].name,
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
            onPressed: () {
              // Handle notifications
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              // Handle help
            },
          ),
          const SizedBox(width: 16),
          PopupMenuButton<dynamic>(
            offset: const Offset(0, 45),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    'A',
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
                        'Admin User',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Administrator',
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
              // Handle menu selection based on the value
            },
            itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
              PopupMenuItem<String>(
                value: 'profile', // Add value
                child: Row(
                  children: [
                    Icon(Icons.person_outline,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings', // Add value
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                onTap: _confirmLogout,
                value: 'logout', // Add value
                child: Row(
                  children: [
                    Icon(Icons.logout, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                  _buildLogo(size: 60),
                  const SizedBox(height: 12),
                  Text(
                    _schoolName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: items.asMap().entries.map((entry) {
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

  Widget _buildSideNavigation(ThemeData theme, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 250 : 80,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Branding Space at top of sidebar
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: isExpanded
                ? Container(
              key: const ValueKey('expanded-header'),
              height: 100,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildLogo(size: 50),
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
              ),
            )
                : Container(
              key: const ValueKey('collapsed-header'),
              height: 100,
              width: 80,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: _buildLogo(size: 40),
            ),
          ),
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                // Completely different widgets for expanded vs collapsed states
                if (isExpanded) {
                  // Full ListTile for expanded state
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
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
                } else {
                  // Icon-only for collapsed state (NO ROW WIDGET)
                  return IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    icon: Icon(
                      item.icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    isSelected: isSelected,
                    selectedIcon: Icon(
                      item.icon,
                      color: theme.colorScheme.primary,
                    ),
                  );
                }
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Logout Option
          isExpanded
              ? ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
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
          )
              : IconButton(
            padding: const EdgeInsets.symmetric(vertical: 8),
            icon: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            onPressed: _confirmLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    // If we have fewer than 2 items, don't show a bottom nav at all
    if (items.length < 2) {
      return const SizedBox.shrink(); // Return an empty widget
    }
    // Get the items to show based on permissions and limit to 4 for bottom nav
    List<BottomNavigationBarItem> visibleItems = [];

    if (items.length <= 4) {
      // If we have 4 or fewer items, show them all
      visibleItems = items
          .map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.name
      ))
          .toList();
    } else {
      // Show first 3 items and a "More" option
      visibleItems = items
          .take(3)
          .map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.name
      ))
          .toList();

      // Add the More option
      visibleItems.add(const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More'
      ));
    }

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
        currentIndex: _selectedIndex >= visibleItems.length - 1 && visibleItems.length == 4
            ? 3  // Select "More" if current index is beyond visible items
            : _selectedIndex.clamp(0, visibleItems.length - 1),
        onTap: (int index) {
          if (visibleItems.length == 4 && index == 3 && items.length > 3) {
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
        items: visibleItems,
      ),
    );
  }

// Function to show overflow menu
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: items.skip(4).map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              onTap: () {
                setState(() {
                  _selectedIndex = items.indexOf(item);
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
}

class NavigationItem extends Item {
  final IconData icon;
  final String permissionKey;

  NavigationItem({
    required String name,
    required String imagePath,
    required this.icon,
    required this.permissionKey,
  }) : super(name: name, imagePath: imagePath);
}
