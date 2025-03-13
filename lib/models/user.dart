class User {
  final String id;
  final String email;
  final String displayName;
  final String userType;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      userType: json['userType'],
    );
  }

  static List<User> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((user) => User.fromJson(user)).toList();
  }
}
