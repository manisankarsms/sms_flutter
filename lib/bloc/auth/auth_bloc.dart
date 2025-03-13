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
  }

  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final users = await authRepository.signInWithMobileAndPassword(
        event.email,
        event.password,
      );

      if (users != null && users.isNotEmpty) {
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
}
