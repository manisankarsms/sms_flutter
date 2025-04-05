class Class {
  final String id;
  final String name;
  final String? staff;
  final String? staffId;  // Added field to store instructor ID
  final List<String>? subjectIds;  // Added field to store subject IDs
  final List<String>? subjectNames; // Added field to store subject names

  Class({
    required this.id,
    required this.name,
    this.staff,
    this.staffId,
    this.subjectIds,
    this.subjectNames,
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
    };
  }
}