import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/auth/auth_event.dart';
import 'package:sms/bloc/auth/auth_state.dart';
import 'package:sms/bloc/exam/exam_bloc.dart';
import 'package:sms/repositories/exam_repository.dart';
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
import '../models/client.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _mobileFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  // Mobile/Password Login Fields
  String _mobile = '';
  String _password = '';
  bool _rememberMeMobile = false;

  // Email/OTP Login Fields
  String _email = '';
  String _otp = '';
  bool _isOtpSent = false;
  bool _rememberMeOtp = false;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isMockEnvironment = false;
  bool _showDebugConsole = false;
  List<Client> _clients = [];
  Client? _selectedClient;
  bool _isLoadingClients = false;

  bool _isCustomEnvironment = false;
  String _customBaseUrl = '';

  // Tab controller
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
        // Reset form state when switching tabs
        _resetFormStates();
      });
    });
    _loadEnvironmentSetting();
    _loadClientData();
    _loadRememberMeSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resetFormStates() {
    _mobile = '';
    _password = '';
    _email = '';
    _otp = '';
    _isOtpSent = false;
    _mobileFormKey.currentState?.reset();
    _otpFormKey.currentState?.reset();
  }

  // Load Remember Me settings
  Future<void> _loadRememberMeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMeMobile = prefs.getBool('rememberMeMobile') ?? false;
      _rememberMeOtp = prefs.getBool('rememberMeOtp') ?? false;

      // Load saved credentials if remember me was enabled
      if (_rememberMeMobile) {
        _mobile = prefs.getString('savedMobile') ?? '';
      }
      if (_rememberMeOtp) {
        _email = prefs.getString('savedEmail') ?? '';
      }
    });
  }

  // Save Remember Me settings
  Future<void> _saveRememberMeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Save mobile form settings
    await prefs.setBool('rememberMeMobile', _rememberMeMobile);
    if (_rememberMeMobile) {
      await prefs.setString('savedMobile', _mobile);
    } else {
      await prefs.remove('savedMobile');
    }

    // Save email form settings
    await prefs.setBool('rememberMeOtp', _rememberMeOtp);
    if (_rememberMeOtp) {
      await prefs.setString('savedEmail', _email);
    } else {
      await prefs.remove('savedEmail');
    }
  }

  // Load client data from SharedPreferences
  Future<void> _loadClientData() async {
    if (kIsWeb) {
      return;
    }

    setState(() {
      _isLoadingClients = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getString('clients');
    final selectedClientId = prefs.getString('selectedClientId');

    if (clientsJson != null) {
      final clientsList = Client.fromJsonList(clientsJson);

      setState(() {
        _clients = clientsList;

        if (selectedClientId != null) {
          try {
            _selectedClient = _clients.firstWhere(
                  (client) => client.id == selectedClientId,
            );
          } catch (e) {
            _selectedClient = null;
          }
        }

        _isLoadingClients = false;
      });

      if (_selectedClient == null && _clients.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // _showClientSelectionDialog();
        });
      }
    } else {
      await _fetchClientData();
    }
  }

  // Fetch client data from API
  Future<void> _fetchClientData() async {
    try {
      setState(() {
        _isLoadingClients = true;
      });

      final authRepository = AuthRepository(
        webService: WebService(baseUrl: Constants.baseUrl),
      );

      final clients = await authRepository.fetchClients();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clients', Client.toJsonList(clients));

      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });

      if (_clients.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // _showClientSelectionDialog();
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingClients = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load client data: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      print('Error fetching client data: $e');
    }
  }

  // Reset client data
  Future<void> _resetClientData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clients');
    await prefs.remove('selectedClientId');

    setState(() {
      _clients = [];
      _selectedClient = null;
      Constants.baseUrl = _isMockEnvironment
          ? Constants.mockBaseUrl
          : Constants.prodBaseUrl;
    });

    _fetchClientData();
  }

  Future<void> _saveEnvironmentSetting({
    required bool isMock,
    required bool isCustom,
    required String customUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isMockEnvironment', isMock);
    await prefs.setBool('isCustomEnvironment', isCustom);
    await prefs.setString('customBaseUrl', customUrl);

    setState(() {
      _isMockEnvironment = isMock;
      _isCustomEnvironment = isCustom;
      _customBaseUrl = customUrl;

      Constants.baseUrl = isCustom
          ? customUrl
          : (isMock ? Constants.mockBaseUrl : Constants.prodBaseUrl);
    });
  }

  Future<void> _loadEnvironmentSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMockEnvironment = prefs.getBool('isMockEnvironment') ?? false;
      _isCustomEnvironment = prefs.getBool('isCustomEnvironment') ?? false;
      _customBaseUrl = prefs.getString('customBaseUrl') ?? '';

      Constants.baseUrl = _isCustomEnvironment
          ? _customBaseUrl
          : (_isMockEnvironment
          ? Constants.mockBaseUrl
          : Constants.prodBaseUrl);
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
        } else if (state is AuthAuthenticated) {
          _navigateToHomeScreen(context, state.users, state.activeUser);
        } else if (state is AuthMultipleUsers) {
          _navigateToHomeScreen(context, state.users, null);
        } else if (state is AuthUnauthenticated) {
          if (ModalRoute.of(context)?.settings.name != '/login') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          }
        } else if (state is OtpSent) {
          setState(() {
            _isOtpSent = true;
          });
          _showSuccessSnackbar('OTP sent to your email');
        } else if (state is OtpVerified) {
          _navigateToHomeScreen(context, state.users, state.selectedUser);
        } else if (state is OtpFailure) {
          _showErrorSnackbar(state.error);
        } else if (state is SessionExpired) {
          _showWarningSnackbar('Your session has expired. Please login again.');
        } else if (state is SessionExtended) {
          _showSuccessSnackbar('Session extended successfully');
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
                  child: _isLoadingClients && !kIsWeb
                      ? _buildLoadingIndicator(theme)
                      : SingleChildScrollView(
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
            if (_showDebugConsole) DebugConsoleOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Loading schools...',
          style: theme.textTheme.titleMedium,
        ),
      ],
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
                      _buildLogo(size: 120),
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
                        spacing: 24,
                        runSpacing: 16,
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

  Widget _buildLogo({double size = 100.0}) {
    Widget imageWidget;

    if (_selectedClient != null && _selectedClient!.logoUrl.isNotEmpty) {
      imageWidget = Image.network(
        _selectedClient!.logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/students.png',
          width: size,
          height: size,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/students.png',
        width: size,
        height: size,
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: imageWidget,
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthBloc authBloc, {required bool isWeb}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isWeb) ...[
          Center(
            child: Hero(
              tag: 'logo',
              child: _buildLogo(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        Text(
          _selectedClient != null
              ? 'Welcome to \n${_selectedClient!.name}'
              : (AppLocalizations.of(context)?.welcome ?? "Welcome"),
          style: theme.textTheme.displaySmall?.copyWith(
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
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(
                icon: Icon(Icons.phone),
                text: 'Mobile & Password',
              ),
              Tab(
                icon: Icon(Icons.email),
                text: 'Email & OTP',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tab Bar View
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMobilePasswordForm(theme, authBloc),
              _buildEmailOtpForm(theme, authBloc),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Language Selection
        Container(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: LanguageSelector(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePasswordForm(ThemeData theme, AuthBloc authBloc) {
    return Form(
      key: _mobileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            label: 'Mobile Number',
            prefixIcon: Icons.phone,
            onChanged: (value) => _mobile = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your mobile number';
              }
              if (value.length < 10) {
                return 'Please enter a valid mobile number';
              }
              return null;
            },
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),

          // Remember Me Checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMeMobile,
                onChanged: (value) {
                  setState(() {
                    _rememberMeMobile = value ?? false;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Remember me (7 days)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
              if (_mobileFormKey.currentState!.validate()) {
                _loginWithMobile(authBloc);
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
              AppLocalizations.of(context)?.login ?? 'Log In',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailOtpForm(ThemeData theme, AuthBloc authBloc) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            label: 'Email Address',
            prefixIcon: Icons.email_outlined,
            onChanged: (value) => _email = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            enabled: !_isOtpSent,
          ),
          const SizedBox(height: 16),
          if (!_isOtpSent) ...[
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                if (_otpFormKey.currentState!.validate()) {
                  _getOtp(authBloc);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
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
                'Send OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            _buildTextField(
              label: 'Enter OTP',
              prefixIcon: Icons.security,
              onChanged: (value) => _otp = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the OTP';
                }
                if (value.length != 6) {
                  return 'OTP must be 6 digits';
                }
                return null;
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Remember Me Checkbox for OTP
            Row(
              children: [
                Checkbox(
                  value: _rememberMeOtp,
                  onChanged: (value) {
                    setState(() {
                      _rememberMeOtp = value ?? false;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Remember me (7 days)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      setState(() {
                        _isOtpSent = false;
                        _otp = '';
                      });
                    },
                    child: Text(
                      'Change Email',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      if (_otpFormKey.currentState!.validate()) {
                        _verifyOtp(authBloc);
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
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildTextField({
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefixIcon,
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.5),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surface.withOpacity(0.5),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  void _loginWithMobile(AuthBloc authBloc) {
    // Since we removed user type selection, we'll use a default or derive it from the response
    authBloc.add(LoginButtonPressed(
      email: _mobile,
      password: _password,
      userType: 'Student', // Default user type, or you can modify your backend to handle this
    ));
  }

  void _getOtp(AuthBloc authBloc) {
    authBloc.add(GetOtpRequested(_email));
  }

  void _verifyOtp(AuthBloc authBloc) {
    authBloc.add(VerifyOtpRequested(_email, _otp));
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

  void _showSuccessSnackbar(String message) {
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

  void _showWarningSnackbar(String message) {
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
    final ExamRepository examRepository = ExamRepository(webService: webService);

    switch (selectedUser.role.toLowerCase()) {
      case Constants.student:
        homeScreen = StudentHomeScreen(users: users, selectedUser: selectedUser);
        break;
      case Constants.staff:
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<ClassesBloc>(
              create: (context) => ClassesBloc(repository: classRepository, user: selectedUser),
            ),
            BlocProvider<StaffClassesBloc>(
              create: (context) => StaffClassesBloc(repository: classRepository, user: selectedUser),
            ),BlocProvider<StaffClassesBloc>(
              create: (context) => StaffClassesBloc(repository: classRepository, user: selectedUser),
            ),
          ],
          child: StaffHomeScreen(user: selectedUser),
        );
        break;
      case Constants.admin:
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
            BlocProvider<ExamBloc>(
              create: (context) => ExamBloc(examRepository: examRepository),
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
                subtitle: Text(user.role),
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

  void _showEnvironmentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Environment Settings'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
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
                    RadioListTile<String>(
                      title: Text('Production'),
                      value: 'prod',
                      groupValue: _isCustomEnvironment
                          ? 'custom'
                          : (_isMockEnvironment ? 'mock' : 'prod'),
                      onChanged: (value) {
                        setDialogState(() {
                          _isMockEnvironment = false;
                          _isCustomEnvironment = false;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Mock (Development)'),
                      value: 'mock',
                      groupValue: _isCustomEnvironment
                          ? 'custom'
                          : (_isMockEnvironment ? 'mock' : 'prod'),
                      onChanged: (value) {
                        setDialogState(() {
                          _isMockEnvironment = true;
                          _isCustomEnvironment = false;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Custom'),
                      value: 'custom',
                      groupValue: _isCustomEnvironment
                          ? 'custom'
                          : (_isMockEnvironment ? 'mock' : 'prod'),
                      onChanged: (value) {
                        setDialogState(() {
                          _isCustomEnvironment = true;
                        });
                      },
                    ),
                    if (_isCustomEnvironment)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Custom Base URL',
                            hintText: 'https://your-api.com',
                          ),
                          controller: TextEditingController(text: _customBaseUrl),
                          onChanged: (value) {
                            _customBaseUrl = value;
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Base URL:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _isCustomEnvironment
                          ? _customBaseUrl
                          : (_isMockEnvironment
                          ? Constants.mockBaseUrl
                          : Constants.prodBaseUrl),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
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
                final baseUrl = _isCustomEnvironment
                    ? _customBaseUrl
                    : (_isMockEnvironment
                    ? Constants.mockBaseUrl
                    : Constants.prodBaseUrl);

                _saveEnvironmentSetting(
                  isMock: _isMockEnvironment,
                  isCustom: _isCustomEnvironment,
                  customUrl: _customBaseUrl,
                );

                Constants.baseUrl = baseUrl;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Environment set to ${_isCustomEnvironment ? 'Custom' : (_isMockEnvironment ? 'Mock' : 'Production')}',
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
}