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
import '../models/user.dart';
import '../models/client.dart';
import '../repositories/auth_repository.dart';
import '../repositories/class_repository.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  bool _isLoading = false;
  bool _isOtpMode = false;
  bool _isOtpSent = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Client
  List<Client> _clients = [];
  Client? _selectedClient;
  bool _isLoadingClients = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _loadRememberMeSettings();
    if (!kIsWeb) {
      await _loadClientData();
    }
  }

  Future<void> _loadRememberMeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _mobileController.text = prefs.getString('savedMobile') ?? '';
        _emailController.text = prefs.getString('savedEmail') ?? '';
      }
    });
  }

  Future<void> _saveRememberMeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);

    if (_rememberMe) {
      await prefs.setString('savedMobile', _mobileController.text);
      await prefs.setString('savedEmail', _emailController.text);
    } else {
      await prefs.remove('savedMobile');
      await prefs.remove('savedEmail');
    }
  }

  Future<void> _loadClientData() async {
    setState(() => _isLoadingClients = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = prefs.getString('clients');
      final selectedClientId = prefs.getString('selectedClientId');

      if (clientsJson != null && clientsJson.isNotEmpty) {
        final clientsList = Client.fromJsonList(clientsJson);
        setState(() {
          _clients = clientsList;
          if (selectedClientId != null) {
            _selectedClient = _clients.firstWhere(
                  (client) => client.id == selectedClientId,
              orElse: () => _clients.first,
            );
            // Save tenant ID to Constants
            Constants.tenantId = _selectedClient?.id ?? '';
          }
        });
      }

      if (_clients.isEmpty) {
        await _fetchClientData();
      }
    } catch (e) {
      await _fetchClientData();
    } finally {
      setState(() => _isLoadingClients = false);
    }
  }

  Future<void> _fetchClientData() async {
    try {
      setState(() => _isLoadingClients = true);

      final authRepository = AuthRepository(
        webService: WebService(baseUrl: Constants.baseUrl),
      );

      final clients = await authRepository.fetchClients();

      if (clients.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('clients', Client.toJsonList(clients));

        setState(() => _clients = clients);

        if (_selectedClient == null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showClientBottomSheet();
          });
        }
      }
    } catch (e) {
      _showSnackbar('Failed to load schools', isError: true);
    } finally {
      setState(() => _isLoadingClients = false);
    }
  }

  Future<void> _selectClient(Client client) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedClientId', client.id);

    setState(() => _selectedClient = client);

    // Save tenant ID to Constants
    Constants.tenantId = client.id;

    Navigator.pop(context);
  }

  void _showClientBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Your School',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          client.name.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        client.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(client.schemaName),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectClient(client),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthState,
      child: Scaffold(
        body: _isLoadingClients && !kIsWeb
            ? _buildLoadingScreen()
            : Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildLoginCard(authBloc),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading schools...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(AuthBloc authBloc) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 600;

    return Container(
      constraints: BoxConstraints(maxWidth: isWeb ? 400 : double.infinity),
      child: Card(
        elevation: isWeb ? 8 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildLoginToggle(),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isOtpMode
                      ? _buildOtpForm(authBloc)
                      : _buildPasswordForm(authBloc),
                ),
                const SizedBox(height: 16),
                _buildRememberMe(),
                const SizedBox(height: 24),
                _buildLoginButton(authBloc),
                if (!kIsWeb && _selectedClient != null) ...[
                  const SizedBox(height: 16),
                  _buildChangeSchoolButton(),
                ],
                const SizedBox(height: 16),
                const LanguageSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.school,
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          _selectedClient?.name ?? 'School Management System',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              title: 'Mobile',
              icon: Icons.phone,
              isSelected: !_isOtpMode,
              onTap: () => setState(() {
                _isOtpMode = false;
                _isOtpSent = false;
              }),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              title: 'Email',
              icon: Icons.email,
              isSelected: _isOtpMode,
              onTap: () => setState(() {
                _isOtpMode = true;
                _passwordController.clear();
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm(AuthBloc authBloc) {
    return Column(
      key: const ValueKey('password'),
      children: [
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Enter mobile number';
            if (value!.length < 10) return 'Enter valid mobile number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          prefixIcon: Icons.lock,
          obscureText: _obscurePassword,
          validator: (value) => value?.isEmpty ?? true ? 'Enter password' : null,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm(AuthBloc authBloc) {
    return Column(
      key: const ValueKey('otp'),
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isOtpSent,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Enter email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Enter valid email';
            }
            return null;
          },
        ),
        if (_isOtpSent) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _otpController,
            label: 'OTP Code',
            prefixIcon: Icons.security,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Enter OTP';
              if (value!.length != 6) return 'OTP must be 6 digits';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() {
                _isOtpSent = false;
                _otpController.clear();
              }),
              child: const Text('Change Email'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Remember me',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthBloc authBloc) {
    String buttonText = 'Sign In';
    if (_isOtpMode && !_isOtpSent) {
      buttonText = 'Send OTP';
    } else if (_isOtpMode && _isOtpSent) {
      buttonText = 'Verify OTP';
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleLogin(authBloc),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChangeSchoolButton() {
    return OutlinedButton.icon(
      onPressed: _showClientBottomSheet,
      icon: const Icon(Icons.swap_horiz, size: 18),
      label: const Text('Change School'),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  void _handleLogin(AuthBloc authBloc) {
    if (_formKey.currentState!.validate()) {
      _saveRememberMeSettings();

      if (_isOtpMode) {
        if (!_isOtpSent) {
          authBloc.add(GetOtpRequested(_emailController.text));
        } else {
          authBloc.add(VerifyOtpRequested(_emailController.text, _otpController.text));
        }
      } else {
        authBloc.add(LoginButtonPressed(
          email: _mobileController.text,
          password: _passwordController.text,
          userType: 'Student',
        ));
      }
    }
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    setState(() => _isLoading = state is AuthLoading);

    if (state is AuthFailure) {
      _showSnackbar(state.error, isError: true);
    } else if (state is AuthAuthenticated) {
      _navigateToHome(state.users, state.activeUser);
    } else if (state is AuthMultipleUsers) {
      _navigateToHome(state.users, null);
    } else if (state is OtpSent) {
      setState(() => _isOtpSent = true);
      _showSnackbar('OTP sent to your email');
    } else if (state is OtpVerified) {
      _navigateToHome(state.users, state.selectedUser);
    } else if (state is OtpFailure) {
      _showSnackbar(state.error, isError: true);
    }
  }

  void _navigateToHome(List<User> users, User? activeUser) {
    if (activeUser != null) {
      _navigateByRole(context, activeUser, users);
    } else {
      _showUserSelection(users);
    }
  }

  void _navigateByRole(BuildContext context, User selectedUser, List<User> users) {
    Widget homeScreen;
    final WebService webService = WebService(baseUrl: Constants.baseUrl);

    final classRepository = ClassRepository(webService: webService);

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
            ),
          ],
          child: StaffHomeScreen(user: selectedUser),
        );
        break;

      case Constants.admin:
        homeScreen = MultiBlocProvider(
          providers: [
            BlocProvider<ClassesBloc>(
              create: (context) => ClassesBloc(repository: classRepository, user: selectedUser),
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


  void _showUserSelection(List<User> users) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0] : '?',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(user.role),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(UserSelected(user, users));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}