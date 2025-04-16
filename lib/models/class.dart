class Class {
  final String id;
  final String name;
  final String? staff;
  final String? staffId;
  final List<String>? subjectIds;
  final List<String>? subjectNames;

  // Newly added fields
  final String? subjectId;
  final String? subjectName;

  Class({
    required this.id,
    required this.name,
    this.staff,
    this.staffId,
    this.subjectIds,
    this.subjectNames,
    this.subjectId,
    this.subjectName,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'].toString(),
      name: json['name'],
      staff: json['staff'],
      staffId: json['staffId'],
      subjectIds: json['subjectIds'] != null
          ? List<String>.from(json['subjectIds'])
          : null,
      subjectNames: json['subjectNames'] != null
          ? List<String>.from(json['subjectNames'])
          : null,
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'staff': staff,
      'staffId': staffId,
      'subjectIds': subjectIds,
      'subjectNames': subjectNames,
      'subjectId': subjectId,
      'subjectName': subjectName,
    };
  }

  @override
  String toString() {
    return 'Class(id: $id, name: $name, staff: $staff, staffId: $staffId, '
        'subjectIds: $subjectIds, subjectNames: $subjectNames, '
        'subjectId: $subjectId, subjectName: $subjectName)';
  }
}
