class StudentFeesSummaryDto {
  final int totalStudents;
  final String totalAmount;
  final String paidAmount;
  final String pendingAmount;
  final int paidCount;
  final int partiallyPaidCount;
  final int pendingCount;
  final String? classId;
  final String? className;
  final String? month;
  final String? academicYear;

  StudentFeesSummaryDto({
    required this.totalStudents,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.pendingCount,
    this.classId,
    this.className,
    this.month,
    this.academicYear,
  });

  double get totalAmountValue => double.tryParse(totalAmount) ?? 0.0;
  double get paidAmountValue => double.tryParse(paidAmount) ?? 0.0;
  double get pendingAmountValue => double.tryParse(pendingAmount) ?? 0.0;

  double get collectionPercentage =>
      totalAmountValue > 0 ? (paidAmountValue / totalAmountValue * 100) : 0.0;
}