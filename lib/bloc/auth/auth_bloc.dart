// auth_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:sms/repositories/mock_repository.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockAuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.signInWithMobileAndPassword(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user)); // Pass user information
      }
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }
}
