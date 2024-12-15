import 'package:equatable/equatable.dart';

abstract class StudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentSaving extends StudentState {}

class StudentSaved extends StudentState {}

class StudentError extends StudentState {
  final String message;

  StudentError(this.message);

  @override
  List<Object?> get props => [message];
}
