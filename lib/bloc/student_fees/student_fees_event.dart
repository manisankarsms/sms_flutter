import 'package:flutter/material.dart';

import '../../models/fees_structures/StudentFeeDto.dart';

abstract class StudentFeesEvent {}

class LoadStudentFeesData extends StudentFeesEvent {}

class LoadFeeStructuresByClass extends StudentFeesEvent {
  final String classId;
  LoadFeeStructuresByClass(this.classId);
}

class LoadStudentsByClass extends StudentFeesEvent {
  final String classId;
  LoadStudentsByClass(this.classId);
}

class LoadStudentFees extends StudentFeesEvent {
  final String? classId;
  final String? studentId;
  final String? status;
  final String? month;

  LoadStudentFees({this.classId, this.studentId, this.status, this.month});
}

class CreateStudentFee extends StudentFeesEvent {
  final CreateStudentFeeRequest request;
  CreateStudentFee(this.request);
}

class BulkCreateStudentFees extends StudentFeesEvent {
  final BulkCreateStudentFeeRequest request;
  BulkCreateStudentFees(this.request);
}

class UpdateStudentFee extends StudentFeesEvent {
  final String id;
  final UpdateStudentFeeRequest request;
  UpdateStudentFee(this.id, this.request);
}

class DeleteStudentFee extends StudentFeesEvent {
  final String id;
  DeleteStudentFee(this.id);
}

class RecordPayment extends StudentFeesEvent {
  final String studentFeeId;
  final PayFeeRequest request;
  RecordPayment(this.studentFeeId, this.request);
}

class LoadPaymentHistory extends StudentFeesEvent {
  final String? studentId;
  final String? studentFeeId;
  final String? startDate;
  final String? endDate;

  LoadPaymentHistory({this.studentId, this.studentFeeId, this.startDate, this.endDate});
}

class LoadFeesSummary extends StudentFeesEvent {
  final String? classId;
  final String? month;
  final String? academicYearId;

  LoadFeesSummary({this.classId, this.month, this.academicYearId});
}

class GenerateFeeReport extends StudentFeesEvent {
  final String reportType; // 'monthly', 'class', 'student'
  final Map<String, dynamic> parameters;

  GenerateFeeReport(this.reportType, this.parameters);
}

class SearchStudentFees extends StudentFeesEvent {
  final String query;
  SearchStudentFees(this.query);
}

class FilterStudentFees extends StudentFeesEvent {
  final String? status;
  final String? classId;
  final String? month;
  final DateTimeRange? dateRange;

  FilterStudentFees({this.status, this.classId, this.month, this.dateRange});
}