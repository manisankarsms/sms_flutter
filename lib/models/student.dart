class Student {
  final String studentId;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String contactNumber;
  final String email;
  final String address;
  final String studentStandard;
  final String? marksScored; // ✅ Optional marksScored field

  Student({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.studentStandard,
    this.marksScored,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? '',
      firstName: json['firstName'] ?? json['studentName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      studentStandard: json['studentStandard'] ?? '',
      marksScored: json['marksScored']?.toString(), // Nullable
    );
  }

  /// Full object to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'studentStandard': studentStandard,
      if (marksScored != null) 'marksScored': int.tryParse(marksScored!) ?? 0,
    };
  }

  /// Marks-only JSON for mark entry or update
  Map<String, dynamic> toMarksJson() {
    return {
      'studentId': studentId,
      'studentName': fullName,
      'marksScored': int.tryParse(marksScored ?? '0') ?? 0,
    };
  }
}
