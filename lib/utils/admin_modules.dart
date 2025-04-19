import 'package:flutter/material.dart';
import '../models/user.dart';
import '../screens/dashboard_screen.dart';
import '../screens/fees_screen.dart';
import '../screens/new_student_screen.dart';
import '../screens/new_staff_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/subjects_screen.dart';
import '../screens/staffs_screen.dart';
import '../screens/exam/exam_list_screen.dart';
import '../screens/holiday_screen.dart';
import '../screens/posts_screen.dart';
import '../screens/admin_permission_screen.dart';
import '../screens/theme_screen.dart';
import '../screens/complaint_list_screen.dart';
import '../screens/library/library_home_screen.dart';
import '../screens/configuration_screen.dart';
import '../screens/admin_permission_screen.dart';

class NavigationModule {
  final String permissionKey;
  final String name;
  final IconData icon;
  final Widget Function(User user) screenBuilder;

  NavigationModule({
    required this.permissionKey,
    required this.name,
    required this.icon,
    required this.screenBuilder,
  });
}

final allModules = [
  NavigationModule(
    permissionKey: 'dashboard',
    name: 'Dashboard',
    icon: Icons.pie_chart,
    screenBuilder: (_) => const DashboardScreen(),
  ),
  NavigationModule(
    permissionKey: 'new_student',
    name: 'New Admission',
    icon: Icons.person_add_rounded,
    screenBuilder: (_) => const NewStudentScreen(),
  ),
  NavigationModule(
    permissionKey: 'new_staff',
    name: 'New Staff',
    icon: Icons.person_pin_outlined,
    screenBuilder: (_) => const StaffRegistrationScreen(),
  ),
  NavigationModule(
    permissionKey: 'classes',
    name: 'Classes',
    icon: Icons.class_rounded,
    screenBuilder: (user) => ClassesScreen(user: user),
  ),
  NavigationModule(
    permissionKey: 'subjects',
    name: 'Subject',
    icon: Icons.subject,
    screenBuilder: (_) => SubjectsScreen(),
  ),
  NavigationModule(
    permissionKey: 'staffs',
    name: 'Staff',
    icon: Icons.badge_rounded,
    screenBuilder: (_) => StaffsScreen(),
  ),
  NavigationModule(
    permissionKey: 'students',
    name: 'Students',
    icon: Icons.school_rounded,
    screenBuilder: (_) => const Center(child: Text('Students - Development In Progress')),
  ),
  NavigationModule(
    permissionKey: 'exams',
    name: 'Exams',
    icon: Icons.assessment_outlined,
    screenBuilder: (_) => ExamsListScreen(),
  ),
  NavigationModule(
    permissionKey: 'holidays',
    name: 'Holiday Calendar',
    icon: Icons.event_rounded,
    screenBuilder: (_) => HolidayScreen(),
  ),
  NavigationModule(
    permissionKey: 'posts',
    name: 'Posts',
    icon: Icons.article_rounded,
    screenBuilder: (_) => PostsScreen(),
  ),
  NavigationModule(
    permissionKey: 'fees',
    name: 'Fees',
    icon: Icons.payments_rounded,
    screenBuilder: (_) => AdminFeesScreen(),
  ),
  NavigationModule(
    permissionKey: 'themes',
    name: 'Themes',
    icon: Icons.color_lens_rounded,
    screenBuilder: (_) => ThemeScreen(),
  ),
  NavigationModule(
    permissionKey: 'complaints',
    name: 'Complaints',
    icon: Icons.report_problem_rounded,
    screenBuilder: (_) => ComplaintListScreen(),
  ),
  NavigationModule(
    permissionKey: 'library',
    name: 'Library',
    icon: Icons.menu_book_rounded,
    screenBuilder: (_) => LibraryHomeScreen(),
  ),
  NavigationModule(
    permissionKey: 'configuration',
    name: 'Configuration',
    icon: Icons.settings,
    screenBuilder: (_) => const ConfigurationScreen(),
  ),
  NavigationModule(
    permissionKey: 'permissions',
    name: 'Permissions',
    icon: Icons.perm_identity_rounded,
    screenBuilder: (_) => AdminPermissionScreen(),
  ),
];
