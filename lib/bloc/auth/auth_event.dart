// auth_event.dart

import 'package:flutter/cupertino.dart';

import '../../models/user.dart';

@immutable
abstract class AuthEvent {}

class LoginButtonPressed extends AuthEvent {
  final String email;
  final String password;
  final String userType;

  LoginButtonPressed({required this.email, required this.password, required this.userType});
}

class UserSelected extends AuthEvent {
  final User selectedUser;
  final List<User> users;  // Keep all users

  UserSelected(this.selectedUser, this.users);
}


class LogoutRequested extends AuthEvent {} // New Logout Event
