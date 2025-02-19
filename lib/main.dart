import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/bloc/attendance/attendance_bloc.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/classes/classes_bloc.dart';
import 'package:sms/repositories/auth_repository.dart';
import 'package:sms/repositories/class_repository.dart';
import 'package:sms/repositories/dashboard_repository.dart';
import 'package:sms/repositories/mock_repository.dart';
import 'package:sms/screens/attendance_screen.dart';
import 'package:sms/screens/home_screen_student.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/screens/profile_screen.dart';
import 'package:sms/services/web_service.dart';

import 'bloc/dashboard/dashboard_bloc.dart';

void main() {
  // final WebService webService = WebService(baseUrl: 'https://0ceba48b-6fa5-45d1-9520-4d0792c8d123.mock.pstmn.io');
  final WebService webService = WebService(baseUrl: 'https://api.mockfly.dev/mocks/8bc986d0-f33b-4f0d-80cf-a9655739a6c4');
  final AuthRepository authRepository = AuthRepository(webService: webService);
  final DashboardRepository dashboardRepository = DashboardRepository(webService: webService);
  final ClassRepository classRepository = ClassRepository(webService: webService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(repository: dashboardRepository), // Provide DashboardBloc
        ),
        BlocProvider<ClassesBloc>(
          create: (context) => ClassesBloc(repository: classRepository), // Provide DashboardBloc
        ),
      ],
      child: MaterialApp(
        title: 'Your App',
        home: LoginScreen(),
      ),
    ),
  );
}
