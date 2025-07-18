class UpdateFeesStructureRequest {
  final String classId;
  final String academicYearId;
  final String name;
  final String amount;
  final bool isMandatory;

  UpdateFeesStructureRequest({
    required this.classId,
    required this.academicYearId,
    required this.name,
    required this.amount,
    this.isMandatory = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'academicYearId': academicYearId,
      'name': name,
      'amount': amount,
      'isMandatory': isMandatory,
    };
  }
}
