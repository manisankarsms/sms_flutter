part of 'fees_bloc.dart';

abstract class FeesState {}

class FeesInitial extends FeesState {}

class FeesLoading extends FeesState {}

class FeesLoaded extends FeesState {
  final Map<String, AcademicYearFees> academicYearFees;
  FeesLoaded(this.academicYearFees);
}

class FeesError extends FeesState {
  final String message;
  FeesError(this.message);
}
