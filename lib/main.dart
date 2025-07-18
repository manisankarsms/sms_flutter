import 'dart:ui';
import 'dart:convert'; // Add this import for JSON decoding
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Add this import for kIsWeb
import 'package:sms/repositories/fees_structure_repository.dart';

import 'bloc/classes/classes_bloc.dart';
import 'bloc/fees_structures/fees_structure_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sms/bloc/attendance/attendance_bloc.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/class_details/class_details_bloc.dart';
import 'package:sms/bloc/configuration/configuration_bloc.dart';
import 'package:sms/bloc/exam/exam_bloc.dart';
import 'package:sms/bloc/feed/feed_bloc.dart';
import 'package:sms/bloc/fees/fees_bloc.dart';
import 'package:sms/bloc/holiday/holiday_bloc.dart';
import 'package:sms/bloc/language/language_bloc.dart';
import 'package:sms/bloc/library/library_bloc.dart';
import 'package:sms/bloc/new_staff/new_staff_bloc.dart';
import 'package:sms/bloc/new_student/new_student_bloc.dart';
import 'package:sms/bloc/permissions/permissions_bloc.dart';
import 'package:sms/bloc/post/post_bloc.dart';
import 'package:sms/bloc/profile/profile_bloc.dart';
import 'package:sms/bloc/rules/rules_bloc.dart';
import 'package:sms/bloc/student_admin/student_bloc.dart';
import 'package:sms/bloc/student_dashboard/student_dashboard_bloc.dart';
import 'package:sms/bloc/students/students_bloc.dart';
import 'package:sms/bloc/subjects/subjects_bloc.dart';
import 'package:sms/repositories/attendance_repository.dart';
import 'package:sms/repositories/auth_repository.dart';
import 'package:sms/repositories/class_details_repository.dart';
import 'package:sms/repositories/class_repository.dart';
import 'package:sms/repositories/complaint_repository.dart';
import 'package:sms/repositories/complete_marks_repository.dart';
import 'package:sms/repositories/configuration_repository.dart';
import 'package:sms/repositories/dashboard_repository.dart';
import 'package:sms/repositories/exam_repository.dart';
import 'package:sms/repositories/feed_repository.dart';
import 'package:sms/repositories/fees_repository.dart';
import 'package:sms/repositories/holiday_repository.dart';
import 'package:sms/repositories/library_repository.dart';
import 'package:sms/repositories/permission_repository.dart';
import 'package:sms/repositories/post_repository.dart';
import 'package:sms/repositories/profile_repository.dart';
import 'package:sms/repositories/rules_repository.dart';
import 'package:sms/repositories/staff_repository.dart';
import 'package:sms/repositories/student_admin_repository.dart';
import 'package:sms/repositories/student_dashboard_repository.dart';
import 'package:sms/repositories/student_repository.dart';
import 'package:sms/repositories/students_repository.dart';
import 'package:sms/repositories/subjects_repository.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/screens/client_selection_screen.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/services/fcm_service.dart';
import 'package:sms/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'bloc/auth/auth_event.dart';
import 'bloc/complaint/complaint_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/language/language_state.dart';
import 'bloc/staffs/staff_bloc.dart';
import 'bloc/theme/theme_bloc.dart';
import 'dev_only/debug_logger.dart';

void main() async {
  // 🔥 Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase FIRST!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize FCM Service
  await FCMService.initialize();

  // ✅ Load any saved environment settings
  await _loadEnvironmentSettings();

  final WebService webService = WebService(baseUrl: Constants.baseUrl);
  final AuthRepository authRepository = AuthRepository(webService: webService);
  final DashboardRepository dashboardRepository = DashboardRepository(webService: webService);
  final StudentDashboardRepository studentDashboardRepository = StudentDashboardRepository(webService: webService);
  final ClassRepository classRepository = ClassRepository(webService: webService);
  final StudentsRepository studentsRepository = StudentsRepository(webService: webService);
  final CompleteMarksRepository completeMarksRepository = CompleteMarksRepository(webService: webService);
  final StudentRepository studentRepository = StudentRepository(webService: webService);
  final StaffRepository staffRepository = StaffRepository(webService: webService);
  final SubjectRepository subjectRepository = SubjectRepository(webService: webService);
  final HolidayRepository holidayRepository = HolidayRepository(webService: webService);
  final PostRepository postRepository = PostRepository(webService: webService);
  final FeedRepository feedRepository = FeedRepository(webService: webService);
  final ComplaintRepository complaintRepository = ComplaintRepository(webService: webService);
  final FeesRepository feesRepository = FeesRepository(/*webService: webService*/);
  final LibraryRepository libraryRepository = LibraryRepository(webService: webService);
  final ExamRepository examRepository = ExamRepository(webService: webService);
  final ConfigurationRepository configurationRepository = ConfigurationRepository(webService: webService);
  final ProfileRepository profileRepository = ProfileRepository(webService: webService);
  final PermissionRepository permissionRepository = PermissionRepository(webService: webService);
  final RulesRepository rulesRepository = RulesRepository(webService: webService);
  final StudentAdminRepository studentAdminRepository = StudentAdminRepository(webService: webService);
  final ClassDetailsRepository classDetailsRepository = ClassDetailsRepository(webService: webService);
  final AttendanceRepository attendanceRepository = AttendanceRepository(webService: webService);
  final FeesStructureRepository feesStructureRepository = FeesStructureRepository(webService: webService);

  final app = MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(authRepository: authRepository)
          ..add(AppStarted()), // 🔥 Trigger session check on app start
      ),
      RepositoryProvider<ClassDetailsRepository>(
        create: (context) => classDetailsRepository,
      ),
      BlocProvider<DashboardBloc>(
        create: (context) => DashboardBloc(repository: dashboardRepository),
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
      BlocProvider<ThemeBloc>(
        create: (context) => ThemeBloc(),
      ),
      BlocProvider<LanguageBloc>(
        create: (context) => LanguageBloc(),
      ),
      BlocProvider(
        create: (context) => ComplaintBloc(complaintRepository),
      ),
      BlocProvider(
        create: (context) => FeesBloc(feesRepository),
      ),
      BlocProvider(
        create: (context) => LibraryBloc(libraryRepository: libraryRepository),
      ),
      BlocProvider(
        create: (context) => StudentBloc(studentRepository: studentRepository),
      ),
      BlocProvider(
        create: (context) => StaffRegistrationBloc(repository: staffRepository),
      ),
      BlocProvider(
        create: (context) => SubjectBloc(subjectRepository: subjectRepository),
      ),
      BlocProvider(
        create: (context) => ExamBloc(examRepository: examRepository),
      ),
      BlocProvider(
        create: (context) => ConfigurationBloc(configurationRepository),
      ),
      BlocProvider(
        create: (context) => PermissionBloc(repo: permissionRepository),
      ),
      BlocProvider(
        create: (context) => RulesBloc(repository: rulesRepository),
      ),
      BlocProvider(
        create: (context) => UserBloc(userRepository: studentAdminRepository),
      ),
      BlocProvider(
        create: (context) => StudentsBloc(repository: studentsRepository),
      ),
      BlocProvider(
        create: (context) => AttendanceBloc(repository: attendanceRepository),
      ),
      BlocProvider(
        create: (context) => ProfileBloc(profileRepository),
      ),
      BlocProvider(
        create: (context) => StudentDashboardBloc(repository: studentDashboardRepository),
      ),
      BlocProvider<FeesStructureBloc>(
        create: (context) => FeesStructureBloc(feesStructureRepository: feesStructureRepository),
      ),
      BlocProvider<ClassDetailsBloc>(
        create: (context) => ClassDetailsBloc(
            classDetailsRepository: context.read<ClassDetailsRepository>()),
      ),
      RepositoryProvider(
        create: (context) => studentsRepository,
      ),
      RepositoryProvider(
        create: (context) => completeMarksRepository,
      ),
    ],
    child: MyApp(),
  );
  DebugLogger.initWithZone(app);
}

// Load environment settings from SharedPreferences
Future<void> _loadEnvironmentSettings() async {
  final prefs = await SharedPreferences.getInstance();

  // Load environment settings
  final isMockEnvironment = prefs.getBool('isMockEnvironment') ?? false;
  final isCustomEnvironment = prefs.getBool('isCustomEnvironment') ?? false;
  final customBaseUrl = prefs.getString('customBaseUrl') ?? '';

  // Set base URL based on environment
  Constants.baseUrl = isCustomEnvironment
      ? customBaseUrl
      : (isMockEnvironment ? Constants.mockBaseUrl : Constants.prodBaseUrl);

  // Load saved tenant ID if available
  final savedTenantId = prefs.getString('selectedClientId');
  if (savedTenantId != null) {
    Constants.tenantId = savedTenantId;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            return MaterialApp(
              title: 'SchoolMate',
              theme: themeState.themeData, // ✅ Dynamic Theme
              locale: langState.locale, // ✅ Dynamic Language
              supportedLocales: const [
                Locale('en'), // English
                Locale('ta'), // Tamil
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate, // ✅ Translations
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const AppInitializer(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

// App Initializer to handle navigation flow
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    // Small delay to ensure context is ready
    await Future.delayed(const Duration(milliseconds: 100));

    final prefs = await SharedPreferences.getInstance();
    final selectedClientId = prefs.getString('selectedClientId');
    final skipClientSelection = prefs.getBool('skipClientSelection') ?? false;

    if (mounted) {
      // Check if running on web
      if (kIsWeb) {
        // Web platform - get tenant info from API
        await _getTenantInfoFromWeb();
      } else {
        // Mobile platform - use existing logic
        if (selectedClientId != null && skipClientSelection) {
          // Set tenant ID from saved preference
          Constants.tenantId = selectedClientId;

          // Navigate directly to login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          // Navigate to client selection
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientSelectionScreen()),
          );
        }
      }
    }
  }

  Future<String?> _fetchTenantInfoFromAPI(WebService webService) async {
    try {
      // Option 1: Extract tenant from URL first (if your web app uses subdomain or path)
      final currentUrl = Uri.base.toString();
      final tenantFromUrl = _extractTenantFromUrl(currentUrl);

      if (tenantFromUrl != null) {
        // Validate that this tenant exists in the API
        final isValidTenant = await _validateTenantExists(webService, tenantFromUrl);
        if (isValidTenant) {
          return tenantFromUrl;
        }
      }

      // Option 2: If no tenant from URL or invalid, show tenant selection dialog
      final response = await webService.fetchData('tenants');
      final Map<String, dynamic> tenantData = json.decode(response);

      if (tenantData['success'] != true) {
        throw Exception(tenantData['message'] ?? 'Failed to fetch tenants');
      }

      final List<dynamic> tenants = tenantData['data'];

      if (tenants.isEmpty) {
        throw Exception('No tenants available');
      }

      // 🔥 CHANGED: Always show dialog instead of using first tenant
      if (mounted) {
        final selectedTenantId = await _showTenantSelectionDialogWithRemember(
            tenants.cast<Map<String, dynamic>>()
        );
        return selectedTenantId;
      }

      return null;

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tenant info: $e');
      }
      rethrow;
    }
  }

// Updated _getTenantInfoFromWeb to handle the dialog flow
  Future<void> _getTenantInfoFromWeb() async {
    try {
      final webService = WebService(baseUrl: Constants.baseUrl);

      // Get tenant info from URL or show selection dialog
      final tenantInfo = await _fetchTenantInfoFromAPI(webService);

      if (tenantInfo != null && tenantInfo.isNotEmpty) {
        await _setTenantAndNavigate(tenantInfo);
      } else {
        // User cancelled the dialog or no tenant selected
        if (mounted) {
          _showTenantError('No tenant selected');
        }
      }
    } catch (e) {
      if (mounted) {
        _showTenantError(e.toString());
      }
    }
  }

// Enhanced tenant selection dialog with better UX
  Future<String?> _showTenantSelectionDialog(List<Map<String, dynamic>> tenants) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Select School'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Fixed height to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please select your school to continue:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tenants.length,
                    itemBuilder: (context, index) {
                      final tenant = tenants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              tenant['name'][0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            tenant['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            tenant['schemaName'] ?? 'No description',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            Navigator.of(context).pop(tenant['id']);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return null
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

// Optional: Add a method to handle "Remember my choice" functionality
  Future<String?> _showTenantSelectionDialogWithRemember(List<Map<String, dynamic>> tenants) async {
    bool rememberChoice = false;
    String? selectedTenantId;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.school, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Select School'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Please select your school to continue:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tenants.length,
                        itemBuilder: (context, index) {
                          final tenant = tenants[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(
                                  tenant['name'][0].toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                tenant['name'],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                tenant['schemaName'] ?? 'No description',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              onTap: () {
                                selectedTenantId = tenant['id'];
                                Navigator.of(context).pop({
                                  'tenantId': tenant['id'],
                                  'rememberChoice': rememberChoice,
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberChoice,
                          onChanged: (value) {
                            setState(() {
                              rememberChoice = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Remember my choice',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      // Save preference if user chose to remember
      if (result['rememberChoice'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('skipClientSelection', true);
      }
      return result['tenantId'];
    }

    return null;
  }

  // Helper method to validate tenant exists
  Future<bool> _validateTenantExists(WebService webService, String tenantId) async {
    try {
      final response = await webService.fetchData('tenants');
      final Map<String, dynamic> tenantData = json.decode(response);

      if (tenantData['success'] != true) {
        return false;
      }

      final List<dynamic> tenants = tenantData['data'];
      return tenants.any((tenant) => tenant['id'] == tenantId);
    } catch (e) {
      return false;
    }
  }

  // Updated _extractTenantFromUrl to handle different URL patterns
  String? _extractTenantFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Option 1: Extract from subdomain (e.g., school1.yourapp.com)
      final host = uri.host;
      if (host.contains('.')) {
        final parts = host.split('.');
        if (parts.length > 2) {
          return parts[0]; // Returns 'school1' from 'school1.yourapp.com'
        }
      }

      // Option 2: Extract from path (e.g., yourapp.com/tenant/school1)
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 && pathSegments[0] == 'tenant') {
        return pathSegments[1];
      }

      // Option 3: Extract from query parameter (e.g., yourapp.com?tenant=school1)
      final tenantParam = uri.queryParameters['tenant'];
      if (tenantParam != null && tenantParam.isNotEmpty) {
        return tenantParam;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting tenant from URL: $e');
      }
      return null;
    }
  }

  // Helper method to show tenant selection for web
  Future<void> _showTenantSelectionForWeb(WebService webService) async {
    try {
      final response = await webService.fetchData('tenants');
      final Map<String, dynamic> tenantData = json.decode(response);

      if (tenantData['success'] != true) {
        throw Exception(tenantData['message'] ?? 'Failed to fetch tenants');
      }

      final List<dynamic> tenants = tenantData['data'];

      if (tenants.isEmpty) {
        throw Exception('No tenants available');
      }

      if (mounted) {
        final selectedTenantId = await _showTenantSelectionDialog(
            tenants.cast<Map<String, dynamic>>()
        );

        if (selectedTenantId != null) {
          await _setTenantAndNavigate(selectedTenantId);
        }
      }
    } catch (e) {
      if (mounted) {
        _showTenantError(e.toString());
      }
    }
  }

  // Helper method to set tenant and navigate
  Future<void> _setTenantAndNavigate(String tenantId) async {
    // Set tenant ID
    Constants.tenantId = tenantId;

    // Save tenant ID to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedClientId', tenantId);

    if (mounted) {
      // Navigate directly to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showTenantNotFoundError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tenant Not Found'),
        content: const Text('Unable to identify the tenant. Please contact support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTenantError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Error loading tenant information: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkInitialRoute(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'SchoolMate',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb ? 'Loading tenant information...' : 'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}