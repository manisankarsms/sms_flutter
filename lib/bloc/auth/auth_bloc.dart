// auth_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sms/repositories/mock_repository.dart';

import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // final AuthRepository authRepository;
  final MockAuthRepository authRepository; //Mock

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<AuthState> emit) async {
    // Handle LoginButtonPressed event here
    emit(AuthLoading()); // Emit loading state

    try {
      final user = await authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(AuthSuccess());
        emit(AuthAuthenticated()); // Emit AuthAuthenticated state on successful authentication
      } else {
        emit(AuthFailure(error: 'Invalid credentials'));
      }
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }
}