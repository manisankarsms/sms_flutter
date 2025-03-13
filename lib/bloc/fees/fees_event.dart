part of 'fees_bloc.dart';

abstract class FeesEvent {}

class LoadFees extends FeesEvent {}

class AddClassFees extends FeesEvent {
  final String academicYear;
  final String className;
  final ClassFees classFees;
  AddClassFees(this.academicYear, this.className, this.classFees);
}

class UpdateClassFees extends FeesEvent {
  final String academicYear;
  final String className;
  final ClassFees updatedClassFees;
  UpdateClassFees(this.academicYear, this.className, this.updatedClassFees);
}

class DeleteClassFees extends FeesEvent {
  final String academicYear;
  final String className;
  DeleteClassFees(this.academicYear, this.className);
}

class CopyFeesToNextYear extends FeesEvent {
  final String currentYear;
  final String nextYear;
  CopyFeesToNextYear(this.currentYear, this.nextYear);
}

