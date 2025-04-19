import 'package:bloc/bloc.dart';
import 'package:sms/bloc/permissions/permissions_event.dart';
import 'package:sms/bloc/permissions/permissions_state.dart';

import '../../models/permissions.dart';
import '../../repositories/permission_repository.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final PermissionRepository repo;
  late List<PermissionDefinition> _defs;
  late List<Staff> _staffCache;

  PermissionBloc({required this.repo}) : super(PermissionLoading()) {
    on<LoadPermissions>(_onLoad);
    on<TogglePermission>(_onToggle);
    on<SavePermissions>(_onSave);
  }

  Future<void> _onLoad(LoadPermissions event, Emitter<PermissionState> emit) async {
    emit(PermissionLoading());
    try {
      _defs = await repo.fetchDefinitions();
      _staffCache = await repo.fetchAllStaff();
      emit(PermissionLoaded(definitions: _defs, staffList: List.from(_staffCache)));
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  void _onToggle(TogglePermission event, Emitter<PermissionState> emit) {
    final idx = _staffCache.indexWhere((s) => s.id == event.staffId);
    if (idx != -1) {
      final staff = _staffCache[idx];
      final perms = List<String>.from(staff.permissions);
      if (perms.contains(event.permissionKey)) perms.remove(event.permissionKey);
      else perms.add(event.permissionKey);
      _staffCache[idx].permissions = perms;
      emit(PermissionLoaded(definitions: _defs, staffList: List.from(_staffCache)));
    }
  }

  Future<void> _onSave(SavePermissions event, Emitter<PermissionState> emit) async {
    emit(PermissionLoading());
    try {
      for (var staff in _staffCache) {
        await repo.updatePermissions(staff.id, staff.permissions);
      }
      emit(PermissionLoaded(definitions: _defs, staffList: List.from(_staffCache)));
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }
}