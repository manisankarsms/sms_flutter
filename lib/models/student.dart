class Student {
  final String studentId; // ✅ Added studentId
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String contactNumber;
  final String email;
  final String address;
  final String studentStandard;

  Student({
    required this.studentId, // ✅ Added this field
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.studentStandard,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? '', // ✅ Added field with fallback
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      studentStandard: json['studentStandard'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId, // ✅ Added field
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'studentStandard': studentStandard,
    };
  }
}
