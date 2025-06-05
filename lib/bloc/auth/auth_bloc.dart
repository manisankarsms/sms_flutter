import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  Timer? _sessionTimer;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<GetOtpRequested>(_onGetOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<UserSelected>(_onUserSelected);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionCheckRequested>(_onSessionCheckRequested);
    on<ExtendSessionRequested>(_onExtendSessionRequested);
    on<SetSessionDurationRequested>(_onSetSessionDurationRequested);
    on<ToggleAutoLogin>(_onToggleAutoLogin);

    // Start session monitoring
    _startSessionMonitoring();
  }

  void _startSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      add(SessionCheckRequested());
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      final sessionData = await authRepository.getStoredSession();

      if (sessionData != null) {
        final remainingHours = await authRepository.getRemainingSessionHours();

        if (sessionData.activeUser != null) {
          emit(AuthAuthenticated(
            users: sessionData.users,
            activeUser: sessionData.activeUser!,
            remainingHours: remainingHours,
          ));
        } else {
          emit(AuthMultipleUsers(sessionData.users));
        }

        if (kDebugMode) {
          print("Auto-login successful. Session expires in $remainingHours hours");
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (error) {
      emit(AuthUnauthenticated());
      if (kDebugMode) {
        print("Auto-login failed: $error");
      }
    }
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      // Set session duration based on remember me (7 days if true, 1 day if false)
      if (event.rememberMe) {
        await authRepository.setSessionDuration(7);
      } else {
        await authRepository.setSessionDuration(1);
      }

      await authRepository.setAutoLoginEnabled(event.rememberMe);

      final users = await authRepository.signInWithMobileAndPassword(
          event.email,
          event.password,
          event.userType
      );

      if (users.length == 1) {
        await authRepository.saveActiveUser(users.first);
        final remainingHours = await authRepository.getRemainingSessionHours();
        emit(AuthAuthenticated(
          users: users,
          activeUser: users.first,
          remainingHours: remainingHours,
        ));
      } else {
        emit(AuthMultipleUsers(users));
      }
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onGetOtpRequested(GetOtpRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await authRepository.getOtp(event.email);
      emit(OtpSent());
    } catch (error) {
      emit(OtpFailure(error.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      // Set session duration based on remember me
      if (event.rememberMe) {
        await authRepository.setSessionDuration(7);
      } else {
        await authRepository.setSessionDuration(1);
      }

      await authRepository.setAutoLoginEnabled(event.rememberMe);

      final users = await authRepository.sendOtp(event.email, event.otp);

      if (users.length == 1) {
        await authRepository.saveActiveUser(users.first);
        final remainingHours = await authRepository.getRemainingSessionHours();
        emit(AuthAuthenticated(
          users: users,
          activeUser: users.first,
          remainingHours: remainingHours,
        ));
      } else {
        emit(OtpVerified(users, null));
      }
    } catch (error) {
      emit(OtpFailure(error.toString()));
    }
  }

  Future<void> _onUserSelected(UserSelected event, Emitter<AuthState> emit) async {
    try {
      await authRepository.saveActiveUser(event.user);
      final remainingHours = await authRepository.getRemainingSessionHours();
      emit(AuthAuthenticated(
        users: event.allUsers,
        activeUser: event.user,
        remainingHours: remainingHours,
      ));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onSessionCheckRequested(SessionCheckRequested event, Emitter<AuthState> emit) async {
    try {
      if (!await authRepository.isSessionValid()) {
        emit(SessionExpired());
        emit(AuthUnauthenticated());
      } else if (state is AuthAuthenticated) {
        final currentState = state as AuthAuthenticated;
        final remainingHours = await authRepository.getRemainingSessionHours();

        // Emit updated state with new remaining time
        emit(AuthAuthenticated(
          users: currentState.users,
          activeUser: currentState.activeUser,
          remainingHours: remainingHours,
        ));

        // Warn user if session expires in less than 24 hours
        if (remainingHours <= 24 && remainingHours > 0) {
          if (kDebugMode) {
            print("Session warning: expires in $remainingHours hours");
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Session check error: $error");
      }
    }
  }

  Future<void> _onExtendSessionRequested(ExtendSessionRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.extendSession(additionalDays: event.additionalDays);
      final remainingHours = await authRepository.getRemainingSessionHours();
      emit(SessionExtended(remainingHours));

      // Update current state if authenticated
      if (state is AuthAuthenticated) {
        final currentState = state as AuthAuthenticated;
        emit(AuthAuthenticated(
          users: currentState.users,
          activeUser: currentState.activeUser,
          remainingHours: remainingHours,
        ));
      }
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onSetSessionDurationRequested(SetSessionDurationRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.setSessionDuration(event.days);
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onToggleAutoLogin(ToggleAutoLogin event, Emitter<AuthState> emit) async {
    try {
      await authRepository.setAutoLoginEnabled(event.enabled);
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }
}