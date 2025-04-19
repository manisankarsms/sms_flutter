import '../../models/permissions.dart';

abstract class PermissionState {}
class PermissionLoading extends PermissionState {}
class PermissionLoaded extends PermissionState {
  final List<PermissionDefinition> definitions;
  final List<Staff> staffList;

  PermissionLoaded({required this.definitions, required this.staffList});
}
class PermissionError extends PermissionState {
  final String message;
  PermissionError(this.message);
}
