import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/auth/auth_event.dart';
import 'package:sms/bloc/auth/auth_state.dart';
import 'package:sms/screens/home_screen_staff.dart';
import 'package:sms/screens/home_screen_student.dart';
import 'package:sms/screens/home_screen_admin.dart';
import 'package:sms/utils/language_selector.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/classes_staff/staff_classes_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/feed/feed_bloc.dart';
import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/staffs/staff_bloc.dart';
import '../dev_only/debug_overlay.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/class_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/feed_repository.dart';
import '../repositories/holiday_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/staff_repository.dart';
import '../repositories/students_repository.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _userType = 'Student';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isMockEnvironment = false; // Track the current environment
  bool _showDebugConsole = false;

  @override
  void initState() {
    super.initState();
    _loadEnvironmentSetting();
  }


  // Load environment setting from preferences
  Future<void> _loadEnvironmentSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMockEnvironment = prefs.getBool('isMockEnvironment') ?? false;
      // Update the Constants.baseUrl upon initialization
      Constants.baseUrl = _isMockEnvironment
          ? Constants.mockBaseUrl
          : Constants.prodBaseUrl;
    });
  }

  // Save environment setting to preferences
  Future<void> _saveEnvironmentSetting(bool isMock) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMockEnvironment', isMock);
    setState(() {
      _isMockEnvironment = isMock;
      // Update the baseUrl when the setting changes
      Constants.baseUrl = isMock
          ? Constants.mockBaseUrl
          : Constants.prodBaseUrl;
    });
  }

  void _toggleDebugConsole() {
    setState(() {
      _showDebugConsole = !_showDebugConsole;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        setState(() => _isLoading = state is AuthLoading);

        if (state is AuthFailure) {
          _showErrorSnackbar(state.error);
        } if (state is AuthAuthenticated) {
          _navigateToHomeScreen(context, state.users, state.activeUser);
        } else if (state is AuthMultipleUsers) {
          _navigateToHomeScreen(context, state.users, null); // Call user selection dialog
        } else if (state is AuthUnauthenticated) {
          if (ModalRoute.of(context)?.settings.name != '/login') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.bug_report,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _toggleDebugConsole(),
              tooltip: 'Debug Console',
            ),
            // Settings button
            IconButton(
              icon: Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showEnvironmentSelectionDialog(),
              tooltip: 'Environment Settings',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main login content
            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.background,
                    ],
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return kIsWeb && !isSmallScreen
                            ? _buildWebLayout(theme, authBloc)
                            : _buildMobileLayout(theme, authBloc);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Debug console overlay
            if (_showDebugConsole) DebugConsoleOverlay(),
          ],
        ),
      ),
    );
  }

  void _showEnvironmentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Environment Settings'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Environment:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<bool>(
                    title: Text('Production'),
                    value: false,
                    groupValue: _isMockEnvironment,
                    onChanged: (value) {
                      setDialogState(() {
                        _isMockEnvironment = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text('Mock (Development)'),
                    value: true,
                    groupValue: _isMockEnvironment,
                    onChanged: (value) {
                      setDialogState(() {
                        _isMockEnvironment = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Base URL:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isMockEnvironment
                        ? Constants.mockBaseUrl
                        : Constants.prodBaseUrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveEnvironmentSetting(_isMockEnvironment);
                Navigator.pop(context);
                // Show a confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Environment changed to ${_isMockEnvironment ? 'Mock' : 'Production'}',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebLayout(ThemeData theme, AuthBloc authBloc) {
    return Center(
      child: Container(
        width: 1000,
        margin: const EdgeInsets.symmetric(vertical: 32),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Left side - Illustration/Branding
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/students.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'School Management System',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.app_description ??
                            'Manage your educational journey efficiently with our comprehensive school management platform.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 24, // Horizontal spacing
                        runSpacing: 16, // Vertical spacing when wrapping
                        children: [
                          _buildFeatureItem(
                              Icons.security,
                              AppLocalizations.of(context)?.secure_access ??
                                  'Secure Access'),
                          _buildFeatureItem(
                              Icons.devices,
                              AppLocalizations.of(context)?.cross_platform ??
                                  'Cross-Platform'),
                          _buildFeatureItem(
                              Icons.analytics,
                              AppLocalizations.of(context)?.real_time_reports ??
                                  'Real-time Reports'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right side - Login Form
              Expanded(
                flex: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: _buildLoginForm(theme, authBloc, isWeb: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, AuthBloc authBloc) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _buildLoginForm(theme, authBloc, isWeb: false),
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthBloc authBloc,
      {required bool isWeb}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isWeb) ...[
            // Mobile Logo and title
            Center(
              child: Hero(
                tag: 'logo',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/students.png',
                    width: 80.0,
                    height: 80.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            AppLocalizations.of(context)?.welcome ?? "Welcome",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isWeb
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            AppLocalizations.of(context)?.sign_in_to_continue ??
            'Sign in to continue',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // User type selection
          Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      'I am a:',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUserTypeOption(
                          value: Constants.student,
                          icon: Icons.school,
                          label: AppLocalizations.of(context)?.student ??'Student',
                        ),
                      ),
                      Expanded(
                        child: _buildUserTypeOption(
                          value: Constants.staff,
                          icon: Icons.business_center,
                          label: AppLocalizations.of(context)?.staff ?? 'Staff',
                        ),
                      ),
                      Expanded(
                        child: _buildUserTypeOption(
                          value: Constants.admin,
                          icon: Icons.admin_panel_settings,
                          label: AppLocalizations.of(context)?.admin ?? 'Admin',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email field
          _buildTextField(
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            onChanged: (value) => _email = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              /*if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }*/
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Password field
          _buildTextField(
            label: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            onChanged: (value) => _password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text(
                AppLocalizations.of(context)?.forgot_password ??
                'Forgot Password?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _login(authBloc);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)?.login ??
                    'Log In',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Language Selection Dropdown (Using Bloc)
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LanguageSelector(), // Updated class now looks better!
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = _userType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _userType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefixIcon,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  void _login(AuthBloc authBloc) {
    authBloc.add(LoginButtonPressed(
      email: _email,
      password: _password,
      userType: _userType,
    ));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /*void _navigateToHomeScreen(BuildContext context, List<User> users) {
    Widget homeScreen;
    final WebService webService = WebService(baseUrl: Constants.baseUrl);
    final AuthRepository authRepository =
    AuthRepository(webService: webService);
    final DashboardRepository dashboardRepository =
    DashboardRepository(webService: webService);
    final ClassRepository classRepository =
    ClassRepository(webService: webService);
    final StudentsRepository studentsRepository =
    StudentsRepository(webService: webService);
    final StaffRepository staffRepository =
    StaffRepository(webService: webService);
    final HolidayRepository holidayRepository =
    HolidayRepository(webService: webService);
    final PostRepository postRepository =
    PostRepository(webService: webService);
    final FeedRepository feedRepository =
    FeedRepository(webService: webService);

    // Default to first user
    User activeUser = users.first;

    switch (activeUser.userType) {
      case 'Student':
        homeScreen = StudentHomeScreen(users: users, selectedUser: activeUser);
        break;
      case 'Staff':
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<ClassesBloc>(
              create: (context) =>
                  ClassesBloc(repository: classRepository, user: activeUser),
            ),
          ],
          child: StaffHomeScreen(user: activeUser),
        );
        break;
      case 'Admin':
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<DashboardBloc>(
              create: (context) =>
                  DashboardBloc(repository: dashboardRepository),
            ),
            BlocProvider<ClassesBloc>(
              create: (context) =>
                  ClassesBloc(repository: classRepository, user: activeUser),
            ),
            BlocProvider<StaffsBloc>(
              create: (context) => StaffsBloc(repository: staffRepository),
            ),
            BlocProvider<HolidayBloc>(
              create: (context) => HolidayBloc(repository: holidayRepository),
            ),
            BlocProvider<PostBloc>(
              create: (context) => PostBloc(postRepository: postRepository),
            ),
            BlocProvider<FeedBloc>(
              create: (context) => FeedBloc(feedRepository: feedRepository),
            ),
          ],
          child: HomeScreenAdmin(user: activeUser),
        );
        break;
      default:
        homeScreen = StudentHomeScreen(users: users, selectedUser: activeUser);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }*/

  void _navigateToHomeScreen(BuildContext context, List<User> users, User? activeUser) {
    if (activeUser != null) {
      // If an active user is already selected, navigate directly
      _navigateBasedOnUserType(context, activeUser, users);
    } else {
      // Otherwise, show user selection dialog
      _showUserSelectionDialog(context, users);
    }
  }


// Navigate based on user type
  void _navigateBasedOnUserType(BuildContext context, User selectedUser, List<User> users) {
    Widget homeScreen;
    final WebService webService = WebService(baseUrl: Constants.baseUrl);
    final AuthRepository authRepository = AuthRepository(webService: webService);
    final DashboardRepository dashboardRepository = DashboardRepository(webService: webService);
    final ClassRepository classRepository = ClassRepository(webService: webService);
    final StudentsRepository studentsRepository = StudentsRepository(webService: webService);
    final StaffRepository staffRepository = StaffRepository(webService: webService);
    final HolidayRepository holidayRepository = HolidayRepository(webService: webService);
    final PostRepository postRepository = PostRepository(webService: webService);
    final FeedRepository feedRepository = FeedRepository(webService: webService);

    switch (selectedUser.userType) {
      case 'Student':
        homeScreen = StudentHomeScreen(users: users, selectedUser: selectedUser);
        break;
      case 'Staff':
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<ClassesBloc>(
              create: (context) => ClassesBloc(repository: classRepository, user: selectedUser),
            ),
            BlocProvider<StaffClassesBloc>(
              create: (context) => StaffClassesBloc(repository: classRepository, user: selectedUser),
            ),
          ],
          child: StaffHomeScreen(user: selectedUser),
        );
        break;
      case 'Admin':
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<DashboardBloc>(
              create: (context) => DashboardBloc(repository: dashboardRepository),
            ),
            BlocProvider<ClassesBloc>(
              create: (context) => ClassesBloc(repository: classRepository, user: selectedUser),
            ),
            BlocProvider<StaffsBloc>(
              create: (context) => StaffsBloc(repository: staffRepository),
            ),
            BlocProvider<HolidayBloc>(
              create: (context) => HolidayBloc(repository: holidayRepository),
            ),
            BlocProvider<PostBloc>(
              create: (context) => PostBloc(postRepository: postRepository),
            ),
            BlocProvider<FeedBloc>(
              create: (context) => FeedBloc(feedRepository: feedRepository),
            ),
          ],
          child: HomeScreenAdmin(user: selectedUser),
        );
        break;
      default:
        homeScreen = StudentHomeScreen(users: users, selectedUser: selectedUser);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  void _showUserSelectionDialog(BuildContext context, List<User> users) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: users.map((user) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0] : "?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user.displayName),
                subtitle: Text(user.userType),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  context.read<AuthBloc>().add(UserSelected(user, users)); // Pass all users
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }


}
