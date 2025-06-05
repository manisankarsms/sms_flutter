import '../../models/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final List<User> users;
  final User activeUser;
  final int remainingHours;

  AuthAuthenticated({
    required this.users,
    required this.activeUser,
    this.remainingHours = 0,
  });
}

class AuthMultipleUsers extends AuthState {
  final List<User> users;
  AuthMultipleUsers(this.users);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {
  final List<User> users;
  final User? selectedUser;
  OtpVerified(this.users, this.selectedUser);
}

class OtpFailure extends AuthState {
  final String error;
  OtpFailure(this.error);
}

class SessionExpired extends AuthState {}

class SessionExtended extends AuthState {
  final int newRemainingHours;
  SessionExtended(this.newRemainingHours);
}