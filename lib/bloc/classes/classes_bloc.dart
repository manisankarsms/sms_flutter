import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/class.dart';
import '../../models/user.dart';
import '../../repositories/class_repository.dart';
import 'classes_event.dart';
import 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final ClassRepository repository;
  final User user;

  ClassesBloc({required this.repository, required this.user})
      : super(const ClassesState()) {
    on<LoadClasses>(_onLoadClasses);
    on<AddClass>(_onAddClass);
    on<DeleteClass>(_onDeleteClass);
    on<UpdateClass>(_onUpdateClass);
    on<SearchClasses>(_onSearchClasses);
    on<FetchStaffAndSubjects>(_onFetchStaffAndSubjects);
    on<ClearMessages>(_onClearMessages);

    // Initial load of classes
    add(const LoadClasses());
  }

  Future<void> _onLoadClasses(LoadClasses event, Emitter<ClassesState> emit) async {
    emit(state.copyWith(status: ClassesStatus.loading));

    try {
      final classes = await repository.fetchAllClasses();
      print("Fetched classes: $classes"); // Debugging

      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: classes,
        filteredClasses: _filterClasses(classes, state.searchQuery),
        error: null,
        message: classes.isEmpty ? null : 'Classes loaded successfully',
      ));
    } catch (e) {
      print("Error fetching classes: $e"); // Debugging
      emit(state.copyWith(
        status: ClassesStatus.failure,
        error: 'Failed to load classes: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddClass(AddClass event, Emitter<ClassesState> emit) async {
    emit(state.copyWith(status: ClassesStatus.loading));

    try {
      await repository.addClass(event.newClass);

      final updatedClasses = List<Class>.from(state.classes)..add(event.newClass);

      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: updatedClasses,
        filteredClasses: _filterClasses(updatedClasses, state.searchQuery),
        message: 'Class "${event.newClass.className}" added successfully',
        error: null,
      ));
    } catch (e) {
      print("Error adding class: $e"); // Debugging
      emit(state.copyWith(
        status: ClassesStatus.failure,
        error: 'Failed to add class: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateClass(UpdateClass event, Emitter<ClassesState> emit) async {
    emit(state.copyWith(status: ClassesStatus.loading));

    try {
      await repository.updateClass(event.updatedClass);

      final updatedClasses = state.classes.map((cls) {
        return cls.id == event.updatedClass.id ? event.updatedClass : cls;
      }).toList();

      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: updatedClasses,
        filteredClasses: _filterClasses(updatedClasses, state.searchQuery),
        message: 'Class "${event.updatedClass.className}" updated successfully',
        error: null,
      ));
    } catch (e) {
      print("Error updating class: $e"); // Debugging
      emit(state.copyWith(
        status: ClassesStatus.failure,
        error: 'Failed to update class: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteClass(DeleteClass event, Emitter<ClassesState> emit) async {
    emit(state.copyWith(status: ClassesStatus.loading));

    try {
      // Find the class name before deletion for the success message
      final classToDelete = state.classes.firstWhere(
            (cls) => cls.id == event.classId,
        orElse: () => Class(className: 'Unknown', id: '', sectionName: '', academicYearId: '', academicYearName: ''),
      );

      await repository.deleteClass(event.classId);

      final updatedClasses = state.classes.where((c) => c.id != event.classId).toList();

      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: updatedClasses,
        filteredClasses: _filterClasses(updatedClasses, state.searchQuery),
        message: 'Class "${classToDelete.className}" deleted successfully',
        error: null,
      ));
    } catch (e) {
      print("Error deleting class: $e"); // Debugging
      emit(state.copyWith(
        status: ClassesStatus.failure,
        error: 'Failed to delete class: ${e.toString()}',
      ));
    }
  }

  void _onSearchClasses(SearchClasses event, Emitter<ClassesState> emit) {
    final filteredClasses = _filterClasses(state.classes, event.query);

    emit(state.copyWith(
      filteredClasses: filteredClasses,
      searchQuery: event.query,
      status: ClassesStatus.success, // Keep success status during search
    ));
  }

  void _onClearMessages(ClearMessages event, Emitter<ClassesState> emit) {
    emit(state.clearMessages());
  }

  List<Class> _filterClasses(List<Class> classes, String query) {
    if (query.isEmpty) return classes;

    return classes.where((cls) {
      final lowercaseQuery = query.toLowerCase();
      return cls.className.toLowerCase().contains(lowercaseQuery) ||
          cls.sectionName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _onFetchStaffAndSubjects(
      FetchStaffAndSubjects event,
      Emitter<ClassesState> emit,
      ) async {
    try {
      emit(StaffAndSubjectsLoading());

      // Fetch both staff and subjects in parallel
      final staffFuture = repository.fetchStaff();
      final subjectsFuture = repository.fetchSubjects();

      final staff = await staffFuture;
      final subjects = await subjectsFuture;

      emit(StaffAndSubjectsLoaded(staff: staff, subjects: subjects));
    } catch (e) {
      emit(ClassesError('Failed to load staff and subjects: ${e.toString()}'));
    }
  }
}