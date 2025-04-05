import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/class.dart';
import '../../models/user.dart';
import '../../repositories/class_repository.dart';
import 'classes_event.dart';
import 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final ClassRepository repository;
  final User user;

  ClassesBloc({required this.repository, required this.user}) : super(const ClassesState()) {
    on<LoadClasses>(_onLoadClasses);
    on<AddClass>(_onAddClass);
    on<DeleteClass>(_onDeleteClass);
    on<UpdateClass>(_onUpdateClass); // Added handler for UpdateClass event
    on<SearchClasses>(_onSearchClasses);
    on<FetchStaffAndSubjects>(_onFetchStaffAndSubjects);
    // Initial load of classes
    add(LoadClasses());
  }

  Future<void> _onLoadClasses(LoadClasses event, Emitter<ClassesState> emit) async {
    emit(state.copyWith(status: ClassesStatus.loading));

    try {
      final classes = await repository.fetchClasses(user.id);
      print("Fetched classes: $classes"); // Debugging
      emit(state.copyWith(
        status: ClassesStatus.success,
        classes: classes,
        filteredClasses: classes,
      ));
    } catch (e) {
      print("Error fetching classes: $e"); // Debugging
      emit(state.copyWith(status: ClassesStatus.failure));
    }
  }

  Future<void> _onAddClass(AddClass event, Emitter<ClassesState> emit) async {
    await repository.addClass(event.newClass);
    final updatedClasses = List<Class>.from(state.classes)..add(event.newClass);
    emit(state.copyWith(
      classes: updatedClasses,
      filteredClasses: _filterClasses(updatedClasses, state.searchQuery),
    ));
  }

  Future<void> _onUpdateClass(UpdateClass event, Emitter<ClassesState> emit) async {
    try {
      // Update class in repository
      await repository.updateClass(event.updatedClass);

      // Update in-memory state
      final updatedClasses = state.classes.map((cls) {
        return cls.id == event.updatedClass.id ? event.updatedClass : cls;
      }).toList();

      emit(state.copyWith(
        classes: updatedClasses,
        filteredClasses: _filterClasses(updatedClasses, state.searchQuery),
      ));
    } catch (e) {
      print("Error updating class: $e"); // Debugging
      // You could emit a failure state here if needed
    }
  }

  Future<void> _onDeleteClass(DeleteClass event, Emitter<ClassesState> emit) async {
    await repository.deleteClass(event.classId);
    final updatedClasses = state.classes.where((c) => c.id != event.classId).toList();
    emit(state.copyWith(
      classes: updatedClasses,
      filteredClasses: _filterClasses(updatedClasses, state.searchQuery),
    ));
  }

  void _onSearchClasses(SearchClasses event, Emitter<ClassesState> emit) {
    final filteredClasses = _filterClasses(state.classes, event.query);
    emit(state.copyWith(
      filteredClasses: filteredClasses,
      searchQuery: event.query,
    ));
  }

  List<Class> _filterClasses(List<Class> classes, String query) {
    if (query.isEmpty) return classes;

    return classes.where((cls) {
      final lowercaseQuery = query.toLowerCase();
      return cls.name.toLowerCase().contains(lowercaseQuery) ||
          (cls.staff?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<void> _onFetchStaffAndSubjects(
      FetchStaffAndSubjects event,
      Emitter<ClassesState> emit
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
      emit(ClassesError(e.toString()));
    }
  }
}