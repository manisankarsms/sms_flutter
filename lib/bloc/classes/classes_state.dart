import '../../models/class.dart';

enum ClassesStatus { initial, loading, success, failure }

class ClassesState {
  final ClassesStatus status;
  final List<Class> classes;
  final List<Class> filteredClasses;
  final String searchQuery;

  const ClassesState({
    this.status = ClassesStatus.initial,
    this.classes = const [],
    this.filteredClasses = const [],
    this.searchQuery = '',
  });

  ClassesState copyWith({
    ClassesStatus? status,
    List<Class>? classes,
    List<Class>? filteredClasses,
    String? searchQuery,
  }) {
    return ClassesState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      filteredClasses: filteredClasses ?? this.filteredClasses,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}