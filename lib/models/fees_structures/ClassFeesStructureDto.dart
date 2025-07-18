import 'FeesStructureDto.dart';

class ClassFeesStructureDto {
  final String classId;
  final String className;
  final String sectionName;
  final String academicYearId;
  final String academicYearName;
  final List<FeesStructureDto> feeStructures;
  final String totalMandatoryFees;
  final String totalOptionalFees;
  final String totalFees;

  ClassFeesStructureDto({
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.academicYearId,
    required this.academicYearName,
    required this.feeStructures,
    required this.totalMandatoryFees,
    required this.totalOptionalFees,
    required this.totalFees,
  });

  factory ClassFeesStructureDto.fromJson(Map<String, dynamic> json) {
    return ClassFeesStructureDto(
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],
      feeStructures: (json['feeStructures'] as List)
          .map((item) => FeesStructureDto.fromJson(item))
          .toList(),
      totalMandatoryFees: json['totalMandatoryFees'],
      totalOptionalFees: json['totalOptionalFees'],
      totalFees: json['totalFees'],
    );
  }
}