import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/feed/feed_bloc.dart';
import 'package:sms/bloc/holiday/holiday_bloc.dart';
import 'package:sms/bloc/post/post_bloc.dart';
import 'package:sms/repositories/auth_repository.dart';
import 'package:sms/repositories/class_repository.dart';
import 'package:sms/repositories/dashboard_repository.dart';
import 'package:sms/repositories/feed_repository.dart';
import 'package:sms/repositories/holiday_repository.dart';
import 'package:sms/repositories/post_repository.dart';
import 'package:sms/repositories/staff_repository.dart';
import 'package:sms/repositories/students_repository.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/staffs/staff_bloc.dart';

void main() {
  final WebService webService = WebService(baseUrl: Constants.baseUrl);
  final AuthRepository authRepository = AuthRepository(webService: webService);
  final DashboardRepository dashboardRepository = DashboardRepository(webService: webService);
  final ClassRepository classRepository = ClassRepository(webService: webService);
  final StudentsRepository studentsRepository = StudentsRepository(webService: webService);
  final StaffRepository staffRepository = StaffRepository(webService: webService);
  final HolidayRepository holidayRepository = HolidayRepository(webService: webService);
  final PostRepository postRepository = PostRepository(webService: webService);
  final FeedRepository feedRepository = FeedRepository(webService: webService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(repository: dashboardRepository), // Provide DashboardBloc
        ),
        BlocProvider<StaffsBloc>(
          create: (context) => StaffsBloc(repository: staffRepository), // Provide DashboardBloc
        ),
        BlocProvider<HolidayBloc>(
          create: (context) => HolidayBloc(repository: holidayRepository), // Provide DashboardBloc
        ),
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(postRepository: postRepository), // Provide DashboardBloc
        ),
        BlocProvider<FeedBloc>(
          create: (context) => FeedBloc(feedRepository: feedRepository), // Provide DashboardBloc
        ),
        RepositoryProvider(
          create: (context) => studentsRepository,
        ),
      ],
      child: const MaterialApp(
        title: 'Your App',
        home: LoginScreen(),
      ),
    ),
  );
}
