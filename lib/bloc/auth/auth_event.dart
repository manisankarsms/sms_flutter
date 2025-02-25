// auth_event.dart

import 'package:flutter/cupertino.dart';

@immutable
abstract class AuthEvent {}

class LoginButtonPressed extends AuthEvent {
  final String email;
  final String password;
  final String userType;

  LoginButtonPressed({required this.email, required this.password, required this.userType});
}

class LogoutRequested extends AuthEvent {} // New Logout Event
