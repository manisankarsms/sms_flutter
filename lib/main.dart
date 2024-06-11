import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/repositories/auth_repository.dart';
import 'package:sms/repositories/mock_repository.dart';
import 'package:sms/screens/home_screen_student.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/screens/profile_screen.dart';
import 'package:sms/services/web_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WebService webService = WebService(baseUrl: 'http://127.0.0.1:8080/'); // Create an instance of WebService

    final AuthRepository authRepository = AuthRepository(webService: webService); // Create an instance of AuthRepository
    // final MockAuthRepository authRepository = MockAuthRepository(); // Create an instance of AuthRepository

    return BlocProvider(
      create: (context) => AuthBloc(authRepository: authRepository), // Provide authRepository here
      child: MaterialApp(
        title: 'Your App',
        home: ProfileScreen(),
        // home: LoginScreen(),
      ),
    );
  }
}