import 'dart:ui';

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
import 'package:sms/bloc/students/students_bloc.dart';
import 'package:sms/bloc/subjects/subjects_bloc.dart';
import 'package:sms/repositories/attendance_repository.dart';
import 'package:sms/repositories/auth_repository.dart';
import 'package:sms/repositories/class_details_repository.dart';
import 'package:sms/repositories/class_repository.dart';
import 'package:sms/repositories/complaint_repository.dart';
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
import 'package:sms/repositories/student_repository.dart';
import 'package:sms/repositories/students_repository.dart';
import 'package:sms/repositories/subjects_repository.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'bloc/auth/auth_event.dart';
import 'bloc/complaint/complaint_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/language/language_state.dart';
import 'bloc/staffs/staff_bloc.dart';
import 'bloc/theme/theme_bloc.dart';
import 'dev_only/debug_logger.dart';

void main() async{
  final WebService webService = WebService(baseUrl: Constants.baseUrl);
  final AuthRepository authRepository = AuthRepository(webService: webService);
  final DashboardRepository dashboardRepository = DashboardRepository(webService: webService);
  final ClassRepository classRepository = ClassRepository(webService: webService);
  final StudentsRepository studentsRepository = StudentsRepository(webService: webService);
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

  final app =
    MultiBlocProvider(
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
        BlocProvider<ClassDetailsBloc>(
          create: (context) => ClassDetailsBloc(
              classDetailsRepository: context.read<ClassDetailsRepository>()
          ),
        ),
        RepositoryProvider(
          create: (context) => studentsRepository,
        ),
      ],
      child: MyApp(),
  );
  DebugLogger.initWithZone(app);
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
              home: const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
