import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../repositories/staff_repository.dart';
import 'new_staff_event.dart';
import 'new_staff_state.dart';

class StaffRegistrationBloc extends Bloc<StaffRegistrationEvent, StaffRegistrationState> {
  final StaffRepository repository;

  StaffRegistrationBloc({required this.repository}) : super(StaffRegistrationInitialState()) {
    on<SaveStaffEvent>(_onSaveStaff);
    on<BulkSaveStaffEvent>(_onBulkSaveStaff);
  }

  Future<void> _onSaveStaff(SaveStaffEvent event, Emitter<StaffRegistrationState> emit) async {
    try {
      emit(StaffRegistrationLoadingState());

      if (kDebugMode) {
        print('StaffRegistrationBloc: Submitting staff registration...');
      }

      // Call repository method which now returns Map<String, dynamic>
      final result = await repository.submitStaffRegistration(event.formData);

      if (kDebugMode) {
        print('StaffRegistrationBloc: Repository result: $result');
      }

      if (result['success'] == true) {
        emit(StaffRegistrationSuccessState(
          message: result['message'] ?? 'Staff registered successfully!',
          data: result['data'],
        ));
      } else {
        emit(StaffRegistrationErrorState(
          errorMessage: result['message'] ?? 'Registration failed. Please try again.',
          error: result['error'],
        ));
      }

    } catch (error) {
      if (kDebugMode) {
        print('StaffRegistrationBloc: Error occurred: $error');
      }

      // Handle specific error types
      String errorMessage = 'An unexpected error occurred. Please try again.';

      if (error.toString().contains('Email already exists')) {
        errorMessage = 'This email address is already registered. Please use a different email.';
      } else if (error.toString().contains('Mobile number already exists')) {
        errorMessage = 'This mobile number is already registered. Please use a different number.';
      } else if (error.toString().contains('Network error') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (error.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (error.toString().contains('FormatException')) {
        errorMessage = 'Invalid server response. Please try again.';
      }

      emit(StaffRegistrationErrorState(
        errorMessage: errorMessage,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onBulkSaveStaff(BulkSaveStaffEvent event, Emitter<StaffRegistrationState> emit) async {
    try {
      emit(StaffRegistrationLoadingState());

      if (kDebugMode) {
        print('StaffRegistrationBloc: Starting bulk staff upload for ${event.staffData.length} staff...');
      }

      int successCount = 0;
      int failedCount = 0;
      List<String> failedStaff = [];
      List<String> duplicateEmails = [];
      List<String> duplicateMobiles = [];

      for (int i = 0; i < event.staffData.length; i++) {
        try {
          // Emit progress state
          emit(BulkStaffProgressState(i + 1, event.staffData.length));

          final staffData = event.staffData[i];

          if (kDebugMode) {
            print('Processing staff ${i + 1}: ${staffData['firstName']} ${staffData['lastName']}');
          }

          // Call repository method
          final result = await repository.submitStaffRegistration(staffData);

          if (result['success'] == true) {
            successCount++;
            if (kDebugMode) {
              print('Successfully created staff: ${staffData['firstName']} ${staffData['lastName']}');
            }
          } else {
            failedCount++;
            final staffName = '${staffData['firstName']} ${staffData['lastName']}';
            failedStaff.add('$staffName: ${result['message'] ?? 'Unknown error'}');

            // Track specific error types
            if (result['message']?.contains('Email already exists') == true) {
              duplicateEmails.add(staffData['email']);
            } else if (result['message']?.contains('Mobile number already exists') == true) {
              duplicateMobiles.add(staffData['mobileNumber']);
            }

            if (kDebugMode) {
              print('Failed to create staff: $staffName - ${result['message']}');
            }
          }

        } catch (error) {
          failedCount++;
          final staffData = event.staffData[i];
          final staffName = '${staffData['firstName']} ${staffData['lastName']}';

          String errorMessage = 'Unknown error occurred';
          if (error.toString().contains('Email already exists')) {
            errorMessage = 'Email already exists';
            duplicateEmails.add(staffData['email']);
          } else if (error.toString().contains('Mobile number already exists')) {
            errorMessage = 'Mobile number already exists';
            duplicateMobiles.add(staffData['mobileNumber']);
          } else if (error.toString().contains('Network error') ||
              error.toString().contains('SocketException')) {
            errorMessage = 'Network error';
          } else if (error.toString().contains('TimeoutException')) {
            errorMessage = 'Request timeout';
          }

          failedStaff.add('$staffName: $errorMessage');

          if (kDebugMode) {
            print('Exception while creating staff: $staffName - $error');
          }
        }

        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (kDebugMode) {
        print('Bulk upload completed: $successCount success, $failedCount failed');
      }

      // Emit final result
      emit(BulkStaffSuccessState(
        successCount: successCount,
        failedCount: failedCount,
        failedStaff: failedStaff,
        duplicateEmails: duplicateEmails,
        duplicateMobiles: duplicateMobiles,
      ));

    } catch (error) {
      if (kDebugMode) {
        print('StaffRegistrationBloc: Bulk upload error: $error');
      }

      emit(StaffRegistrationErrorState(
        errorMessage: 'Bulk upload failed: ${error.toString()}',
        error: error.toString(),
      ));
    }
  }
}