class Profile {
  final String email;
  final String mobileNumber;
  final String role;
  final String firstName;
  final String lastName;
  final String createdAt;
  final String? updatedAt;
  final String? avatarUrl;

  const Profile({
    required this.email,
    required this.mobileNumber,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    this.updatedAt,
    this.avatarUrl,
  });

  Profile copyWith({
    String? email,
    String? mobileNumber,
    String? role,
    String? firstName,
    String? lastName,
    String? createdAt,
    String? updatedAt,
    String? avatarUrl,
  }) {
    return Profile(
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'mobileNumber': mobileNumber,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'avatarUrl': avatarUrl,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      email: json['email'] as String,
      mobileNumber: json['mobileNumber'] as String,
      role: json['role'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';

  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Profile &&
        other.email == email &&
        other.mobileNumber == mobileNumber &&
        other.role == role &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return email.hashCode ^
    mobileNumber.hashCode ^
    role.hashCode ^
    firstName.hashCode ^
    lastName.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    avatarUrl.hashCode;
  }

  @override
  String toString() {
    return 'Profile(email: $email, mobileNumber: $mobileNumber, role: $role, firstName: $firstName, lastName: $lastName, createdAt: $createdAt, updatedAt: $updatedAt, avatarUrl: $avatarUrl)';
  }
}