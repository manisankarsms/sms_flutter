import 'package:equatable/equatable.dart';

abstract class StaffRegistrationState extends Equatable {
  const StaffRegistrationState();

  @override
  List<Object?> get props => [];
}

class StaffRegistrationInitialState extends StaffRegistrationState {}

class StaffRegistrationLoadingState extends StaffRegistrationState {}

class StaffRegistrationSuccessState extends StaffRegistrationState {
  final String message;
  final dynamic data;

  const StaffRegistrationSuccessState({
    required this.message,
    this.data,
  });

  @override
  List<Object?> get props => [message, data];
}

class StaffRegistrationErrorState extends StaffRegistrationState {
  final String errorMessage;
  final String? error;

  const StaffRegistrationErrorState({
    required this.errorMessage,
    this.error,
  });

  @override
  List<Object?> get props => [errorMessage, error];
}

class BulkStaffProgressState extends StaffRegistrationState {
  final int processed;
  final int total;

  const BulkStaffProgressState(this.processed, this.total);

  @override
  List<Object> get props => [processed, total];
}

class BulkStaffSuccessState extends StaffRegistrationState {
  final int successCount;
  final int failedCount;
  final List<String> failedStaff;
  final List<String> duplicateEmails;
  final List<String> duplicateMobiles;

  const BulkStaffSuccessState({
    required this.successCount,
    required this.failedCount,
    required this.failedStaff,
    required this.duplicateEmails,
    required this.duplicateMobiles,
  });

  @override
  List<Object> get props => [
    successCount,
    failedCount,
    failedStaff,
    duplicateEmails,
    duplicateMobiles,
  ];
}