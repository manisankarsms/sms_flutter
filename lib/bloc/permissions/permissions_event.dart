abstract class PermissionEvent {}
class LoadPermissions extends PermissionEvent {}
class TogglePermission extends PermissionEvent {
  final String staffId;
  final String permissionKey;

  TogglePermission({required this.staffId, required this.permissionKey});
}
class SavePermissions extends PermissionEvent {}