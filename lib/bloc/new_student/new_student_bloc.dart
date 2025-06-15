import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../repositories/student_repository.dart';
import 'new_student_event.dart';
import 'new_student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository studentRepository;

  StudentBloc({required this.studentRepository}) : super(StudentInitialState()) {
    on<SaveStudentEvent>(_onSaveStudent);
    on<BulkSaveStudentsEvent>(_onBulkSaveStudents); // Add this line!
  }

  Future<void> _onSaveStudent(SaveStudentEvent event, Emitter<StudentState> emit) async {
    try {
      emit(StudentLoadingState());

      if (kDebugMode) {
        print('StudentBloc: Submitting student registration...');
      }

      // Call repository method which now returns Map<String, dynamic>
      final result = await studentRepository.submitStudentRegistration(event.formData);

      if (kDebugMode) {
        print('StudentBloc: Repository result: $result');
      }

      if (result['success'] == true) {
        emit(StudentSuccessState(
          message: result['message'] ?? 'Student registered successfully!',
          data: result['data'],
        ));
      } else {
        emit(StudentErrorState(
          message: result['message'] ?? 'Registration failed. Please try again.',
          error: result['error'],
        ));
      }

    } catch (error) {
      if (kDebugMode) {
        print('StudentBloc: Error occurred: $error');
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

      emit(StudentErrorState(
        message: errorMessage,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onBulkSaveStudents(BulkSaveStudentsEvent event, Emitter<StudentState> emit) async {
    try {
      emit(StudentLoadingState());

      if (kDebugMode) {
        print('StudentBloc: Starting bulk student upload for ${event.studentsData.length} students...');
      }

      int successCount = 0;
      int failedCount = 0;
      List<String> failedStudents = [];
      List<String> duplicateEmails = [];
      List<String> duplicateMobiles = [];

      for (int i = 0; i < event.studentsData.length; i++) {
        try {
          // Emit progress state
          emit(BulkStudentProgressState(i + 1, event.studentsData.length));

          final studentData = event.studentsData[i];

          if (kDebugMode) {
            print('Processing student ${i + 1}: ${studentData['firstName']} ${studentData['lastName']}');
          }

          // Call repository method
          final result = await studentRepository.submitStudentRegistration(studentData);

          if (result['success'] == true) {
            successCount++;
            if (kDebugMode) {
              print('Successfully created student: ${studentData['firstName']} ${studentData['lastName']}');
            }
          } else {
            failedCount++;
            final studentName = '${studentData['firstName']} ${studentData['lastName']}';
            failedStudents.add('$studentName: ${result['message'] ?? 'Unknown error'}');

            // Track specific error types
            if (result['message']?.contains('Email already exists') == true) {
              duplicateEmails.add(studentData['email']);
            } else if (result['message']?.contains('Mobile number already exists') == true) {
              duplicateMobiles.add(studentData['mobileNumber']);
            }

            if (kDebugMode) {
              print('Failed to create student: $studentName - ${result['message']}');
            }
          }

        } catch (error) {
          failedCount++;
          final studentData = event.studentsData[i];
          final studentName = '${studentData['firstName']} ${studentData['lastName']}';

          String errorMessage = 'Unknown error occurred';
          if (error.toString().contains('Email already exists')) {
            errorMessage = 'Email already exists';
            duplicateEmails.add(studentData['email']);
          } else if (error.toString().contains('Mobile number already exists')) {
            errorMessage = 'Mobile number already exists';
            duplicateMobiles.add(studentData['mobileNumber']);
          } else if (error.toString().contains('Network error') ||
              error.toString().contains('SocketException')) {
            errorMessage = 'Network error';
          } else if (error.toString().contains('TimeoutException')) {
            errorMessage = 'Request timeout';
          }

          failedStudents.add('$studentName: $errorMessage');

          if (kDebugMode) {
            print('Exception while creating student: $studentName - $error');
          }
        }

        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (kDebugMode) {
        print('Bulk upload completed: $successCount success, $failedCount failed');
      }

      // Emit final result
      emit(BulkStudentSuccessState(
        successCount: successCount,
        failedCount: failedCount,
        failedStudents: failedStudents,
        duplicateEmails: duplicateEmails,
        duplicateMobiles: duplicateMobiles,
      ));

    } catch (error) {
      if (kDebugMode) {
        print('StudentBloc: Bulk upload error: $error');
      }

      emit(StudentErrorState(
        message: 'Bulk upload failed: ${error.toString()}',
        error: error.toString(),
      ));
    }
  }
}