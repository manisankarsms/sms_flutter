import 'FeesStructureItem.dart';

class BulkCreateFeesStructureRequest {
  final String classId;
  final String academicYearId;
  final List<FeesStructureItem> feeStructures;

  BulkCreateFeesStructureRequest({
    required this.classId,
    required this.academicYearId,
    required this.feeStructures,
  });

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'academicYearId': academicYearId,
      'feeStructures': feeStructures.map((item) => item.toJson()).toList(),
    };
  }
}