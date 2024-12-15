class Profile {
  final String studentName;
  final String studentId;
  final String email;
  final String phone;
  final String address;
  final String dateOfBirth;
  final String gender;
  final String department;
  final String yearOfStudy;
  final String major;
  final String minor;
  final double gpa;
  final List<String> classes;
  final String academicAdvisor;
  final String academicStanding;
  final List<String> scholarships;
  final List<String> achievements;
  final List<String> activities;
  final List<String> hobbies;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelationship;

  Profile({
    required this.studentName,
    required this.studentId,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.department,
    required this.yearOfStudy,
    required this.major,
    required this.minor,
    required this.gpa,
    required this.classes,
    required this.academicAdvisor,
    required this.academicStanding,
    required this.scholarships,
    required this.achievements,
    required this.activities,
    required this.hobbies,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelationship,
  });

  Profile copyWith({
    String? studentName,
    String? studentId,
    String? email,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
    String? department,
    String? yearOfStudy,
    String? major,
    String? minor,
    double? gpa,
    List<String>? classes,
    String? academicAdvisor,
    String? academicStanding,
    List<String>? scholarships,
    List<String>? achievements,
    List<String>? activities,
    List<String>? hobbies,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
  }) {
    return Profile(
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      major: major ?? this.major,
      minor: minor ?? this.minor,
      gpa: gpa ?? this.gpa,
      classes: classes ?? this.classes,
      academicAdvisor: academicAdvisor ?? this.academicAdvisor,
      academicStanding: academicStanding ?? this.academicStanding,
      scholarships: scholarships ?? this.scholarships,
      achievements: achievements ?? this.achievements,
      activities: activities ?? this.activities,
      hobbies: hobbies ?? this.hobbies,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelationship: emergencyContactRelationship ?? this.emergencyContactRelationship,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      studentName: json['studentName'],
      studentId: json['studentId'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      department: json['department'],
      yearOfStudy: json['yearOfStudy'],
      major: json['major'],
      minor: json['minor'],
      gpa: json['gpa'].toDouble(),
      classes: List<String>.from(json['classes']),
      academicAdvisor: json['academicAdvisor'],
      academicStanding: json['academicStanding'],
      scholarships: List<String>.from(json['scholarships']),
      achievements: List<String>.from(json['achievements']),
      activities: List<String>.from(json['activities']),
      hobbies: List<String>.from(json['hobbies']),
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      emergencyContactRelationship: json['emergencyContactRelationship'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'studentId': studentId,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'major': major,
      'minor': minor,
      'gpa': gpa,
      'classes': classes,
      'academicAdvisor': academicAdvisor,
      'academicStanding': academicStanding,
      'scholarships': scholarships,
      'achievements': achievements,
      'activities': activities,
      'hobbies': hobbies,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelationship': emergencyContactRelationship,
    };
  }
}
