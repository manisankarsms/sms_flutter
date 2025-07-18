import 'ClassFeesStructureDto.dart';

class FeesStructureSummaryDto {
  final String academicYearId;
  final String academicYearName;
  final int totalClasses;
  final int totalFeeStructures;
  final String totalMandatoryFees;
  final String totalOptionalFees;
  final List<ClassFeesStructureDto> classSummaries;

  FeesStructureSummaryDto({
    required this.academicYearId,
    required this.academicYearName,
    required this.totalClasses,
    required this.totalFeeStructures,
    required this.totalMandatoryFees,
    required this.totalOptionalFees,
    required this.classSummaries,
  });

  factory FeesStructureSummaryDto.fromJson(Map<String, dynamic> json) {
    return FeesStructureSummaryDto(
      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],
      totalClasses: json['totalClasses'],
      totalFeeStructures: json['totalFeeStructures'],
      totalMandatoryFees: json['totalMandatoryFees'],
      totalOptionalFees: json['totalOptionalFees'],
      classSummaries: (json['classSummaries'] as List)
          .map((item) => ClassFeesStructureDto.fromJson(item))
          .toList(),
    );
  }
}