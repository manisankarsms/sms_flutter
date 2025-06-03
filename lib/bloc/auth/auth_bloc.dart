// auth_bloc.dart

import 'package:bloc/bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LogoutRequested>(_onLogoutRequested);
    on<UserSelected>(_onUserSelected);
    on<GetOtpRequested>(_onGetOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
  }

  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final users = await authRepository.signInWithMobileAndPassword(
        event.email,
        event.password,
        event.userType
      );

      if (users.isNotEmpty) {
        if (users.length == 1) {
          emit(AuthAuthenticated(users, users[0])); // Pass full list + selected user
        } else {
          emit(AuthMultipleUsers(users)); // Let user pick one
        }
      } else {
        emit(AuthFailure(error: "No users found."));
      }
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  void _onUserSelected(UserSelected event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.users, event.selectedUser)); // Keep full user list
  }


  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout(); // Ensure logout clears session/token
    emit(AuthUnauthenticated()); // Emit unauthenticated state
  }

  void _onGetOtpRequested(GetOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.getOtp(event.email);
      emit(OtpSent());
    } catch (error) {
      emit(OtpFailure(error.toString()));
    }
  }

  void _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final users = await authRepository.sendOtp(event.email, event.otp);
      if (users.isNotEmpty) {
        if (users.length == 1) {
          emit(OtpVerified(users, users[0]));
        } else {
          emit(AuthMultipleUsers(users));
        }
      } else {
        emit(OtpFailure("No users found."));
      }
    } catch (error) {
      emit(OtpFailure(error.toString()));
    }
  }
}
