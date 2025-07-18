class FeesStructureDto {
  final String? id;
  final String classId;
  final String academicYearId;
  final String name;
  final String amount;
  final bool isMandatory;
  final String? createdAt;
  final String? updatedAt;
  final String? className;
  final String? sectionName;
  final String? academicYearName;

  FeesStructureDto({
    this.id,
    required this.classId,
    required this.academicYearId,
    required this.name,
    required this.amount,
    this.isMandatory = true,
    this.createdAt,
    this.updatedAt,
    this.className,
    this.sectionName,
    this.academicYearName,
  });

  factory FeesStructureDto.fromJson(Map<String, dynamic> json) {
    return FeesStructureDto(
      id: json['id'],
      classId: json['classId'],
      academicYearId: json['academicYearId'],
      name: json['name'],
      amount: json['amount'],
      isMandatory: json['isMandatory'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      className: json['className'],
      sectionName: json['sectionName'],
      academicYearName: json['academicYearName'],
    );
  }
}