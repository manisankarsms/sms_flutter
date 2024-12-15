class User {
  final String id;
  final String email;
  final String displayName;
  final String userType;
  // Add more properties as needed

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
    // Initialize additional properties here
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      userType: json['userType'],
      // Parse additional properties from JSON here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      // Convert additional properties to JSON here
    };
  }
}
