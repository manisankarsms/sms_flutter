// lib/models/fee_payment.dart
class FeePaymentDto {
  final String? id;
  final String studentFeeId;
  final String amount;
  final String paymentMode;
  final String paymentDate;
  final String? receiptNumber;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;
  final String? studentId;
  final String? studentName;
  final String? studentEmail;
  final String? feeStructureId;
  final String? feeStructureName;
  final String? className;
  final String? sectionName;
  final String? academicYearName;
  final String? month;
  final String? feeAmount;
  final String? feePaidAmount;
  final String? feeStatus;

  FeePaymentDto({
    this.id,
    required this.studentFeeId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.receiptNumber,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.studentId,
    this.studentName,
    this.studentEmail,
    this.feeStructureId,
    this.feeStructureName,
    this.className,
    this.sectionName,
    this.academicYearName,
    this.month,
    this.feeAmount,
    this.feePaidAmount,
    this.feeStatus,
  });

  factory FeePaymentDto.fromJson(Map<String, dynamic> json) {
    return FeePaymentDto(
      id: json['id'],
      studentFeeId: json['studentFeeId'],
      amount: json['amount'],
      paymentMode: json['paymentMode'],
      paymentDate: json['paymentDate'],
      receiptNumber: json['receiptNumber'],
      remarks: json['remarks'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentEmail: json['studentEmail'],
      feeStructureId: json['feeStructureId'],
      feeStructureName: json['feeStructureName'],
      className: json['className'],
      sectionName: json['sectionName'],
      academicYearName: json['academicYearName'],
      month: json['month'],
      feeAmount: json['feeAmount'],
      feePaidAmount: json['feePaidAmount'],
      feeStatus: json['feeStatus'],
    );
  }
}

class CreateFeePaymentRequest {
  final String studentFeeId;
  final String amount;
  final String paymentMode;
  final String? receiptNumber;
  final String? remarks;

  CreateFeePaymentRequest({
    required this.studentFeeId,
    required this.amount,
    required this.paymentMode,
    this.receiptNumber,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentFeeId': studentFeeId,
      'amount': amount,
      'paymentMode': paymentMode,
      'receiptNumber': receiptNumber,
      'remarks': remarks,
    };
  }
}

class UpdateFeePaymentRequest {
  final String amount;
  final String paymentMode;
  final String? receiptNumber;
  final String? remarks;

  UpdateFeePaymentRequest({
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

class PaymentSummaryDto {
  final String studentId;
  final String studentName;
  final String totalPayments;
  final int paymentCount;
  final String? lastPaymentDate;
  final String averagePaymentAmount;
  final Map<String, int> paymentModes;

  PaymentSummaryDto({
    required this.studentId,
    required this.studentName,
    required this.totalPayments,
    required this.paymentCount,
    this.lastPaymentDate,
    required this.averagePaymentAmount,
    required this.paymentModes,
  });

  factory PaymentSummaryDto.fromJson(Map<String, dynamic> json) {
    return PaymentSummaryDto(
      studentId: json['studentId'],
      studentName: json['studentName'],
      totalPayments: json['totalPayments'],
      paymentCount: json['paymentCount'],
      lastPaymentDate: json['lastPaymentDate'],
      averagePaymentAmount: json['averagePaymentAmount'],
      paymentModes: Map<String, int>.from(json['paymentModes'] ?? {}),
    );
  }
}

class DailyPaymentReportDto {
  final String date;
  final String totalAmount;
  final int paymentCount;
  final Map<String, String> paymentModes;
  final String cashAmount;
  final String onlineAmount;
  final String bankTransferAmount;
  final String upiAmount;
  final String cardAmount;

  DailyPaymentReportDto({
    required this.date,
    required this.totalAmount,
    required this.paymentCount,
    required this.paymentModes,
    required this.cashAmount,
    required this.onlineAmount,
    required this.bankTransferAmount,
    required this.upiAmount,
    required this.cardAmount,
  });

  factory DailyPaymentReportDto.fromJson(Map<String, dynamic> json) {
    return DailyPaymentReportDto(
      date: json['date'],
      totalAmount: json['totalAmount'],
      paymentCount: json['paymentCount'],
      paymentModes: Map<String, String>.from(json['paymentModes'] ?? {}),
      cashAmount: json['cashAmount'],
      onlineAmount: json['onlineAmount'],
      bankTransferAmount: json['bankTransferAmount'],
      upiAmount: json['upiAmount'],
      cardAmount: json['cardAmount'],
    );
  }
}

class MonthlyFeeReportDto {
  final String month;
  final int totalStudents;
  final String totalAmount;
  final String paidAmount;
  final String pendingAmount;
  final int paidCount;
  final int partiallyPaidCount;
  final int pendingCount;
  final double collectionPercentage;
  final List<ClassFeesSummaryDto> classSummaries;

  MonthlyFeeReportDto({
    required this.month,
    required this.totalStudents,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.pendingCount,
    required this.collectionPercentage,
    required this.classSummaries,
  });

  factory MonthlyFeeReportDto.fromJson(Map<String, dynamic> json) {
    return MonthlyFeeReportDto(
      month: json['month'],
      totalStudents: json['totalStudents'],
      totalAmount: json['totalAmount'],
      paidAmount: json['paidAmount'],
      pendingAmount: json['pendingAmount'],
      paidCount: json['paidCount'],
      partiallyPaidCount: json['partiallyPaidCount'],
      pendingCount: json['pendingCount'],
      collectionPercentage: (json['collectionPercentage'] as num).toDouble(),
      classSummaries: (json['classSummaries'] as List)
          .map((e) => ClassFeesSummaryDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'month': month,
    'totalStudents': totalStudents,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'pendingAmount': pendingAmount,
    'paidCount': paidCount,
    'partiallyPaidCount': partiallyPaidCount,
    'pendingCount': pendingCount,
    'collectionPercentage': collectionPercentage,
    'classSummaries': classSummaries.map((e) => e.toJson()).toList(),
  };
}

class ClassFeesSummaryDto {
  final String classId;
  final String className;
  final String? sectionName;
  final String? month;
  final int totalStudents;
  final String totalAmount;
  final String paidAmount;
  final String pendingAmount;
  final int paidCount;
  final int partiallyPaidCount;
  final int pendingCount;
  final double collectionPercentage;

  ClassFeesSummaryDto({
    required this.classId,
    required this.className,
    this.sectionName,
    this.month,
    required this.totalStudents,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.pendingCount,
    required this.collectionPercentage,
  });

  factory ClassFeesSummaryDto.fromJson(Map<String, dynamic> json) {
    return ClassFeesSummaryDto(
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      month: json['month'],
      totalStudents: json['totalStudents'],
      totalAmount: json['totalAmount'],
      paidAmount: json['paidAmount'],
      pendingAmount: json['pendingAmount'],
      paidCount: json['paidCount'],
      partiallyPaidCount: json['partiallyPaidCount'],
      pendingCount: json['pendingCount'],
      collectionPercentage: (json['collectionPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'className': className,
    'sectionName': sectionName,
    'month': month,
    'totalStudents': totalStudents,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'pendingAmount': pendingAmount,
    'paidCount': paidCount,
    'partiallyPaidCount': partiallyPaidCount,
    'pendingCount': pendingCount,
    'collectionPercentage': collectionPercentage,
  };
}

class MonthlyPaymentReportDto {
  final String month;
  final int totalPayments;
  final String totalAmount;
  final List<PaymentModeBreakdownDto> paymentModeBreakdown;
  final List<DailyPaymentSummaryDto> dailySummaries;

  MonthlyPaymentReportDto({
    required this.month,
    required this.totalPayments,
    required this.totalAmount,
    required this.paymentModeBreakdown,
    required this.dailySummaries,
  });

  factory MonthlyPaymentReportDto.fromJson(Map<String, dynamic> json) {
    return MonthlyPaymentReportDto(
      month: json['month'],
      totalPayments: json['totalPayments'],
      totalAmount: json['totalAmount'],
      paymentModeBreakdown: (json['paymentModeBreakdown'] as List)
          .map((e) => PaymentModeBreakdownDto.fromJson(e))
          .toList(),
      dailySummaries: (json['dailySummaries'] as List)
          .map((e) => DailyPaymentSummaryDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'month': month,
    'totalPayments': totalPayments,
    'totalAmount': totalAmount,
    'paymentModeBreakdown':
    paymentModeBreakdown.map((e) => e.toJson()).toList(),
    'dailySummaries': dailySummaries.map((e) => e.toJson()).toList(),
  };
}

class ClassPaymentSummaryDto {
  final String classId;
  final String className;
  final String? sectionName;
  final String startDate;
  final String endDate;
  final int totalPayments;
  final String totalAmount;
  final List<PaymentModeBreakdownDto> paymentModeBreakdown;

  ClassPaymentSummaryDto({
    required this.classId,
    required this.className,
    this.sectionName,
    required this.startDate,
    required this.endDate,
    required this.totalPayments,
    required this.totalAmount,
    required this.paymentModeBreakdown,
  });

  factory ClassPaymentSummaryDto.fromJson(Map<String, dynamic> json) {
    return ClassPaymentSummaryDto(
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalPayments: json['totalPayments'],
      totalAmount: json['totalAmount'],
      paymentModeBreakdown: (json['paymentModeBreakdown'] as List)
          .map((e) => PaymentModeBreakdownDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'className': className,
    'sectionName': sectionName,
    'startDate': startDate,
    'endDate': endDate,
    'totalPayments': totalPayments,
    'totalAmount': totalAmount,
    'paymentModeBreakdown':
    paymentModeBreakdown.map((e) => e.toJson()).toList(),
  };
}

class PaymentModeBreakdownDto {
  final String paymentMode;
  final int count;
  final String amount;
  final double percentage;

  PaymentModeBreakdownDto({
    required this.paymentMode,
    required this.count,
    required this.amount,
    required this.percentage,
  });

  factory PaymentModeBreakdownDto.fromJson(Map<String, dynamic> json) {
    return PaymentModeBreakdownDto(
      paymentMode: json['paymentMode'],
      count: json['count'],
      amount: json['amount'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'paymentMode': paymentMode,
    'count': count,
    'amount': amount,
    'percentage': percentage,
  };
}

class DailyPaymentSummaryDto {
  final String date;
  final int totalPayments;
  final String totalAmount;

  DailyPaymentSummaryDto({
    required this.date,
    required this.totalPayments,
    required this.totalAmount,
  });

  factory DailyPaymentSummaryDto.fromJson(Map<String, dynamic> json) {
    return DailyPaymentSummaryDto(
      date: json['date'],
      totalPayments: json['totalPayments'],
      totalAmount: json['totalAmount'],
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'totalPayments': totalPayments,
    'totalAmount': totalAmount,
  };
}

class PaymentStatisticsDto {
  final String? classId;
  final String? className;
  final String? month;
  final String? startDate;
  final String? endDate;
  final int totalPayments;
  final String totalAmount;
  final String averagePaymentAmount;
  final List<PaymentModeBreakdownDto> paymentModeBreakdown;
  final List<String> topPaymentDates;
  final Map<String, dynamic> trends;

  PaymentStatisticsDto({
    this.classId,
    this.className,
    this.month,
    this.startDate,
    this.endDate,
    required this.totalPayments,
    required this.totalAmount,
    required this.averagePaymentAmount,
    required this.paymentModeBreakdown,
    required this.topPaymentDates,
    required this.trends,
  });

  factory PaymentStatisticsDto.fromJson(Map<String, dynamic> json) {
    return PaymentStatisticsDto(
      classId: json['classId'],
      className: json['className'],
      month: json['month'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalPayments: json['totalPayments'],
      totalAmount: json['totalAmount'],
      averagePaymentAmount: json['averagePaymentAmount'],
      paymentModeBreakdown: (json['paymentModeBreakdown'] as List)
          .map((e) => PaymentModeBreakdownDto.fromJson(e))
          .toList(),
      topPaymentDates: List<String>.from(json['topPaymentDates']),
      trends: Map<String, dynamic>.from(json['trends']),
    );
  }

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'className': className,
    'month': month,
    'startDate': startDate,
    'endDate': endDate,
    'totalPayments': totalPayments,
    'totalAmount': totalAmount,
    'averagePaymentAmount': averagePaymentAmount,
    'paymentModeBreakdown':
    paymentModeBreakdown.map((e) => e.toJson()).toList(),
    'topPaymentDates': topPaymentDates,
    'trends': trends,
  };
}
