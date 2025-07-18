class AcademicYear {
  final String id;
  final String year;
  final String startDate;
  final String endDate;
  final bool isActive;

  AcademicYear({
    required this.id,
    required this.year,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'],
      year: json['year'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isActive: json['isActive'] ?? false,
    );
  }
}