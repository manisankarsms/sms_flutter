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
          // Directly authenticate if only one user is available
          emit(AuthAuthenticated(users[0]));
        } else {
          // Emit state with multiple users to allow user selection
          emit(AuthMultipleUsers(users));
        }
      } else {
        emit(AuthFailure(error: "No users found."));
      }
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  void _onUserSelected(UserSelected event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.selectedUser));
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout(); // Ensure logout clears session/token
    emit(AuthUnauthenticated()); // Emit unauthenticated state
  }
}
