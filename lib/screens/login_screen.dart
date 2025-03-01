import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/auth/auth_event.dart';
import 'package:sms/bloc/auth/auth_state.dart';
import 'package:sms/screens/home_screen_staff.dart';
import 'package:sms/screens/home_screen_student.dart';
import 'package:sms/screens/home_screen_admin.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/feed/feed_bloc.dart';
import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/staffs/staff_bloc.dart';
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
        } else if (state is AuthAuthenticated) {
          _navigateToHomeScreen(context, state.user);
        } else if (state is AuthUnauthenticated) {
          // Instead of navigating to "Login", just ensure we're already on login
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
        body: SafeArea(
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
      ),
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
                        'Manage your educational journey efficiently with our comprehensive school management platform.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          _buildFeatureItem(Icons.security, 'Secure Access'),
                          const SizedBox(width: 24),
                          _buildFeatureItem(Icons.devices, 'Cross-Platform'),
                          const SizedBox(width: 24),
                          _buildFeatureItem(Icons.analytics, 'Real-time Reports'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
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

  Widget _buildLoginForm(ThemeData theme, AuthBloc authBloc, {required bool isWeb}) {
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
            'Welcome Back',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isWeb ? theme.colorScheme.primary : theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Sign in to continue',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

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
                          value: 'Student',
                          icon: Icons.school,
                          label: 'Student',
                        ),
                      ),
                      Expanded(
                        child: _buildUserTypeOption(
                          value: 'Staff',
                          icon: Icons.business_center,
                          label: 'Staff',
                        ),
                      ),
                      Expanded(
                        child: _buildUserTypeOption(
                          value: 'Admin',
                          icon: Icons.admin_panel_settings,
                          label: 'Admin',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

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
          const SizedBox(height: 16),

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
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                : const Text(
              'Log In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),
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

  void _navigateToHomeScreen(BuildContext context, User user) {
    Widget homeScreen;
    final WebService webService = WebService(baseUrl: 'https://mock.apidog.com/m1/820032-799426-default');
    final AuthRepository authRepository = AuthRepository(webService: webService);
    final DashboardRepository dashboardRepository = DashboardRepository(webService: webService);
    final ClassRepository classRepository = ClassRepository(webService: webService);
    final StudentsRepository studentsRepository = StudentsRepository(webService: webService);
    final StaffRepository staffRepository = StaffRepository(webService: webService);
    final HolidayRepository holidayRepository = HolidayRepository(webService: webService);
    final PostRepository postRepository = PostRepository(webService: webService);
    final FeedRepository feedRepository = FeedRepository(webService: webService);

    switch (user.userType) {
      case 'Student':
        homeScreen = StudentHomeScreen(user: user);
        break;
      case 'Staff':
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<ClassesBloc>(
              create: (context) => ClassesBloc(repository: classRepository, user: user),
            ),
            // Add other Blocs here if needed
          ],
          child: StaffHomeScreen(user: user),
        );
        break;
      case 'Admin':
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<DashboardBloc>(
              create: (context) => DashboardBloc(repository: dashboardRepository),
            ),
            BlocProvider<ClassesBloc>(
              create: (context) => ClassesBloc(repository: classRepository, user: user),
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
            // Add other Blocs here if needed
          ],
          child: HomeScreenAdmin(user: user),
        );
        break;
      default:
        homeScreen = StudentHomeScreen(user: user);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

}