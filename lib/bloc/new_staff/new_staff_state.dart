import 'package:equatable/equatable.dart';

abstract class StaffRegistrationState extends Equatable {
  const StaffRegistrationState();

  @override
  List<Object> get props => [];
}

class StaffRegistrationInitialState extends StaffRegistrationState {}

class StaffRegistrationLoadingState extends StaffRegistrationState {}

class StaffRegistrationSuccessState extends StaffRegistrationState {
  final String registrationId;

  const StaffRegistrationSuccessState(this.registrationId);

  @override
  List<Object> get props => [registrationId];
}

class StaffRegistrationErrorState extends StaffRegistrationState {
  final String errorMessage;

  const StaffRegistrationErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}