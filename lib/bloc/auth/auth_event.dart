import '../../models/user.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginButtonPressed extends AuthEvent {
  final String email;
  final String password;
  final String userType;
  final bool rememberMe; // New field

  LoginButtonPressed({
    required this.email,
    required this.password,
    required this.userType,
    this.rememberMe = true,
  });
}

class GetOtpRequested extends AuthEvent {
  final String email;
  GetOtpRequested(this.email);
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  final bool rememberMe; // New field

  VerifyOtpRequested(this.email, this.otp, {this.rememberMe = true});
}

class UserSelected extends AuthEvent {
  final User user;
  final List<User> allUsers;
  UserSelected(this.user, this.allUsers);
}

class LogoutRequested extends AuthEvent {}

class SessionCheckRequested extends AuthEvent {}

class ExtendSessionRequested extends AuthEvent {
  final int? additionalDays;
  ExtendSessionRequested({this.additionalDays});
}

class SetSessionDurationRequested extends AuthEvent {
  final int days;
  SetSessionDurationRequested(this.days);
}

class ToggleAutoLogin extends AuthEvent {
  final bool enabled;
  ToggleAutoLogin(this.enabled);
}