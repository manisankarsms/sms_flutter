import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {}

class LoadClasses extends UserEvent {}

class AddUser extends UserEvent {
  final User user;
  const AddUser(this.user);
  @override
  List<Object?> get props => [user];
}

class UpdateUser extends UserEvent {
  final User user;
  const UpdateUser(this.user);
  @override
  List<Object?> get props => [user];
}

class DeleteUser extends UserEvent {
  final String userId;
  const DeleteUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AssignUserToClass extends UserEvent {
  final String userId;
  final String classId;

  AssignUserToClass(this.userId, this.classId);
}

class BulkUpdateUserRole extends UserEvent {
  final List<String> userIds;
  final String newRole;

  const BulkUpdateUserRole(this.userIds, this.newRole);

  @override
  List<Object> get props => [userIds, newRole];
}

class BulkUpdateUserPermissions extends UserEvent {
  final List<String> userIds;
  final List<String> permissions;
  final bool isAdd; // true for add, false for remove

  const BulkUpdateUserPermissions(this.userIds, this.permissions, this.isAdd);

  @override
  List<Object> get props => [userIds, permissions, isAdd];
}

class BulkDeleteUsers extends UserEvent {
  final List<String> userIds;

  const BulkDeleteUsers(this.userIds);

  @override
  List<Object> get props => [userIds];
}

class BulkAssignUsersToClass extends UserEvent {
  final List<String> userIds;
  final String classId;

  const BulkAssignUsersToClass(this.userIds, this.classId);

  @override
  List<Object> get props => [userIds, classId];
}