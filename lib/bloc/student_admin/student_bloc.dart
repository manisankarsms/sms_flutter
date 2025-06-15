// student_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sms/bloc/student_admin/student_event.dart';
import 'package:sms/bloc/student_admin/student_state.dart';
import 'package:sms/repositories/student_admin_repository.dart';
import '../../models/user.dart';
import '../../models/class.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final StudentAdminRepository userRepository;
  List<User> _users = [];
  List<Class> _classes = [];

  UserBloc({required this.userRepository}) : super(UserLoading()) {
    if (kDebugMode) {
      print("[UserBloc] Initialized.");
    }
    on<LoadUsers>(_onLoadUsers);
    on<LoadClasses>(_onLoadClasses);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<AssignUserToClass>(_onAssignUserToClass);

    // Bulk operation handlers
    on<BulkUpdateUserRole>(_onBulkUpdateUserRole);
    on<BulkUpdateUserPermissions>(_onBulkUpdateUserPermissions);
    on<BulkDeleteUsers>(_onBulkDeleteUsers);
    on<BulkAssignUsersToClass>(_onBulkAssignUsersToClass);

    // Load both users and classes on initialization
    add(LoadUsers());
    add(LoadClasses());
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    try {
      if (kDebugMode) {
        print("[UserBloc] Processing LoadUsers event");
      }

      // Don't emit loading if we're just refreshing users
      if (_users.isEmpty && _classes.isEmpty) {
        emit(UserLoading());
      }

      _users = await userRepository.fetchUsers();

      if (kDebugMode) {
        print("[UserBloc] Emitting UsersAndClassesLoaded with ${_users.length} users and ${_classes.length} classes");
      }
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[UserBloc] Error loading users: $e");
        print("[UserBloc] Stacktrace: $stacktrace");
      }
      emit(UserOperationFailure('Failed to load users: ${e.toString()}', _users, classes: _classes));
    }
  }

  Future<void> _onLoadClasses(LoadClasses event, Emitter<UserState> emit) async {
    try {
      if (kDebugMode) {
        print("[UserBloc] Processing LoadClasses event");
      }

      _classes = await userRepository.fetchClasses();

      if (kDebugMode) {
        print("[UserBloc] Loaded ${_classes.length} classes");
      }

      // Emit the combined state with both users and classes
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[UserBloc] Error loading classes: $e");
        print("[UserBloc] Stacktrace: $stacktrace");
      }
      emit(UserOperationFailure('Failed to load classes: ${e.toString()}', _users, classes: _classes));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
    try {
      emit(UserOperationInProgress(_users, "Adding user...", classes: _classes));

      await userRepository.addUser(event.user);
      emit(UserOperationSuccess(_users, "User added successfully!", classes: _classes));

      // Reload users after adding
      add(LoadUsers());
    } catch (e) {
      emit(UserOperationFailure('Failed to add user: ${e.toString()}', _users, classes: _classes));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    try {
      emit(UserOperationInProgress(_users, "Updating user...", classes: _classes));

      await userRepository.updateUser(event.user);
      final index = _users.indexWhere((p) => p.id == event.user.id);
      if (index != -1) {
        _users[index] = event.user;
      }

      emit(UserOperationSuccess(_users, "User updated successfully!", classes: _classes));
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure('Failed to update user: ${e.toString()}', _users, classes: _classes));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    try {
      emit(UserOperationInProgress(_users, "Deleting user...", classes: _classes));

      await userRepository.deleteUser(event.userId);
      _users.removeWhere((p) => p.id == event.userId);

      emit(UserOperationSuccess(_users, "User deleted successfully!", classes: _classes));
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure('Failed to delete user: ${e.toString()}', _users, classes: _classes));
    }
  }

  Future<void> _onAssignUserToClass(AssignUserToClass event, Emitter<UserState> emit) async {
    try {
      emit(UserOperationInProgress(_users, "Assigning user to class...", classes: _classes));

      // Note: You'll need to implement this method in your repository
      await userRepository.assignStudentToClass(event.classId, event.userId);

      emit(UserOperationSuccess(_users, "User assigned to class successfully!", classes: _classes));
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure('Failed to assign user to class: ${e.toString()}', _users, classes: _classes));
    }
  }

  // BULK OPERATIONS - Fixed versions
  Future<void> _onBulkUpdateUserRole(
      BulkUpdateUserRole event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserOperationInProgress(_users, "Updating user roles...", classes: _classes));

      // Update local users list
      _users = _users.map((user) {
        if (event.userIds.contains(user.id)) {
          return user.copyWith(
            role: event.newRole,
            updatedAt: DateTime.now(),
          );
        }
        return user;
      }).toList();

      // Here you would typically call your repository to update users in the database
      // await userRepository.bulkUpdateUserRole(event.userIds, event.newRole);

      emit(UserOperationSuccess(
        _users,
        'Role updated for ${event.userIds.length} users',
        classes: _classes,
      ));

      // Emit the updated state
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure(
        'Failed to update user roles: ${e.toString()}',
        _users,
        classes: _classes,
      ));
    }
  }

  Future<void> _onBulkUpdateUserPermissions(
      BulkUpdateUserPermissions event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserOperationInProgress(_users, "Updating user permissions...", classes: _classes));

      // Update local users list
      _users = _users.map((user) {
        if (event.userIds.contains(user.id)) {
          List<String> newPermissions = List.from(user.permissions);

          if (event.isAdd) {
            // Add permissions
            for (String permission in event.permissions) {
              if (!newPermissions.contains(permission)) {
                newPermissions.add(permission);
              }
            }
          } else {
            // Remove permissions
            newPermissions.removeWhere((permission) => event.permissions.contains(permission));
          }

          return user.copyWith(
            permissions: newPermissions,
            updatedAt: DateTime.now(),
          );
        }
        return user;
      }).toList();

      // Here you would typically call your repository to update users in the database
      // await userRepository.bulkUpdateUserPermissions(event.userIds, event.permissions, event.isAdd);

      emit(UserOperationSuccess(
        _users,
        'Permissions ${event.isAdd ? 'added to' : 'removed from'} ${event.userIds.length} users',
        classes: _classes,
      ));

      // Emit the updated state
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure(
        'Failed to update user permissions: ${e.toString()}',
        _users,
        classes: _classes,
      ));
    }
  }

  Future<void> _onBulkDeleteUsers(
      BulkDeleteUsers event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserOperationInProgress(_users, "Deleting users...", classes: _classes));

      // Remove users from local list
      _users = _users.where((user) => !event.userIds.contains(user.id)).toList();

      // Here you would typically call your repository to delete users from the database
      // await userRepository.bulkDeleteUsers(event.userIds);

      emit(UserOperationSuccess(
        _users,
        '${event.userIds.length} users deleted successfully',
        classes: _classes,
      ));

      // Emit the updated state
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure(
        'Failed to delete users: ${e.toString()}',
        _users,
        classes: _classes,
      ));
    }
  }

  Future<void> _onBulkAssignUsersToClass(
      BulkAssignUsersToClass event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserOperationInProgress(_users, "Assigning users to class...", classes: _classes));

      // Here you would typically call your repository to assign users to class
      // await userRepository.bulkAssignUsersToClass(event.userIds, event.classId);

      // Get class name for message
      String className = event.classId;
      try {
        final classItem = _classes.firstWhere(
              (c) => c.id == event.classId,
        );
        className = '${classItem.className} - ${classItem.sectionName ?? ''}';
      } catch (e) {
        // If class not found, use the classId
        className = event.classId;
      }

      emit(UserOperationSuccess(
        _users,
        '${event.userIds.length} users assigned to $className',
        classes: _classes,
      ));

      // Emit the updated state
      emit(UsersAndClassesLoaded(_users, _classes));
    } catch (e) {
      emit(UserOperationFailure(
        'Failed to assign users to class: ${e.toString()}',
        _users,
        classes: _classes,
      ));
    }
  }

  // Helper method to get classes
  List<Class> get classes => List.from(_classes);

  // Helper method to get users
  List<User> get users => List.from(_users);
}