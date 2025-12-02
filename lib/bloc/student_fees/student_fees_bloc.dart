import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/class.dart';
import '../../models/fees_structures/FeePayment.dart';
import '../../models/fees_structures/StudentFeeDto.dart';
import '../../models/user.dart';
import '../../models/fees_structures/FeesStructureDto.dart';
import '../../repositories/fee_payments_repository.dart';
import '../../repositories/fees_structure_repository.dart';
import '../../repositories/class_repository.dart';
import '../../repositories/student_fees_repository.dart';
import '../../repositories/students_repository.dart';
import 'student_fees_event.dart';
import 'student_fees_state.dart';

class StudentFeesBloc extends Bloc<StudentFeesEvent, StudentFeesState> {
  final StudentFeesRepository studentFeesRepository;
  final FeePaymentsRepository feePaymentsRepository;
  final FeesStructureRepository feesStructureRepository;
  final ClassRepository classRepository;
  final StudentsRepository studentsRepository;

  List<StudentFeeDto> _studentFees = [];
  List<Class> _classes = [];
  List<FeesStructureDto> _feeStructures = [];
  List<User> _students = [];
  List<FeePaymentDto> _payments = [];

  StudentFeesBloc({
    required this.studentFeesRepository,
    required this.feePaymentsRepository,
    required this.feesStructureRepository,
    required this.classRepository,
    required this.studentsRepository,
  }) : super(StudentFeesInitial()) {
    on<LoadStudentFeesData>(_onLoadStudentFeesData);
    on<LoadFeeStructuresByClass>(_onLoadFeeStructuresByClass);
    on<LoadStudentsByClass>(_onLoadStudentsByClass);
    on<LoadStudentFees>(_onLoadStudentFees);
    on<CreateStudentFee>(_onCreateStudentFee);
    on<BulkCreateStudentFees>(_onBulkCreateStudentFees);
    on<UpdateStudentFee>(_onUpdateStudentFee);
    on<DeleteStudentFee>(_onDeleteStudentFee);
    on<RecordPayment>(_onRecordPayment);
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
    on<LoadFeesSummary>(_onLoadFeesSummary);
    on<SearchStudentFees>(_onSearchStudentFees);
    on<FilterStudentFees>(_onFilterStudentFees);
  }

  Future<void> _onLoadStudentFeesData(LoadStudentFeesData event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesLoading());

      // Load classes
      final classes = await classRepository.fetchAllClasses();
      _classes = classes;

      // Load all student fees
      final studentFees = await studentFeesRepository.getAllStudentFees();
      _studentFees = studentFees;

      emit(StudentFeesLoaded(
        studentFees: _studentFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to load student fees data: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onLoadFeeStructuresByClass(LoadFeeStructuresByClass event, Emitter<StudentFeesState> emit) async {
    try {
      final feeStructures = await feesStructureRepository.getFeesStructuresByClass(event.classId);
      _feeStructures = feeStructures;

      emit(StudentFeesLoaded(
        studentFees: _studentFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to load fee structures: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onLoadStudentsByClass(LoadStudentsByClass event, Emitter<StudentFeesState> emit) async {
    try {
      final students = await studentsRepository.getAdminStudents(event.classId);
      _students = students.map((student) => User(
        id: student.studentId,
        firstName: student.firstName,
        lastName: student.lastName,
        email: student.email,
        role: 'STUDENT', permissions: [],
      )).toList();

      emit(StudentFeesLoaded(
        studentFees: _studentFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to load students: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onLoadStudentFees(LoadStudentFees event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesLoading());

      List<StudentFeeDto> studentFees;

      if (event.studentId != null) {
        studentFees = await studentFeesRepository.getStudentFeesByStudentId(event.studentId!);
      } else {
        studentFees = await studentFeesRepository.getAllStudentFees();
      }

      // Apply filters
      if (event.status != null && event.status != 'All') {
        studentFees = studentFees.where((fee) => fee.status == event.status).toList();
      }

      if (event.month != null) {
        studentFees = studentFees.where((fee) => fee.month == event.month).toList();
      }

      _studentFees = studentFees;

      emit(StudentFeesLoaded(
        studentFees: _studentFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
        selectedStatus: event.status,
        selectedMonth: event.month,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to load student fees: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onCreateStudentFee(CreateStudentFee event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesOperationInProgress(_studentFees, "Creating student fee..."));

      final newStudentFee = await studentFeesRepository.createStudentFee(event.request);
      _studentFees.add(newStudentFee);

      emit(StudentFeesOperationSuccess(_studentFees, "Student fee created successfully!"));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to create student fee: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onBulkCreateStudentFees(BulkCreateStudentFees event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesOperationInProgress(_studentFees, "Assigning fees to students..."));

      final newStudentFees = await studentFeesRepository.createBulkStudentFees(event.request);
      _studentFees.addAll(newStudentFees);

      emit(StudentFeesOperationSuccess(
          _studentFees,
          "Fees assigned successfully to ${newStudentFees.length} students!"
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to assign fees: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onUpdateStudentFee(UpdateStudentFee event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesOperationInProgress(_studentFees, "Updating student fee..."));

      final updatedStudentFee = await studentFeesRepository.updateStudentFee(event.id, event.request);

      final index = _studentFees.indexWhere((fee) => fee.id == event.id);
      if (index != -1) {
        _studentFees[index] = updatedStudentFee;
      }

      emit(StudentFeesOperationSuccess(_studentFees, "Student fee updated successfully!"));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to update student fee: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onDeleteStudentFee(DeleteStudentFee event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesOperationInProgress(_studentFees, "Deleting student fee..."));

      await studentFeesRepository.deleteStudentFee(event.id);
      _studentFees.removeWhere((fee) => fee.id == event.id);

      emit(StudentFeesOperationSuccess(_studentFees, "Student fee deleted successfully!"));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to delete student fee: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onRecordPayment(RecordPayment event, Emitter<StudentFeesState> emit) async {
    try {
      emit(StudentFeesOperationInProgress(_studentFees, "Recording payment..."));

      // Record payment
      final updatedStudentFee = await studentFeesRepository.payStudentFee(event.studentFeeId, event.request);

      // Update the student fee in the list
      final index = _studentFees.indexWhere((fee) => fee.id == event.studentFeeId);
      if (index != -1) {
        _studentFees[index] = updatedStudentFee;
      }

      // Load payment history for this student fee
      final payments = await feePaymentsRepository.getPaymentsByStudentFeeId(event.studentFeeId);
      _payments = payments;

      emit(StudentFeesOperationSuccess(_studentFees, "Payment recorded successfully!"));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to record payment: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onLoadPaymentHistory(LoadPaymentHistory event, Emitter<StudentFeesState> emit) async {
    try {
      List<FeePaymentDto> payments;

      if (event.studentFeeId != null) {
        payments = await feePaymentsRepository.getPaymentsByStudentFeeId(event.studentFeeId!);
      } else if (event.studentId != null) {
        payments = await feePaymentsRepository.getPaymentsByStudentId(event.studentId!);
      } else {
        payments = await feePaymentsRepository.getAllFeePayments();
      }

      // Apply date filters if provided
      if (event.startDate != null && event.endDate != null) {
        payments = payments.where((payment) {
          final paymentDate = DateTime.parse(payment.paymentDate);
          final startDate = DateTime.parse(event.startDate!);
          final endDate = DateTime.parse(event.endDate!);
          return paymentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              paymentDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }

      _payments = payments;

      emit(StudentFeesLoaded(
        studentFees: _studentFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to load payment history: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onLoadFeesSummary(LoadFeesSummary event, Emitter<StudentFeesState> emit) async {
    try {
      // This would typically call a specific API endpoint for summary data
      // For now, we'll calculate from existing data

      var fees = _studentFees;

      // Apply filters
      if (event.classId != null) {
        fees = fees.where((fee) => fee.className?.contains(event.classId!) ?? false).toList();
      }

      if (event.month != null) {
        fees = fees.where((fee) => fee.month == event.month).toList();
      }

      // Calculate summary
      final totalAmount = fees.fold<double>(0, (sum, fee) => sum + double.parse(fee.amount));
      final paidAmount = fees.fold<double>(0, (sum, fee) => sum + double.parse(fee.paidAmount));
      final pendingAmount = totalAmount - paidAmount;

      final paidCount = fees.where((fee) => fee.status == 'PAID').length;
      final partiallyPaidCount = fees.where((fee) => fee.status == 'PARTIALLY_PAID').length;
      final pendingCount = fees.where((fee) => fee.status == 'PENDING').length;

      final summaryData = {
        'totalStudents': fees.length,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'pendingAmount': pendingAmount,
        'paidCount': paidCount,
        'partiallyPaidCount': partiallyPaidCount,
        'pendingCount': pendingCount,
        'collectionPercentage': totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0,
      };

      emit(FeesSummaryLoaded(
        StudentFeesSummaryDto(
          totalFees: totalAmount.toString(),
          totalPaid: paidAmount.toString(),
          paidCount: paidCount,
          partiallyPaidCount: partiallyPaidCount,
          pendingCount: pendingCount, studentId: '', studentName: '', totalBalance: '', overdueCount: 0,
        ),
        reportData: summaryData,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to load fees summary: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onSearchStudentFees(SearchStudentFees event, Emitter<StudentFeesState> emit) async {
    try {
      var filteredFees = _studentFees;

      if (event.query.isNotEmpty) {
        filteredFees = _studentFees.where((fee) {
          final query = event.query.toLowerCase();
          return fee.studentName?.toLowerCase().contains(query) == true ||
              fee.studentEmail?.toLowerCase().contains(query) == true ||
              fee.feeStructureName?.toLowerCase().contains(query) == true ||
              fee.month.toLowerCase().contains(query);
        }).toList();
      }

      emit(StudentFeesLoaded(
        studentFees: filteredFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to search student fees: ${e.toString()}', _studentFees));
    }
  }

  Future<void> _onFilterStudentFees(FilterStudentFees event, Emitter<StudentFeesState> emit) async {
    try {
      var filteredFees = _studentFees;

      // Apply status filter
      if (event.status != null && event.status != 'All') {
        filteredFees = filteredFees.where((fee) => fee.status == event.status).toList();
      }

      // Apply class filter
      if (event.classId != null) {
        filteredFees = filteredFees.where((fee) =>
        fee.className?.contains(event.classId!) ?? false).toList();
      }

      // Apply month filter
      if (event.month != null) {
        filteredFees = filteredFees.where((fee) => fee.month == event.month).toList();
      }

      // Apply date range filter
      if (event.dateRange != null) {
        filteredFees = filteredFees.where((fee) {
          final dueDate = DateTime.parse(fee.dueDate);
          return dueDate.isAfter(event.dateRange!.start.subtract(const Duration(days: 1))) &&
              dueDate.isBefore(event.dateRange!.end.add(const Duration(days: 1)));
        }).toList();
      }

      emit(StudentFeesLoaded(
        studentFees: filteredFees,
        classes: _classes,
        feeStructures: _feeStructures,
        students: _students,
        payments: _payments,
        selectedStatus: event.status,
        selectedClassId: event.classId,
        selectedMonth: event.month,
      ));
    } catch (e) {
      emit(StudentFeesOperationFailure('Failed to filter student fees: ${e.toString()}', _studentFees));
    }
  }
}