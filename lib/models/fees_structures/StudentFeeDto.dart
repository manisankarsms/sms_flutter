// lib/models/student_fee.dart
class StudentFeeDto {
  final String? id;
  final String studentId;
  final String feeStructureId;
  final String amount;
  final String paidAmount;
  final String status;
  final String dueDate;
  final String? paidDate;
  final String month;
  final String? createdAt;
  final String? updatedAt;
  final String? studentName;
  final String? studentEmail;
  final String? feeStructureName;
  final String? className;
  final String? sectionName;
  final String? academicYearName;
  final String? balanceAmount;

  StudentFeeDto({
    this.id,
    required this.studentId,
    required this.feeStructureId,
    required this.amount,
    required this.paidAmount,
    required this.status,
    required this.dueDate,
    this.paidDate,
    required this.month,
    this.createdAt,
    this.updatedAt,
    this.studentName,
    this.studentEmail,
    this.feeStructureName,
    this.className,
    this.sectionName,
    this.academicYearName,
    this.balanceAmount,
  });

  factory StudentFeeDto.fromJson(Map<String, dynamic> json) {
    return StudentFeeDto(
      id: json['id'],
      studentId: json['studentId'],
      feeStructureId: json['feeStructureId'],
      amount: json['amount'],
      paidAmount: json['paidAmount'],
      status: json['status'],
      dueDate: json['dueDate'],
      paidDate: json['paidDate'],
      month: json['month'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      studentName: json['studentName'],
      studentEmail: json['studentEmail'],
      feeStructureName: json['feeStructureName'],
      className: json['className'],
      sectionName: json['sectionName'],
      academicYearName: json['academicYearName'],
      balanceAmount: json['balanceAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'feeStructureId': feeStructureId,
      'amount': amount,
      'paidAmount': paidAmount,
      'status': status,
      'dueDate': dueDate,
      'paidDate': paidDate,
      'month': month,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'feeStructureName': feeStructureName,
      'className': className,
      'sectionName': sectionName,
      'academicYearName': academicYearName,
      'balanceAmount': balanceAmount,
    };
  }
}

class CreateStudentFeeRequest {
  final String studentId;
  final String feeStructureId;
  final String amount;
  final String dueDate;
  final String month;

  CreateStudentFeeRequest({
    required this.studentId,
    required this.feeStructureId,
    required this.amount,
    required this.dueDate,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'feeStructureId': feeStructureId,
      'amount': amount,
      'dueDate': dueDate,
      'month': month,
    };
  }
}

class UpdateStudentFeeRequest {
  final String amount;
  final String dueDate;
  final String month;

  UpdateStudentFeeRequest({
    required this.amount,
    required this.dueDate,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'dueDate': dueDate,
      'month': month,
    };
  }
}

class BulkCreateStudentFeeRequest {
  final String feeStructureId;
  final List<String> studentIds;
  final String dueDate;
  final String month;

  BulkCreateStudentFeeRequest({
    required this.feeStructureId,
    required this.studentIds,
    required this.dueDate,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'feeStructureId': feeStructureId,
      'studentIds': studentIds,
      'dueDate': dueDate,
      'month': month,
    };
  }
}

class PayFeeRequest {
  final String amount;
  final String paymentMode;
  final String? receiptNumber;
  final String? remarks;

  PayFeeRequest({
    required this.amount,
    required this.paymentMode,
    this.receiptNumber,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paymentMode': paymentMode,
      'receiptNumber': receiptNumber,
      'remarks': remarks,
    };
  }
}

class StudentFeesSummaryDto {
  final String studentId;
  final String studentName;
  final String totalFees;
  final String totalPaid;
  final String totalBalance;
  final int paidCount;
  final int partiallyPaidCount;
  final int pendingCount;
  final int overdueCount;

  StudentFeesSummaryDto({
    required this.studentId,
    required this.studentName,
    required this.totalFees,
    required this.totalPaid,
    required this.totalBalance,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.pendingCount,
    required this.overdueCount,
  });

  factory StudentFeesSummaryDto.fromJson(Map<String, dynamic> json) {
    return StudentFeesSummaryDto(
      studentId: json['studentId'],
      studentName: json['studentName'],
      totalFees: json['totalFees'],
      totalPaid: json['totalPaid'],
      totalBalance: json['totalBalance'],
      paidCount: json['paidCount'],
      partiallyPaidCount: json['partiallyPaidCount'],
      pendingCount: json['pendingCount'],
      overdueCount: json['overdueCount'],
    );
  }
}

class MonthlyFeeReportDto {
  final String month;
  final String totalFees;
  final String totalPaid;
  final String totalBalance;
  final int studentCount;
  final int paidCount;
  final int partiallyPaidCount;
  final int pendingCount;

  MonthlyFeeReportDto({
    required this.month,
    required this.totalFees,
    required this.totalPaid,
    required this.totalBalance,
    required this.studentCount,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.pendingCount,
  });

  factory MonthlyFeeReportDto.fromJson(Map<String, dynamic> json) {
    return MonthlyFeeReportDto(
      month: json['month'],
      totalFees: json['totalFees'],
      totalPaid: json['totalPaid'],
      totalBalance: json['totalBalance'],
      studentCount: json['studentCount'],
      paidCount: json['paidCount'],
      partiallyPaidCount: json['partiallyPaidCount'],
      pendingCount: json['pendingCount'],
    );
  }
}

class ClassFeesSummaryDto {
  final String classId;
  final String className;
  final String sectionName;
  final String totalFees;
  final String totalPaid;
  final String totalBalance;
  final int studentCount;
  final String collectionPercentage;

  ClassFeesSummaryDto({
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.totalFees,
    required this.totalPaid,
    required this.totalBalance,
    required this.studentCount,
    required this.collectionPercentage,
  });

  factory ClassFeesSummaryDto.fromJson(Map<String, dynamic> json) {
    return ClassFeesSummaryDto(
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      totalFees: json['totalFees'],
      totalPaid: json['totalPaid'],
      totalBalance: json['totalBalance'],
      studentCount: json['studentCount'],
      collectionPercentage: json['collectionPercentage'],
    );
  }
}