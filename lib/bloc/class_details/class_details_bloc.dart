import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/subject.dart';
import 'class_details_event.dart';
import 'class_details_state.dart';
import '../../repositories/class_details_repository.dart';
import '../../models/user.dart';

class ClassDetailsBloc extends Bloc<ClassDetailsEvent, ClassDetailsState> {
  final ClassDetailsRepository classDetailsRepository;
  String? _currentClassId; // Store current class ID

  ClassDetailsBloc({
    required this.classDetailsRepository,
  }) : super(ClassDetailsInitial()) {
    if (kDebugMode) {
      print("[ClassDetailsBloc] Initialized.");
    }

    // Teacher-related event handlers
    on<LoadClassTeachers>(_onLoadClassTeachers);
    on<LoadStaffList>(_onLoadStaffList);
    on<AssignTeacherToClass>(_onAssignTeacherToClass);
    on<UpdateClassTeachers>(_onUpdateClassTeachers);
    on<RemoveTeacherFromClass>(_onRemoveTeacherFromClass);

    // Subject-related event handlers
    on<LoadClassSubjects>(_onLoadClassSubjects);
    on<LoadStaffSubjects>(_onLoadStaffSubjects);
    on<LoadAvailableSubjects>(_onLoadAvailableSubjects);
    on<AssignSubjectToClass>(_onAssignSubjectToClass);
    on<BulkAssignSubjectsToClass>(_onBulkAssignSubjectToClass);
    on<RemoveSubjectFromClass>(_onRemoveSubjectFromClass);
    on<AssignStaffToSubject>(_onAssignStaffToSubject);
    on<RemoveStaffFromSubject>(_onRemoveStaffFromSubject);
  }

  // ============================================================================
  // TEACHER-RELATED EVENT HANDLERS
  // ============================================================================

  Future<void> _onLoadClassTeachers(
      LoadClassTeachers event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Loading teacher for class: ${event.classId}");
      }

      // Store the current class ID
      _currentClassId = event.classId;

      emit(ClassDetailsLoading());

      final teacher = await classDetailsRepository.getClassTeacherAssignments(event.classId);

      if (kDebugMode) {
        if (teacher != null) {
          print("[ClassDetailsBloc] Found teacher: ${teacher.firstName} ${teacher.lastName} for class ${event.classId}");
        } else {
          print("[ClassDetailsBloc] No teacher assigned to class ${event.classId}");
        }
      }

      emit(ClassTeacherLoaded(teacher));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error loading class teacher: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to load class teacher: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStaffList(
      LoadStaffList event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Loading staff list");
      }

      emit(ClassDetailsLoading());

      final staffList = await classDetailsRepository.fetchStaff();

      // Get current teacher if state has one
      User? currentTeacher;
      if (state is ClassTeacherLoaded) {
        currentTeacher = (state as ClassTeacherLoaded).teacher;
      }

      if (kDebugMode) {
        print("[ClassDetailsBloc] Loaded ${staffList.length} staff members");
      }

      emit(StaffListLoaded(staffList, currentTeacher));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error loading staff list: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to load staff list: ${e.toString()}'));
    }
  }

  Future<void> _onAssignTeacherToClass(
      AssignTeacherToClass event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Assigning teacher ${event.teacherId} to class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.assignStaffToClass(
          event.classId,
          event.teacherId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully assigned teacher to class");
      }

      emit(TeacherAssignmentSuccess('Teacher assigned successfully'));

      // Reload teachers after assignment
      add(LoadClassTeachers(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error assigning teacher: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to assign teacher: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateClassTeachers(
      UpdateClassTeachers event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Updating teachers for class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.updateClassTeacherAssignments(
          event.classId,
          event.teacherIds
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully updated class teachers");
      }

      emit(TeacherAssignmentSuccess('Teachers updated successfully'));

      // Reload teachers after update
      add(LoadClassTeachers(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error updating teachers: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to update teachers: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveTeacherFromClass(
      RemoveTeacherFromClass event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Removing teacher ${event.teacherId} from class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.removeStaffFromClass(
          event.classId,
          event.teacherId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully removed teacher from class");
      }

      emit(TeacherAssignmentSuccess('Teacher removed successfully'));

      // Reload teachers after removal
      add(LoadClassTeachers(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error removing teacher: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to remove teacher: ${e.toString()}'));
    }
  }

  // ============================================================================
  // SUBJECT-RELATED EVENT HANDLERS
  // ============================================================================

  Future<void> _onLoadClassSubjects(
      LoadClassSubjects event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Loading subjects for class: ${event.classId}");
      }

      // Store the current class ID
      _currentClassId = event.classId;

      emit(ClassDetailsLoading());

      final subjects = await classDetailsRepository.getClassSubjects(event.classId);

      if (kDebugMode) {
        print("[ClassDetailsBloc] Found ${subjects.length} subjects for class ${event.classId}");
      }

      emit(ClassSubjectsLoaded(subjects));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error loading class subjects: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to load class subjects: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStaffSubjects(
      LoadStaffSubjects event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Loading staff subjects for class: ${event.classId}");
      }

      // Store the current class ID
      _currentClassId = event.classId;

      emit(ClassDetailsLoading());

      final subjects = await classDetailsRepository.getStaffSubjectAssignments(event.classId);

      if (kDebugMode) {
        print("[ClassDetailsBloc] Found ${subjects.length} staff subject assignments for class ${event.classId}");
      }

      emit(StaffSubjectsLoaded(subjects));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error loading staff subjects: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to load staff subjects: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAvailableSubjects(
      LoadAvailableSubjects event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Loading available subjects");
      }

      emit(ClassDetailsLoading());

      List<Subject> availableSubjects;

      // If we have a current class ID, get subjects not assigned to that class
      if (_currentClassId != null) {
        availableSubjects = await classDetailsRepository.getAvailableSubjectsForClass(_currentClassId!);
      } else {
        // Fallback to all subjects if no class ID is available
        availableSubjects = await classDetailsRepository.fetchSubjects();
      }

      if (kDebugMode) {
        print("[ClassDetailsBloc] Found ${availableSubjects.length} available subjects");
      }

      emit(AvailableSubjectsLoaded(availableSubjects));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error loading available subjects: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to load available subjects: ${e.toString()}'));
    }
  }

  Future<void> _onAssignSubjectToClass(
      AssignSubjectToClass event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Assigning subject ${event.subjectId} to class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.assignSubjectToClass(
          event.classId,
          event.subjectId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully assigned subject to class");
      }

      emit(SubjectAssignmentSuccess('Subject assigned successfully'));

      // Reload subjects after assignment
      add(LoadClassSubjects(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error assigning subject: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to assign subject: ${e.toString()}'));
    }
  }

  Future<void> _onBulkAssignSubjectToClass(
      BulkAssignSubjectsToClass event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Bulk assigning ${event.subjectId.length} subjects to class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.bulkAssignSubjectToClass(
          event.classId,
          event.subjectId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully bulk assigned subjects to class");
      }

      emit(SubjectAssignmentSuccess('${event.subjectId.length} subjects assigned successfully'));

      // Reload subjects after assignment
      add(LoadClassSubjects(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error bulk assigning subjects: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to assign subjects: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveSubjectFromClass(
      RemoveSubjectFromClass event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Removing subject ${event.classSubjectId} from class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.removeSubjectFromClass(
          event.classSubjectId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully removed subject from class");
      }

      emit(SubjectAssignmentSuccess('Subject removed successfully'));

      // Reload subjects after removal
      add(LoadClassSubjects(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error removing subject: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to remove subject: ${e.toString()}'));
    }
  }

  Future<void> _onAssignStaffToSubject(
      AssignStaffToSubject event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Assigning staff ${event.subjectId} to subject ${event.classSubjectId} in class ${event.classId}");
      }

      emit(ClassDetailsLoading());

      await classDetailsRepository.assignStaffToSubject(
          event.classId,
          event.subjectId,
          event.classSubjectId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully assigned staff to subject");
      }

      emit(SubjectStaffAssignmentSuccess('Teacher assigned to subject successfully'));

      // Reload staff subjects after assignment
      add(LoadStaffSubjects(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error assigning staff to subject: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to assign teacher to subject: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveStaffFromSubject(
      RemoveStaffFromSubject event,
      Emitter<ClassDetailsState> emit
      ) async {
    try {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Removing staff from subject ${event.staffSubjectId} in class");
      }

      emit(ClassDetailsLoading());

      // Assuming you have a method to remove staff from subject specifically
      // If not, you might need to add this method to your repository
      await classDetailsRepository.removeStaffFromSubject(
          event.staffSubjectId
      );

      if (kDebugMode) {
        print("[ClassDetailsBloc] Successfully removed staff from subject");
      }

      emit(SubjectStaffAssignmentSuccess('Teacher removed from subject successfully'));

      // Reload staff subjects after removal
      add(LoadStaffSubjects(event.classId));

    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[ClassDetailsBloc] Error removing staff from subject: $e");
        print("[ClassDetailsBloc] Stacktrace: $stacktrace");
      }
      emit(ClassDetailsError('Failed to remove teacher from subject: ${e.toString()}'));
    }
  }
}