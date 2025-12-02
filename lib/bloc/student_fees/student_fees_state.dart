import '../../models/class.dart';
import '../../models/fees_structures/FeePayment.dart';
import '../../models/fees_structures/FeesStructureDto.dart';
import '../../models/fees_structures/StudentFeeDto.dart';
import '../../models/user.dart';

abstract class StudentFeesState {}

class StudentFeesInitial extends StudentFeesState {}

class StudentFeesLoading extends StudentFeesState {}

class StudentFeesLoaded extends StudentFeesState {
  final List<StudentFeeDto> studentFees;
  final List<Class> classes;
  final List<FeesStructureDto> feeStructures;
  final List<User> students;
  final List<FeePaymentDto> payments;
  final StudentFeesSummaryDto? summary;
  final String? selectedClassId;
  final String? selectedStatus;
  final String? selectedMonth;

  StudentFeesLoaded({
    this.studentFees = const [],
    this.classes = const [],
    this.feeStructures = const [],
    this.students = const [],
    this.payments = const [],
    this.summary,
    this.selectedClassId,
    this.selectedStatus,
    this.selectedMonth,
  });

  StudentFeesLoaded copyWith({
    List<StudentFeeDto>? studentFees,
    List<Class>? classes,
    List<FeesStructureDto>? feeStructures,
    List<User>? students,
    List<FeePaymentDto>? payments,
    StudentFeesSummaryDto? summary,
    String? selectedClassId,
    String? selectedStatus,
    String? selectedMonth,
  }) {
    return StudentFeesLoaded(
      studentFees: studentFees ?? this.studentFees,
      classes: classes ?? this.classes,
      feeStructures: feeStructures ?? this.feeStructures,
      students: students ?? this.students,
      payments: payments ?? this.payments,
      summary: summary ?? this.summary,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class StudentFeesOperationInProgress extends StudentFeesState {
  final List<StudentFeeDto> studentFees;
  final String message;

  StudentFeesOperationInProgress(this.studentFees, this.message);
}

class StudentFeesOperationSuccess extends StudentFeesState {
  final List<StudentFeeDto> studentFees;
  final String message;

  StudentFeesOperationSuccess(this.studentFees, this.message);
}

class StudentFeesOperationFailure extends StudentFeesState {
  final String error;
  final List<StudentFeeDto> studentFees;

  StudentFeesOperationFailure(this.error, this.studentFees);
}

class PaymentRecorded extends StudentFeesState {
  final StudentFeeDto updatedStudentFee;
  final FeePaymentDto payment;
  final String message;

  PaymentRecorded(this.updatedStudentFee, this.payment, this.message);
}

class FeesSummaryLoaded extends StudentFeesState {
  final StudentFeesSummaryDto summary;
  final Map<String, dynamic> reportData;

  FeesSummaryLoaded(this.summary, {this.reportData = const {}});
}