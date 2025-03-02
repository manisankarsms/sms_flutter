import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/staff.dart';
import '../../repositories/staff_repository.dart';
import 'staff_event.dart';
import 'staff_state.dart';

/// Bloc class for managing staff-related events and state.
class StaffsBloc extends Bloc<StaffsEvent, StaffsState> {
  final StaffRepository repository; // Repository to handle data operations

  /// Constructor initializes the bloc and registers event handlers.
  /// Automatically triggers `LoadStaff` event on initialization.
  StaffsBloc({required this.repository}) : super(StaffsState()) {
    on<LoadStaff>(_onLoadStaff);
    on<AddStaff>(_onAddStaff);
    on<DeleteStaff>(_onDeleteStaff);

    if (kDebugMode) {
      print('StaffsBloc initialized, dispatching LoadStaff');
    }
    add(LoadStaff()); // Automatically load staff when the bloc is created
  }

  /// Handles loading staff from the repository.
  /// Emits `loading` state first, then `success` or `failure` based on the result.
  Future<void> _onLoadStaff(LoadStaff event, Emitter<StaffsState> emit) async {
    if (kDebugMode) {
      print('LoadStaff event triggered');
    }
    emit(state.copyWith(status: StaffsStatus.loading)); // Show loading state

    try {
      final staff = await repository.fetchStaff(); // Fetch staff data
      if (kDebugMode) {
        print('Fetched staff from repository: ${staff.length} items');
      }

      emit(state.copyWith(status: StaffsStatus.success, staff: staff)); // Update state with fetched staff
    } catch (e) {
      if (kDebugMode) {
        print('Error loading staff: $e');
      }
      emit(state.copyWith(status: StaffsStatus.failure)); // Emit failure state on error
    }
  }

  /// Handles adding a new staff member.
  /// Updates the repository and then emits the updated staff list.
  Future<void> _onAddStaff(AddStaff event, Emitter<StaffsState> emit) async {
    if (kDebugMode) {
      print('Adding staff: ${event.staff.name}');
    }
    await repository.addStaff(event.staff); // Save new staff to repository

    final updatedStaff = List<Staff>.from(state.staff)..add(event.staff); // Update local list
    if (kDebugMode) {
      print('Updated staff list count: ${updatedStaff.length}');
    }

    emit(state.copyWith(staff: updatedStaff)); // Emit new state with updated staff list
  }

  /// Handles deleting a staff member.
  /// Updates the repository and emits a new state with the staff removed.
  Future<void> _onDeleteStaff(DeleteStaff event, Emitter<StaffsState> emit) async {
    if (kDebugMode) {
      print('Deleting staff with ID: ${event.staffId}');
    }
    await repository.deleteStaff(event.staffId); // Delete staff from repository

    final updatedStaff = state.staff.where((s) => s.id != event.staffId).toList(); // Remove from list
    if (kDebugMode) {
      print('Updated staff list count after deletion: ${updatedStaff.length}');
    }

    emit(state.copyWith(staff: updatedStaff)); // Emit new state with updated staff list
  }
}
